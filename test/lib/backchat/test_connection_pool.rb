require File.expand_path('../../test_helper', File.dirname(__FILE__))

class BackchatConnectionPoolTest < MiniTest::Unit::TestCase
  def setup
    XMPPConnection.any_instance.stubs(:connect).returns(nil)
    XMPPConnection.any_instance.stubs(:login).returns(nil)

    @pool = Backchat::ConnectionPool.new(5)
  end

  def test_configure_saves_settings_passed_in_a_block
    Backchat::ConnectionPool.configure do
      host     'example.com'
      username 'don_draper'
      password 'secret'
      pool_size 1
    end

    assert_equal Backchat::ConnectionPool.settings, { host: 'example.com',
                                                      username: 'don_draper',
                                                      password: 'secret',
                                                      pool_size: 1,
                                                      persistent: true }
  end

  def test_configure_accepts_a_hash
    Backchat::ConnectionPool.configure(host: 'example.com', username: 'don_draper',
                                       password: 'secret', pool_size: 1)

    assert_equal Backchat::ConnectionPool.settings, { host: 'example.com',
                                                      username: 'don_draper',
                                                      password: 'secret',
                                                      pool_size: 1,
                                                      persistent: true }
  end

  def test_configure_allows_partial_settings_in_a_block
    Backchat::ConnectionPool.configure { host 'example.com' }

    assert_equal Backchat::ConnectionPool.settings,
      Backchat::ConnectionPool::DEFAULT_SETTINGS.merge(host: 'example.com')
  end

  def test_configure_allows_partial_settings_in_a_hash
    Backchat::ConnectionPool.configure(host: 'example.com')

    assert_equal Backchat::ConnectionPool.settings,
      Backchat::ConnectionPool::DEFAULT_SETTINGS.merge(host: 'example.com')
  end

  def test_initialize_creates_a_queue
    assert_includes @pool.instance_variables, :@queue
  end

  def test_queue_is_a_queue
    assert_instance_of SizedQueue, @pool.instance_variable_get(:@queue)
  end

  def test_initialize_fills_the_pool_with_connections
    assert_equal 5, @pool.count
  end

  def test_initialize_fills_the_pool_with_the_number_of_connections_it_is_passed
    assert_equal 1, Backchat::ConnectionPool.new(1).count
  end

  def test_initialize_connects_new_connections
    XMPPConnection.any_instance.expects(:connect)
    Backchat::ConnectionPool.new(1)
  end

  def test_initialize_authenticates_new_connections
    XMPPConnection.any_instance.expects(:login)
    Backchat::ConnectionPool.new(1)
  end

  def test_take_removes_a_connection_from_the_queue
    @pool.take
    assert_equal 4, @pool.count
  end

  def test_add_adds_a_connection_to_the_queue
    conn = @pool.take
    @pool.add(conn)

    assert_equal 5, @pool.count
  end

  def test_with_connection_yields_a_block_with_a_connection
    @pool.with_connection do |conn|
      assert_instance_of XMPPConnection, conn
    end
  end

  def test_with_connection_removes_a_connection_from_the_pool_and_returns_it
    @pool.with_connection do |conn|
      assert_equal 4, @pool.count
    end

    assert_equal 5, @pool.count
  end

  def test_with_connection_ensures_that_a_connection_is_returned_to_the_pool
    @pool.with_connection { |conn| raise 'Error' }
  rescue
    assert_equal 5, @pool.count
  end

  def test_connection_yields_with_an_unauthenticated_connection
    XMPPConnection.any_instance.expects(:login).never

    Backchat::ConnectionPool.connection { |conn| }
  end

  def test_connection_accepts_credentials
    XMPPConnection.any_instance.expects(:login)

    Backchat::ConnectionPool.connection(username: 'don_draper',
                                        password: 'secret') { |conn| }
  end

  def test_backchat_connection_pool_creates_a_pool
    refute Backchat.instance_variable_get(:@connection_pool)
    assert_instance_of Backchat::ConnectionPool, Backchat.connection_pool
  end
end
