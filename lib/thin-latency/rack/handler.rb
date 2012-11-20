module ThinLatency
  module Rack
    class Handler
      ::Rack::Handler.register 'thin-latency', 'ThinLatency::Rack::Handler'

      def self.run(app, options={})
        server = ::Thin::Server.new(options[:Host] || '0.0.0.0',
                                    options[:Port] || 8080,
                                    app,
                                    :backend => ThinLatency::Backends::TcpServer)
        yield server if block_given?
        server.start
      end

      def self.valid_options
        {
          "Host=HOST" => "Hostname to listen on (default: localhost)",
          "Port=PORT" => "Port to listen on (default: 8080)",
        }
      end
    end
  end
end
