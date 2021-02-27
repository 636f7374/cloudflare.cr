require "./src/cloudflare.cr"
require "./serialization/serialization.cr"
require "./serialization/*"
require "./cli/*"

option_parser = Cloudflare::CommandLine::OptionParser.new
option_parser.parse

import, output_path = option_parser.get!
starting_time = Time.local
export = Cloudflare::Serialization::Export.new
radar = Cloudflare::Radar.new options: import.to_options

concurrent_mutex = Mutex.new :unchecked
concurrent_fibers = Set(Fiber).new

rader_fiber = spawn { radar.perform }
concurrent_mutex.synchronize { concurrent_fibers << rader_fiber }

loop do
  all_dead = concurrent_mutex.synchronize { concurrent_fibers.all? { |fiber| fiber.dead? } }

  progress = String.build do |io|
    io << "\r" << "Completed: [" << radar.number_of_tasks_completed << "/" << radar.number_of_tasks << "]"
    io << " | Percentage: " << "[" << ((radar.number_of_tasks_completed / radar.number_of_tasks) * 100_i32).round(2_i32) << "%]"
    io << " | Elapsed: " << "[" << (Time.local - starting_time).to_s << "]"
  end

  all_dead ? STDOUT.puts(progress) : STDOUT.print(progress)

  if all_dead
    radar.storage.each do |storage_entry|
      export_entry = Cloudflare::Serialization::Export::Entry.new
      export_entry.ipRange = storage_entry.first
      storage_entry.last.list.each { |name, count| export_entry.list[name.to_s] = count }

      export.subnets << export_entry
    end

    export.createdAt = Time.local.to_s
    output_io = File.open filename: output_path, mode: "wb"
    output_io.write export.to_json.to_slice
    output_io.close

    break
  end

  next sleep 0.25_f32.seconds unless all_dead
end
