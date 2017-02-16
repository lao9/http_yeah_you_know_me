require './lib/guessing_game'
require 'pry'

class GamePaths
  attr_reader :path, :verb, :server
  def initialize(path, verb, server)
    @path = path
    @verb = verb
    @server = server
  end

  def choose_path
    if path == "/start_game"
      if server.game_object.game_status
        server.default_response_num = 403 if verb == "POST"
        ["Game has already been started!", server.game_object.determine_verb("GET", "")]
      else
        server.default_response_num = 301 if verb == "POST"
        server.game_object.game_status = true
        ["Good luck!"]
      end
    elsif path == ("/game") && server.game_object.game_status
      server.default_response_num = 301 if verb == "POST"
      server.game_object.determine_verb(verb, server.guess)
    elsif path.include?("/game?guess=") && server.game_object.game_status
      server.default_response_num = 301 if verb == "POST"
      server.game_object.determine_verb(verb, path.split("=")[1])
    elsif (path == ("/game") && !server.game_object.game_status) || (path.include?("/game?guess=") && !server.game_object.game_status)
      ["New game hasn't been started yet!"]
    end
  end

end
