require 'thin/connection'

module ThinLatency
  class Connection < Thin::Connection

    attr_accessor :rcv_buffer, :snd_buffer

    def post_init
      super
      @active     = true
    end

    def receive_data(data)
      rcv_buffer.push(data, &method(:receive_data!))
    end

    def send_data(data)
      snd_buffer.push(data, &method(:send_data!))
    end

    # @api private
    #
    # Override Thin::Connection#terminate request to prevent it from closing a
    # connection that has data in the buffer, that hasn't been passed ont the
    # EM network loop.
    def terminate_request
      return super if persistent?
      if @active
        @terminate_after_send = true
        return
      end
      super
    end

    def unbind
      snd_buffer.close
      rcv_buffer.close
    end

  private

    def receive_data!(data)
      #$stderr.warn "#{Time.new} recv #{data.bytesize} bytes"
      recver.call(data)
    end

    def send_data!(data)
      #$stderr.warn "#{Time.new} send #{data.bytesize} bytes"
      sender.call(data)
      if @terminate_after_send && snd_buffer.empty?
        @active = false
        terminate_request
      end
    end

    def sender
      # I'd prefer to initialize this in post_init, but the behavior of
      # Thin::Connection#terminate_requests causes an error when the client uses
      # HTTP pipelining.
      @sender  ||= Thin::Connection.instance_method(:send_data).bind(self)
    end

    def recver
      # I'd prefer to initialize this in post_init, but the behavior of
      # Thin::Connection#terminate_requests causes an error when the client uses
      # HTTP pipelining.
      @recver     = Thin::Connection.instance_method(:receive_data).bind(self)
    end

  end # class::Connection
end # module::ThinLatency
