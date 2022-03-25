require 'socket'
host = ARGV[0]
nickname = ARGV[1]
client = TCPSocket.open(host, 2000)
puts 'Connected to chat server, type away!'
puts 'please enter from 1 to 10: '
client.puts nickname
Thread.new do
  while line = client.gets
    puts line.chop
  end
end
 
while input = STDIN.gets.chomp
  if (1..10).include?(input.to_i)
    client.puts input.to_i
  else
    puts 'please enter from 1 to 10: '
  end
end