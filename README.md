# Backchat

Backchat is a JRuby-only gem that provides the
[Smack](http://www.igniterealtime.org/projects/smack/) XMPP libraries
and adds connection-pooling resources to them. It exists because there
are [no](https://github.com/ln/xmpp4r) [good](https://github.com/blaine/xmpp4r-simple)
[native](https://github.com/bryanwoods/babylon) XMPP libraries for Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'backchat'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install backchat

## Usage

You'll need to require all of the Smack libraries you need inside your app with
the standard JRuby syntax:

```ruby
java_import 'org.jivesoftware.smacmx.muc.MultiUserChat'
java_import 'org.jivesoftware.smacmx.Form'
...
```

But you'll get connection pooling for free. Yay! Inside your app, configure
Backchat's pool in some kind of initializer:

```ruby
Backchat::ConnectionPool.configure do
  host 'jabber.org'
  username 'admin'
  password 's3cr3t$@ren0fun'
  pool_size: 5 # five connections is the default
end

# configure also accepts a hash
Backchat::ConnectionPool.configure(host: 'jabber.org', username: 'admin',
  password: 's3cr3t$@ren0fun', pool_size: 5)
```

Once Backchat is configured, you can use the connection pool like magic:

```ruby
# connection_pool takes a block and passes it an XMPPConnection.
Backchat.connection_pool do |conn|
  chat = MultiUserChat.new(conn, 'my-room@solonely.localhost')
  chat.create('me')
end
```

The connection pool is created on the first call to `Backchat#connection_pool`,
provides authenticated connections, and blocks until a connection is available.
In the future it seems like it'd be nice to have a group of unauthenticated
connections so the pool could be used with multiple users, but my current use
case doesn't require it so it's missing in this version.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
