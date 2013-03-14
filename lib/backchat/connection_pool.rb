module Backchat
  class ConnectionPool
    include Enumerable

    DEFAULT_SETTINGS = {
      host: 'localhost',
      username: 'admin',
      password: 'password',
      pool_size: 5 }

    @settings = DEFAULT_SETTINGS

    def initialize(count = self.class.settings[:pool_size])
      @queue = fill(ArrayBlockingQueue.new(count))
    end

    def each(&block)
      queue.each(&block)
    end

    def take
      queue.take
    end

    def add(connection)
      queue.add(connection)
    end

    def with_connection
      connection = take
      yield connection
    ensure
      add(connection)
    end


    class << self
      attr_reader :settings

      def configure(settings = {}, &block)
        if block_given?
          instance_eval(&block)
        else
          @settings.merge!(settings)
        end
      end

      def connection(credentials = {})
        connection = XMPPConnection.new(settings[:host])
        connection.connect
        if (credentials.keys & [:username, :password]).count == 2
          connection.login(*credentials.values_at(:username, :password))
        end

        yield connection
      ensure
        connection.disconnect
      end

      private
      [:host, :username, :password, :pool_size].each do |key|
        define_method("#{key}") do |val|
          @settings ||= {}
          @settings[key] = val
        end
      end
    end

    private
    attr_reader :queue

    def fill(queue)
      while queue.remaining_capacity > 0
        conn = XMPPConnection.new(self.class.settings[:host])
        conn.connect
        conn.login(self.class.settings[:username],
                   self.class.settings[:password], conn.connection_id)

        queue.add(conn)
      end

      queue
    end
  end

  def self.connection_pool(&block)
    @connection_pool = ConnectionPool.new
    block_given? ? @connection_pool.with_connection(&block) : @connection_pool
  end
end
