require 'socket'
require './lib/path_finder'
require './lib/response'
require 'pry'

class Iterations
  attr_reader :tcp_server, :client
  attr_accessor :hello_counter, :request_counter
  def initialize(port)
    @tcp_server = TCPServer.new(port)
    @hello_counter = 0
    @request_counter = 0
  end

  def start
    loop do
      accept_and_listen
      path_finder = PathFinder.new(@request_lines, self)
      @body = path_finder.output_decider
      Response.new(@body, self).respond
      break if path_finder.path == "/shutdown" || $close == true
    end
  end

  def accept_and_listen
    @client = tcp_server.accept
    @request_lines = []
    while line = @client.gets and !line.chomp.empty?
      @request_lines << line.chomp
    end
  end

end

# Iterations.new(9292).accept_and_listen
