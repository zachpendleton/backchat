module Backchat
  class ConnectionPool
    include Enumerable

    DEFAULT_SETTINGS = {
      host: 'localhost',
      username: 'admin',
      password: 'password',
      pool_size: 5,
      persistent: true }

    @settings = DEFAULT_SETTINGS

    def initialize(count = self.class.settings[:pool_size])
      @queue = fill(SizedQueue.new(count))
    end

    def count
      queue.length
    end

    def take
      queue.pop
    end

    def add(connection)
      queue.push(connection)
    end

    def with_connection
      connection = take
      connection.connect unless connection.is_connected?
      connection.login(self.class.settings[:username],
                       self.class.settings[:password],
                       "resource_#{connection.connection_id}") unless connection.is_authenticated?
      yield connection
    ensure
      connection.disconnect unless self.class.settings[:persistent]
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
      [:host, :username, :password, :pool_size, :persistent].each do |key|
        define_method("#{key}") do |val|
          @settings ||= {}
          @settings[key] = val
        end
      end
    end

    private
    attr_reader :queue

    def fill(queue)
      while queue.length < queue.max
        conn = XMPPConnection.new(self.class.settings[:host])
        if self.class.settings[:persistent]
          conn.connect
          conn.login(self.class.settings[:username],
                     self.class.settings[:password],
                     "resource_#{conn.connection_id}")
        end

        queue.push(conn)
      end

      queue
    end
  end

  def self.connection_pool(&block)
    @connection_pool = ConnectionPool.new
    block_given? ? @connection_pool.with_connection(&block) : @connection_pool
  end
end
