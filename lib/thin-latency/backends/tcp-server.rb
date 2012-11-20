require 'thin/backends/tcp_server'
require 'thin-latency/connection'
require 'thin-latency/buffer'

module ThinLatency
  module Backends
    class TcpServer < Thin::Backends::TcpServer

      class << self
        def snd_buffer(address, speed = DOWNLOAD_SPEED)
          @snd_buffers ||= Hash.new {|h,k| h[k] = Buffer.new(speed, :send) }
          @snd_buffers[address]
        end

        def rcv_buffer(address, speed = UPLOAD_SPEED)
          @rcv_buffers ||= Hash.new {|h,k| h[k] = Buffer.new(speed, :recv) }
          @rcv_buffers[address]
        end
      end

      # Default connection speed in kbps
      DOWNLOAD_SPEED = 128
      UPLOAD_SPEED   = 128


      # @return [Fixnum] connection upload speed in kbps. override it by
      # passing the +:ul_speed+ option to TcpServer#initialize, or Thin::Server#initialize
      attr_reader :ul_speed

      # @return [Fixnum] connection download speed in kbps. override it by
      # passing the +:dl_speed+ option to TcpServer#initialize, or Thin::Server#initialize
      attr_reader :dl_speed

      def initialize(host, port, options)
        super(host, port)

        @dl_speed   = options[:dl_speed]
        @dl_speed   = options[:speed] / 2 if !@dl_speed && options[:speed]
        @dl_speed ||= DOWNLOAD_SPEED

        @ul_speed   = options[:ul_speed]
        @ul_speed   = options[:speed] / 2 if !@dl_speed && options[:speed]
        @ul_speed ||= UPLOAD_SPEED
      end

      def connect
        @signature = EventMachine.start_server(@host, @port, ThinLatency::Connection, &method(:initialize_connection))
      end


    protected

      def initialize_connection(connection)
        port, ip = Socket.unpack_sockaddr_in(connection.get_peername)
        connection.rcv_buffer = self.class.rcv_buffer(ip, @dl_speed)
        connection.snd_buffer = self.class.snd_buffer(ip, @ul_speed)
        super(connection)
      end


    end # class TcpServer
  end # module::Backends
end # module::ThinLatency
