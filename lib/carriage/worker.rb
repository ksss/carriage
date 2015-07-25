class Carriage
  module Worker
    def run
      logger.info "run"
      until @stop
        key, value = server.carriage.redis.blpop("carriage:waitings")
        if key.nil?
          next
        end
        job = Marshal.load(value)
        unless job.kind_of?(Carriage::Job)
          raise TypeError, "must be instance of Carriage::Job"
        end

        k = Object.const_get(job.klass, false)

        logger.info "status:start\tdate:#{Time.now}\tjid:#{job.jid}"

        time = Benchmark.realtime {
          k.new.perform(*job.args)
        }

        logger.info "status:done\ttime:#{time}\tjid:#{job.jid}"
      end
    end

    def stop
      logger.info "stop"
      @stop = true
      server.carriage.redis.client.disconnect
    end
  end
end
