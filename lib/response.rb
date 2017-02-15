require 'pry'

class Response
  attr_reader :server, :output
  def initialize(body_lines, server)
    @output = "<html><head></head><body>" + "<pre>" + body_lines.join("\n") + "</pre>" + "</body></html>"
    @server = server
  end

  def respond
    server.client.puts headers
    server.client.puts output
    server.client.close
  end

  def headers
    ["http/1.1 200 ok",
    "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
    "server: ruby",
    "content-type: text/html; charset=iso-8859-1",
    "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  end

end
