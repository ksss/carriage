class Carriage
  module Pushable
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def perform_async(*args)
        carriage = Carriage.new
        job = Job.new(self.to_s, args, SecureRandom.hex(16))
        len = carriage.redis.rpush("carriage:waitings", Marshal.dump(job))

        PerformAsyncOutput.new(len, job)
      end
    end
  end
end
