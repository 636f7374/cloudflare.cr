module Cloudflare::Serialized
  module Frames
    abstract struct Radar
      include JSON::Serializable

      struct Progress < Radar
        property numberOfTasks : UInt64
        property numberOfTasksCompleted : UInt64

        def initialize(@numberOfTasks : UInt64, @numberOfTasksCompleted : UInt64)
        end
      end
    end
  end
end
