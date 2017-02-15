require 'socket'
require 'pry'

class Iterations
  attr_reader :tcp_server, :hello_counter, :request_counter
  def initialize(port)
    @tcp_server = TCPServer.new(port)
    @hello_counter = 0
    @request_counter = 0
  end

  def start
    loop do
      accept_and_listen
      analyze_request
      @body = output_decider
      respond(@body)
      break if @path == "/shutdown" || $close == true
    end
  end

  def accept_and_listen
    @client = tcp_server.accept
    @request_lines = []
    while line = @client.gets and !line.chomp.empty?
      @request_lines << line.chomp
    end
    return @request_lines
  end

  def analyze_request
    @verb = @request_lines[0].split[0]
    @path = @request_lines[0].split[1]
    @protocol = @request_lines[0].split[2]
    @host = @request_lines.find {|item| item.include?("Host:")}.split(":")[1].strip
    @port = @request_lines.find {|item| item.include?("Host:")}.split(":")[2]
    @origin = @host
    @accept = @request_lines.find {|item| item.include?("Accept:")}.split[1]
  end

  def output_decider
    @request_counter += 1
    if @path == "/"
      ["Verb: #{@verb}", "Path: #{@path}", "Protocol: #{@protocol}", "Host: #{@host}", "Port: #{@port}", "Origin: #{@origin}", "Accept: #{@accept}"]
    elsif @path == "/hello"
      output = ["Hello, World! (#{@hello_counter})"]
      @hello_counter += 1
      output
    elsif @path == "/favicon.ico"
      @request_counter -= 1
      @body
    elsif @path == "/datetime"
      ["#{Time.now.strftime('%I:%M%p on %A, %B %e, %Y')}"]
    elsif @path == "/shutdown"
      ["Total Requests: #{@request_counter}"]
    elsif @path.include?("path?word=")
      word_game(@path.split("=")[1])
    end
  end

  def respond(body_lines)
    response = "<pre>" + body_lines.join("\n") + "</pre>"
    output = "<html><head></head><body>#{response}</body></html>"
    headers = ["http/1.1 200 ok",
              "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
              "server: ruby",
              "content-type: text/html; charset=iso-8859-1",
              "content-length: #{output.length}\r\n\r\n"].join("\r\n")
    @client.puts headers
    @client.puts output
    @client.close
  end

  def word_game(word_value)
    dictionary = File.open("/usr/share/dict/words", "r").read.split("\n")
    if dictionary.include?(word_value)
      ["#{word_value} is a known word"]
    else
      ["#{word_value} is not a known word"]
    end
  end

end
