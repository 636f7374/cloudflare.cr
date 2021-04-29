module Cloudflare::CommandLine
  def self.perform(option_parser : OptionParser)
    case serialized_redar = option_parser.get_radar!
    in Serialized::Radar::Standard
      process_standard option_parser: option_parser, serialized_redar: serialized_redar
    in Serialized::Radar::Callee
      process_callee option_parser: option_parser, serialized_redar: serialized_redar
    end
  end

  private def self.process_standard(option_parser : OptionParser, serialized_redar : Serialized::Radar::Standard)
    case parallel = serialized_redar.parallel
    in Serialized::Radar::Standard::Parallel
      process_parallel serialized_redar: serialized_redar, parallel: parallel
    in Nil
      process_standard serialized_redar: serialized_redar
    end
  end

  private def self.process_standard(serialized_redar : Serialized::Radar::Standard)
    starting_time = Time.local
    output_path = serialized_redar.get_output_path!
    radar = serialized_redar.unwrap

    rader_fiber = spawn { radar.perform ip_blocks: radar.options.radar.get_prefix_24_ip_blocks }

    loop do
      rader_fiber_dead = rader_fiber.dead?

      progress_bar = create_text_progress_bar radar: radar, starting_time: starting_time
      rader_fiber_dead ? STDOUT.puts(progress_bar) : STDOUT.print(progress_bar)

      if rader_fiber_dead
        write_serialized_export_to_file radar: radar, output_path: output_path, starting_time: starting_time

        break
      end

      next sleep 0.25_f32.seconds unless rader_fiber_dead
    end
  end

  private def self.process_parallel(serialized_redar : Serialized::Radar::Standard, parallel : Serialized::Radar::Standard::Parallel)
    starting_time = Time.local
    output_path = serialized_redar.get_output_path!
    radar = serialized_redar.unwrap

    prefix_24_ip_blocks = radar.options.radar.get_prefix_24_ip_blocks
    serialized_callees = split_parallel_serialized_callee_set serialized_redar: serialized_redar, parallel: parallel, ip_blocks: prefix_24_ip_blocks

    exports = [] of Cloudflare::Serialized::Export
    exports_mutex = Mutex.new :unchecked

    case listen_address = parallel.get_listen_address!
    in Socket::IPAddress
      caller = TCPServer.new host: listen_address.address, port: listen_address.port
    in Socket::UNIXAddress
      caller = UNIXServer.new path: listen_address.path
    in Socket::Address
      abort "CommandLine.process_parallel: Unknown Parallel.listenAddress type (not IPAddress or UNIXAddress)."
    end

    external_controller = ExternalController.new io: caller, calleeSet: serialized_callees
    spawn { external_controller.perform }

    case parallel.type
    in .sub_process?
      sub_process_count = serialized_callees.size
    in .hybrid?
      sub_process_count = parallel.subProcessCalleeCount || 0_i32
      sub_process_count = 0_i32 if 0_i32 > sub_process_count
      sub_process_count = serialized_callees.size if sub_process_count > serialized_callees.size
    in .distributed?
      sub_process_count = 0_i32
    end

    sub_process_count.times do
      spawn do
        process = Process.new command: parallel.executableName, args: ["-e", parallel.listenAddress], shell: true
        process.wait
      end
    end

    loop do
      if external_controller.done?
        external_controller.close rescue nil

        write_serialized_export_to_file exports: external_controller.get_exports, output_path: output_path

        break
      end

      sleep 0.25_f32.seconds
    end
  end

  private def self.process_callee(option_parser : OptionParser, serialized_redar : Serialized::Radar::Callee)
    external_controller = option_parser.externalController
    abort "CommandLine.process_callee: (Error: CommandLine::OptionParser.externalController is Nil!)" unless external_controller

    starting_time = Time.local
    ip_blocks = serialized_redar.ipBlocks.map { |ip_block_text| IPAddress.new addr: ip_block_text }
    radar = serialized_redar.unwrap

    rader_fiber = spawn { radar.perform ip_blocks: ip_blocks.to_set }

    loop do
      rader_fiber_dead = rader_fiber.dead?

      progress_bar = create_text_progress_bar radar: radar, starting_time: starting_time
      rader_fiber_dead ? STDOUT.puts(progress_bar) : STDOUT.print(progress_bar)

      progress_frame = create_progress_frame radar: radar, starting_time: starting_time
      slice = progress_frame.to_json.to_slice
      external_controller.write_bytes slice.size, IO::ByteFormat::BigEndian
      external_controller.write slice: slice
      external_controller.flush

      if rader_fiber_dead
        export = create_serialized_export radar: radar, starting_time: starting_time
        slice = export.to_yaml.to_slice

        external_controller.write_bytes slice.size, IO::ByteFormat::BigEndian
        external_controller.write slice: slice
        external_controller.flush
        external_controller.close

        break
      end

      next sleep 0.25_f32.seconds unless rader_fiber_dead
    end
  end

  private def self.create_progress_frame(radar : Cloudflare::Radar, starting_time : Time) : Serialized::Frames::Radar::Progress
    Serialized::Frames::Radar::Progress.new numberOfTasks: radar.number_of_tasks, numberOfTasksCompleted: radar.number_of_tasks_completed
  end

  private def self.create_text_progress_bar(radar : Cloudflare::Radar, starting_time : Time) : String
    String.build do |io|
      io << "\r" << "Completed: [" << radar.number_of_tasks_completed << "/" << radar.number_of_tasks << "]"
      io << " | Percentage: " << "[" << ((radar.number_of_tasks_completed / radar.number_of_tasks) * 100_i32).round(2_i32) << "%]"
      io << " | Elapsed: " << "[" << (Time.local - starting_time).to_s << "]"
    end
  end

  private def self.create_serialized_export(radar : Cloudflare::Radar, starting_time : Time) : Serialized::Export
    serialized_export = Serialized::Export.new
    serialized_export.startingTime = starting_time

    radar.storage.each do |ip_block, entry|
      serialized_export_entry = Serialized::Export::Entry.new
      serialized_export_entry.ipBlock = ip_block
      entry.edges.each { |name, count| serialized_export_entry.edges[name.to_s] = count }

      serialized_export.ipBlocks << serialized_export_entry
    end

    serialized_export.createdAt = Time.local
    serialized_export
  end

  private def self.write_serialized_export_to_file(radar : Cloudflare::Radar, output_path : String, starting_time : Time)
    export = create_serialized_export radar: radar, starting_time: starting_time
    write_serialized_export_to_file export: export, output_path: output_path
  end

  private def self.write_serialized_export_to_file(export : Serialized::Export, output_path : String)
    output = File.open filename: output_path, mode: "wb"
    output.write export.to_yaml.to_slice

    output.close
  end

  private def self.write_serialized_export_to_file(exports : Set(Serialized::Export), output_path : String)
    output = File.open filename: output_path, mode: "wb"
    output.write exports.to_yaml.to_slice

    output.close
  end

  private def self.split_parallel_serialized_callee_set(serialized_redar : Serialized::Radar::Standard, parallel : Serialized::Radar::Standard::Parallel, ip_blocks : Set(IPAddress::IPv4 | IPAddress::IPv6)) : Set(Serialized::Radar::Callee)
    serialized_callees = Set(Serialized::Radar::Callee).new

    per_callee_ip_blocks_count = (ip_blocks.size / parallel.calleeCount).to_i32
    per_callee_ip_blocks_count += 1_i32

    ip_blocks.each_slice per_callee_ip_blocks_count do |slice_ip_blocks|
      next if slice_ip_blocks.empty?
      serialized_callee = Serialized::Radar::Callee.new

      serialized_callee.concurrentCount = serialized_redar.concurrentCount
      serialized_callee.numberOfScansPerBlock = serialized_redar.numberOfScansPerBlock
      serialized_callee.maximumNumberOfFailuresPerBlock = serialized_redar.maximumNumberOfFailuresPerBlock
      serialized_callee.skipRange = serialized_redar.skipRange
      serialized_callee.excludes = serialized_redar.excludes
      serialized_callee.timeout = serialized_redar.timeout
      serialized_callee.ipBlocks = slice_ip_blocks.map { |ip_blocks| String.build { |io| io << ip_blocks.address << '/' << ip_blocks.prefix } }
      serialized_callees << serialized_callee
    end

    serialized_callees
  end
end

require "option_parser"
require "./command_line/*"
