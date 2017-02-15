require 'minitest/autorun'
require 'minitest/pride'
require './lib/server_runner'
require './lib/path_finder'
require 'faraday'
require 'pry'

class HttpTest < Minitest::Test

  attr_accessor :server, :conn
  def start_up(port)
    $close = false
    @server = Iterations.new(port)
    @conn = Faraday.new(:url => "http://127.0.0.1:#{port}")
  end

  def thread_setup(predicted_output, path)
    threads = []
    threads << Thread.new{server.start}
    threads << Thread.new do
      $close = true
      assert_equal predicted_output, html_clean_up(conn.get(path).body)
    end
    threads.each {|thread| thread.join}
  end

  def html_clean_up(body)
    body.split("<html><head></head><body><pre>")[1].split("</pre></body></html>").join
  end

  def test_server_exists_and_default_values
    start_up(9292)
    assert_instance_of Iterations, server
    assert_instance_of TCPServer, server.tcp_server
    assert_equal 0, server.hello_counter
    assert_equal 0, server.request_counter
  end

  def test_will_respond_to_an_http_request
    start_up(9290)
    threads = []
    threads << Thread.new {server.start}
    threads << Thread.new do
      $close = true
      response = conn.get '/'
      assert_instance_of Faraday::Response, response
    end
    threads.each {|thread| thread.join}
  end

  def test_path_finder_defaults
    start_up(9299)
    request_lines= ["GET / HTTP/1.1",
    "Host: 127.0.0.1:9299",
    "Connection: keep-alive",
    "Cache-Control: max-age=0",
    "Upgrade-Insecure-Requests: 1",
    "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
    "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "DNT: 1",
    "Accept-Encoding: gzip, deflate, sdch, br",
    "Accept-Language: en-US,en;q=0.8,de;q=0.6,es;q=0.4,it;q=0.2"]
    path_finder_test = PathFinder.new(request_lines, server)
    assert_equal "GET", path_finder_test.verb
    assert_equal "/", path_finder_test.path
    assert_equal "HTTP/1.1", path_finder_test.protocol
    assert_equal "127.0.0.1", path_finder_test.host
    assert_equal "9299", path_finder_test.port
    assert_equal "127.0.0.1", path_finder_test.origin
    assert_equal "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8", path_finder_test.accept
    assert_instance_of Iterations, path_finder_test.server
  end

  def test_root_path
    start_up(9293)
    statement = "Verb: GET\nPath: /\nProtocol: HTTP/1.1\nHost: 127.0.0.1\nPort: 9293\nOrigin: 127.0.0.1\nAccept: */*"
    thread_setup(statement, "/")
  end

  def test_single_hello
    start_up(9291)
    statement = "Hello, World! (0)"
    thread_setup(statement, "/hello")
  end

  def test_multiple_hello
    start_up(9294)
    statement = "Hello, World! (0)"
    thread_setup(statement, "/hello")
    statement = "Hello, World! (1)"
    thread_setup(statement, "/hello")
    statement = "Hello, World! (2)"
    thread_setup(statement, "/hello")
  end

  def test_date_time
    start_up(9295)
    statement = "#{Time.now.strftime('%I:%M%p on %A, %B %e, %Y')}"
    thread_setup(statement, "/datetime")
  end

  def test_shutdown
    start_up(9296)
    statement = "Total Requests: 1"
    threads = []
    threads << Thread.new{server.start}
    threads << Thread.new do
      assert_equal statement, html_clean_up(conn.get("/shutdown").body)
    end
    threads.each {|thread| thread.join}
  end

  def test_word_game
    start_up(9297)
    statement = "hello is a known word"
    thread_setup(statement, "/path?word=hello")
    statement = "poohead is not a known word"
    thread_setup(statement, "/path?word=poohead")
  end

  def test_possible_paths_with_shutdown
    start_up(9298)
    statement = "Verb: GET\nPath: /\nProtocol: HTTP/1.1\nHost: 127.0.0.1\nPort: 9298\nOrigin: 127.0.0.1\nAccept: */*"
    thread_setup(statement, "/")
    statement = "Hello, World! (0)"
    thread_setup(statement, "/hello")
    statement = "poohead is not a known word"
    thread_setup(statement, "/path?word=poohead")
    statement = "Hello, World! (1)"
    thread_setup(statement, "/hello")
    statement = "#{Time.now.strftime('%I:%M%p on %A, %B %e, %Y')}"
    thread_setup(statement, "/datetime")
    statement = "Hello, World! (2)"
    thread_setup(statement, "/hello")
    statement = "hello is a known word"
    thread_setup(statement, "/path?word=hello")
    statement = "Total Requests: 8"
    threads = []
    threads << Thread.new{server.start}
    threads << Thread.new do
      assert_equal statement, html_clean_up(conn.get("/shutdown").body)
    end
    threads.each {|thread| thread.join}
  end


 end
