require 'socket'
require 'pry'

tcp_server = TCPServer.new(9292)

counter = 0
hello_counter = 0

loop do
  client = tcp_server.accept
  request_lines = []
  while line = client.gets and !line.chomp.empty?
    request_lines << line.chomp
  end
  binding.pry
  verb = request_lines[0].split(" ")[0]
  path = request_lines[0].split(" ")[1]
  protocol = request_lines[0].split(" ")[2]
  host = request_lines[1].split(" ")[1].split(":")[0]
  port = request_lines[1].split(" ")[1].split(":")[1]
  origin = "127.0.0.1"
  accept = request_lines[5].split(" ")[1]

  if path == "/"
    client.puts "Verb: #{verb}"
    client.puts "Path: #{path}"
    client.puts "Protocol: #{protocol}"
    client.puts "Host: #{host}"
    client.puts "Port: #{port}"
    client.puts "Origin: #{origin}"
    client.puts "Accept: #{accept}"
  elsif path == "/hello"
    client.puts "Hello, World! (#{hello_counter})"
    hello_counter += 1
  elsif path == "/datetime"
    client.puts "#{Time.now.strftime('%H:%M%p on %A, %B %e, %Y')}"
  elsif path == "/shutdown"
    client.puts "Shutdown here. Total Requests: #{counter}"
    break
  elsif path.include?("path?word=")
    word_value = path.split("=")[1]
    dictionary = File.open("/usr/share/dict/words", "r").read.split("\n")
    if dictionary.include?(word_value)
      client.puts("#{word_value} is a known word")
    else
      client.puts("#{word_value} is not a known word")
    end
  end
  counter += 1
  client.close
end

# Why I am incrementng by 0.5...
# http://stackoverflow.com/questions/35550189/why-this-simple-web-server-is-called-even-number-times/35550225
