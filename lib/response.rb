require 'pry'

class Response
  attr_reader :server, :output
  def initialize(body_lines, server)
    @output = "<html><head></head><body>" + "<pre>" + body_lines.join("\n") + "</pre>" + "</body></html>"
    @server = server
  end

  def respond(response_num)
    if response_num == 200
      server.client.puts headers_200
    else response_num == 301
      server.client.puts headers_301
    end
    server.client.puts output
    server.client.close
  end

  def headers_200
    ["http/1.1 200 OK",
    "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
    "server: ruby",
    "content-type: text/html; charset=iso-8859-1",
    "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  end

  def headers_301
    ["http/1.1 301 Moved Permanently",
    "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
    "server: ruby",
    "content-type: text/html; charset=iso-8859-1",
    "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  end

# "Location: http://127.0.0.1:" + server.port.to_s + "/game"
# "Location: http:google.com"

end
