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
      case parallel.type
      in .distributed?
        process_standard_parallel_distributed serialized_redar: serialized_redar, parallel: parallel
      in .sub_process?
        process_standard_parallel_sub_process serialized_redar: serialized_redar, parallel: parallel
      end
    in Nil
      process_standard serialized_redar: serialized_redar
    end
  end

  private def self.process_standard(serialized_redar : Serialized::Radar::Standard)
    starting_time = Time.local
    output_path = serialized_redar.get_output_path!
    radar = serialized_redar.unwrap

    rader_fiber = spawn { radar.perform subnets: radar.options.radar.get_prefix_24_subnets }

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

  private def self.process_standard_parallel_sub_process(serialized_redar : Serialized::Radar::Standard, parallel : Serialized::Radar::Standard::Parallel)
    starting_time = Time.local
    output_path = serialized_redar.get_output_path!
    radar = serialized_redar.unwrap

    prefix_24_subnets = radar.options.radar.get_prefix_24_subnets
    serialized_callees = split_parallel_serialized_callee_set serialized_redar: serialized_redar, parallel: parallel, subnets: prefix_24_subnets

    exports = [] of Cloudflare::Serialized::Export
    exports_mutex = Mutex.new :unchecked

    case listen_address = parallel.get_listen_address!
    in Socket::IPAddress
      caller = TCPServer.new host: listen_address.address, port: listen_address.port
    in Socket::UNIXAddress
      caller = UNIXServer.new path: listen_address.path
    in Socket::Address
      abort "CommandLine.process_standard_parallel_sub_process: Unknown Parallel.listenAddress type (not IPAddress or UNIXAddress)."
    end

    external_controller = ExternalController.new io: caller, calleeSet: serialized_callees

    spawn do
      external_controller.perform
    end

    serialized_callees.size.times do
      spawn do
        process = Process.new command: parallel.executableName, args: ["-e", parallel.listenAddress], shell: true
        process.wait
      end
    end

    loop do
      if external_controller.done?
        external_controller.close rescue nil

        export = Cloudflare::Serialized::Export.new
        export.startingTime = starting_time
        export.createdAt = Time.local
        external_controller.get_exports.each &.subnets.each { |subnet| export.subnets << subnet }
        write_serialized_export_to_file export: export, output_path: output_path

        break
      end

      sleep 0.25_f32.seconds
    end
  end

  private def self.process_standard_parallel_distributed(serialized_redar : Serialized::Radar::Standard, parallel : Serialized::Radar::Standard::Parallel)
    starting_time = Time.local
    output_path = serialized_redar.get_output_path!
    radar = serialized_redar.unwrap

    prefix_24_subnets = radar.options.radar.get_prefix_24_subnets
    serialized_callees = split_parallel_serialized_callee_set serialized_redar: serialized_redar, parallel: parallel, subnets: prefix_24_subnets

    exports = [] of Cloudflare::Serialized::Export
    exports_mutex = Mutex.new :unchecked

    case listen_address = parallel.get_listen_address!
    in Socket::IPAddress
      caller = TCPServer.new host: listen_address.address, port: listen_address.port, reuse_port: true
    in Socket::UNIXAddress
      caller = UNIXServer.new path: listen_address.path
    in Socket::Address
      abort "CommandLine.process_standard_parallel_distributed: Unknown Parallel.listenAddress type (not IPAddress or UNIXAddress)."
    end

    external_controller = ExternalController.new io: caller, calleeSet: serialized_callees

    spawn do
      external_controller.perform
    end

    loop do
      if external_controller.done?
        external_controller.close rescue nil

        export = Cloudflare::Serialized::Export.new
        export.startingTime = starting_time
        export.createdAt = Time.local
        external_controller.get_exports.each &.subnets.each { |subnet| export.subnets << subnet }
        write_serialized_export_to_file export: export, output_path: output_path

        break
      end

      sleep 0.25_f32.seconds
    end
  end

  private def self.process_callee(option_parser : OptionParser, serialized_redar : Serialized::Radar::Callee)
    external_controller = option_parser.externalController
    abort "CommandLine.process_callee: (Error: CommandLine::OptionParser.externalController is Nil!)" unless external_controller

    starting_time = Time.local
    subnets = serialized_redar.subnets.map { |text_subnet| IPAddress.new addr: text_subnet }
    radar = serialized_redar.unwrap

    rader_fiber = spawn { radar.perform subnets: subnets.to_set }

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

    radar.storage.each do |subnet, entry|
      serialized_export_entry = Serialized::Export::Entry.new
      serialized_export_entry.subnet = subnet
      entry.edges.each { |name, count| serialized_export_entry.edges[name.to_s] = count }

      serialized_export.subnets << serialized_export_entry
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

  private def self.split_parallel_serialized_callee_set(serialized_redar : Serialized::Radar::Standard, parallel : Serialized::Radar::Standard::Parallel, subnets : Set(IPAddress::IPv4 | IPAddress::IPv6)) : Set(Serialized::Radar::Callee)
    serialized_callees = Set(Serialized::Radar::Callee).new

    per_callee_subnets_count = (subnets.size / parallel.calleeCount).to_i32
    per_callee_subnets_count += 1_i32

    subnets.each_slice per_callee_subnets_count do |subnets|
      next if subnets.empty?
      serialized_callee = Serialized::Radar::Callee.new

      serialized_callee.concurrentCount = serialized_redar.concurrentCount
      serialized_callee.numberOfScansPerSubnet = serialized_redar.numberOfScansPerSubnet
      serialized_callee.maximumNumberOfFailuresPerSubnet = serialized_redar.maximumNumberOfFailuresPerSubnet
      serialized_callee.skipRange = serialized_redar.skipRange
      serialized_callee.excludes = serialized_redar.excludes
      serialized_callee.timeout = serialized_redar.timeout.to_callee_timeout
      serialized_callee.subnets = subnets.map { |subnet| String.build { |io| io << subnet.address << '/' << subnet.prefix } }

      serialized_callees << serialized_callee
    end

    serialized_callees
  end
end

require "option_parser"
require "./command_line/*"
