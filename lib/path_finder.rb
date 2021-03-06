require './lib/word_game'
require './lib/game_paths'
require './lib/guessing_game'
require 'pry'

class PathFinder
  attr_reader :verb, :path, :protocol, :host, :port, :origin, :accept, :server
  def initialize(request_lines, server)
    @verb = request_lines[0].split[0]
    @path = request_lines[0].split[1]
    @protocol = request_lines[0].split[2]
    @host = request_lines.find {|item| item.include?("Host:")}.split(":")[1].strip
    @port = request_lines.find {|item| item.include?("Host:")}.split(":")[2]
    @origin = @host
    @accept = request_lines.find {|item| item.include?("Accept:")}.split[1]
    @server = server
  end

  def output_decider
    server.request_counter += 1
    server.default_response_num = 200
    if path == "/"
      ["Verb: #{verb}", "Path: #{path}", "Protocol: #{protocol}", "Host: #{host}", "Port: #{port}", "Origin: #{origin}", "Accept: #{accept}"]
    elsif path == "/hello"
      output = ["Hello, World! (#{server.hello_counter})"]
      server.hello_counter += 1
      output
    elsif path == "/favicon.ico"
      server.request_counter -= 1
      server.body
    elsif path == "/datetime"
      ["#{Time.now.strftime('%I:%M%p on %A, %B %e, %Y')}"]
    elsif path == "/shutdown"
      ["Total Requests: #{server.request_counter}"]
    elsif path.include?("path?word=")
      WordGame.word_game(path.split("=")[1])
    elsif path.include?("game")
      GamePaths.new(path, verb, server).choose_path
    elsif path == "/force_error"
      server.default_response_num = 500
      ["SystemError"]
    else
      server.default_response_num = 404
      ["I don't know what you're trying to do!"]
    end
  end

end
