module ThinLatency
  class Buffer

    def initialize(speed, type = :recv)
      @buffer = []
      @speed  = ((speed * 1000) / 8).round
      @type   = type
    end

    def push(data, &callback)
      @buffer.push([data, callback])
      schedule
    end

    def close
      @timer && @timer.cancel
    end

    def empty?
      @buffer.empty?
    end

    private

    # Makes speed variable +/- random percentage.
    # This means speed could momentarily double.
    def speed
      @speed.send([:+, :-].sample, (@speed * rand).round)
    end

    def schedule
      return if @timer
      @timer = EM::PeriodicTimer.new(1) do
        sent = 0
        while !empty? && sent < speed
          sent += shift
        end
        $stderr.warn "#{Time.new} #{@type} #{sent} bytes, #{sent * 8} bits"
        if empty?
          @timer.cancel
          @timer = nil
        end
      end
    end

    def shift
      return if @buffer.empty?
      data, cb = @buffer.shift
      if data.bytesize > @speed
        @buffer.unshift([data[@speed + 1 .. -1], cb])
        data = data[0..@speed]
      end
      cb.call(data)
      data.bytesize
    end

  end # class::Buffer
end # module::ThinLatency
