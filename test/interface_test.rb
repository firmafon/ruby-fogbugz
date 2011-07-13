require 'test_helper.rb'

class InitializationTest < FogTest
  def setup
    @uri = 'http://fogbugz.example.com'
  end

  test 'initializing with uri' do
    f = Fogbugz::Interface.new(@uri)
    assert_match /^#{@uri}/, f.uri
  end

  test 'removing trailing path separator from uri' do
    f = Fogbugz::Interface.new("#{@uri}/")
    assert_match /^#{@uri}/, f.uri
  end

  test 'accepting email option' do
    f = Fogbugz::Interface.new(@uri, :email => 'test@example.com')
    assert_equal 'test@example.com', f.email
  end

  test 'accepting password option' do
    f = Fogbugz::Interface.new(@uri, :password => 'test')
    assert_equal 'test', f.password
  end

  test 'accepting optional root path with leading path separator' do
    f = Fogbugz::Interface.new(@uri, :root => '/fogbugz')
    assert_match /^#{@uri}\/fogbugz\//, f.uri
  end

  test 'accepting optional root path with trailing path separator' do
    f = Fogbugz::Interface.new(@uri, :root => 'fogbugz/')
    assert_match /^#{@uri}\/fogbugz\//, f.uri
  end

  test 'accepting optional root path no path separator' do
    f = Fogbugz::Interface.new(@uri, :root => 'fogbugz')
    assert_match /^#{@uri}\/fogbugz\//, f.uri
  end

  test 'accepting optional endpoint for api' do
    f = Fogbugz::Interface.new(@uri, :endpoint => 'api.php')
    assert_match /\/api\.php$/, f.uri
  end

  test 'acceptiong endpoint and root options' do
    f = Fogbugz::Interface.new(@uri, :root => 'fogbugz', :endpoint => 'api.php')
    assert_equal "#{@uri}/fogbugz/api.php", f.uri
  end

  test 'accepting auth token option' do
    f = Fogbugz::Interface.new(@uri, :token => 'test')
    assert_equal 'test', f.token
  end
end

class AuthenticationTest < FogTest
  def setup
    @uri = 'http://fogbugz.example.com'
    @new_credentials = { :email => 'test-2@example.com', :password => 'test' }
    @credentials = { :email => 'test@example.com', :password => 'testpassword' }
    @fogbugz = Fogbugz::Interface.new(@uri, @credentials)
    @token = 'testtoken'
  end

  test 'logon with provided credentials' do
    @fogbugz.expects(:command).with(:logon, @new_credentials).
      returns 'token' => @token
    @fogbugz.logon @new_credentials
    assert_equal @token, @fogbugz.token
  end

  test 'authenticate with provided credentials' do
    @fogbugz.expects(:command).with(:logon, @new_credentials).
      returns 'token' => @token
    @fogbugz.logon @new_credentials
    assert_equal @token, @fogbugz.token
  end
  
  test 'logon with default credentials' do
    @fogbugz.expects(:command).with(:logon, @credentials).
      returns 'token' => @token
    @fogbugz.logon
    assert_equal @token, @fogbugz.token
  end

  test 'authentication with default credentials' do
    @fogbugz.expects(:command).with(:logon, @credentials).
      returns 'token' => @token
    @fogbugz.authenticate
    assert_equal @token, @fogbugz.token
  end
end

class CommandTest < FogTest
  def setup
    @uri = 'http://fogbugz.example.com'
    @token = 'token'
    @fogbugz = Fogbugz::Interface.new(@uri, :token => @token)
  end

  test 'sending correct parameters with command' do
    command = mock()
    command.expects(:execute).returns('test' => 'test')
    Fogbugz::Command.expects(:new).
      with(@fogbugz.uri, { :cmd => 'search', :q => 'case', :token => @token }).
      returns(command)
    assert_equal({'test' => 'test'}, @fogbugz.command(:search, :q => 'case'))
  end

  test 'yielding command to block' do
    command = mock()
    command.expects(:test).with('test')
    command.expects(:execute).returns(:test => 'test')
    Fogbugz::Command.expects(:new).
      with(@fogbugz.uri, :cmd => 'search', :token => @token).returns(command)
    resp = @fogbugz.command(:search) do |c|
      c.test 'test'
    end
    assert_equal resp[:test], 'test'
  end
end
