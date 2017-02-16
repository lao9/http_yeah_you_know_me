require './lib/word_game'
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
    elsif path == "/start_game"
      if server.game_object.game_status
        ["Game has already been started!", server.game_object.determine_verb("GET", "")]
      else
        # start new game
        server.game_object.game_status = true
        ["Good luck!"]
      end
    elsif path == ("/game") && server.game_object.game_status
      server.default_response_num = 301 if verb == "POST"
      server.game_object.determine_verb(verb, server.guess)
      # either making a guess, or getting information
    elsif path.include?("/game?guess=") && server.game_object.game_status
      # post man
      server.default_response_num = 301 if verb == "POST"
      server.game_object.determine_verb(verb, path.split("=")[1])
    elsif (path == ("/game") && !server.game_object.game_status) || (path.include?("/game?guess=") && !server.game_object.game_status)
      ["New game hasn't been started yet!"]
    else
      ["I don't know what you're trying to do!"]
    end
  end

end
