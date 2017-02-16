require 'socket'
require './lib/path_finder'
require './lib/response'
require 'pry'

class Iterations
  attr_reader :tcp_server, :client, :body, :guess, :port
  attr_accessor :hello_counter, :request_counter, :game_object, :default_response_num
  def initialize(port)
    @tcp_server = TCPServer.new(port)
    @port = port
    @hello_counter = 0
    @request_counter = 0
    @body = ""
    @guess = ""
    @game_object = GuessingGame.new
    @response_num = 200
  end

  def start
    loop do
      accept_and_listen
      path_finder = PathFinder.new(@request_lines, self)
      @body = path_finder.output_decider
      check_game_status
      Response.new(@body, self).respond(default_response_num)
      break if path_finder.path == "/shutdown" || $close == true
    end
  end

  def accept_and_listen
    @client = tcp_server.accept
    @request_lines = []
    while line = @client.gets and !line.chomp.empty?
      @request_lines << line.chomp
    end
    content_length = @request_lines.find {|item| item.include?("Content-Length:")}
    @guess = @client.read(content_length.split[1].to_i).split("=")[1] if content_length != nil
  end

  def check_game_status
    if @body.include?("Your guess was correct!")
      @game_object = GuessingGame.new
    end
  end

end

#Iterations.new(9292).start
