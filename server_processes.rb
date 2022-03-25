require 'socket'

def operate_random(master_reader, client_writers, nickname_array, nickname_play_game_array, number_array)
  Thread.new do
    while incoming = master_reader.gets
      if incoming.include?(': ')
        nickname, number = incoming.split(': ')
        nickname_play_game_array << nickname
        number_array << number.to_i
      else
        nickname_array << incoming.delete("\n")
      end
      if nickname_play_game_array.size >= 2 && (nickname_play_game_array.sort == nickname_array.sort)
        result = number_array.sample
        client_writers.each do |writer|
          writer.puts "result: #{result}"
        end
        nickname_play_game_array = []
        number_array = []
      end
    end
  end
end
def return_result(info, client_reader, socket)
  Thread.new do
    while result = client_reader.gets
      if info[:number] == result.split(': ')[1].delete("\n")
        socket.puts "you win, result is #{info[:number]}\nstart new game\nplease enter from 1 to 10: "
      else
        socket.puts "you lose, result is #{info[:number]}\nstart new game\nplease enter from 1 to 10: "
      end
      info[:number] = nil
    end
  end
end
def read_nickname_from(socket)
  if read = socket.gets
    read.chomp
  end
end
def read_number_from(socket, info)
  if read = socket.gets
    if info[:number].nil?
      socket.puts "waiting other people"
      read.chomp
    else
      socket.puts "you entered number, please waiting other people"
      info[:number]
    end
  end
end
 
puts 'Starting server on port 2000'
 
server = TCPServer.open(2000)
client_writers = []
nickname_array = []
nickname_play_game_array = []
number_array = []
master_reader, master_writer = IO.pipe
operate_random(master_reader, client_writers, nickname_array, nickname_play_game_array, number_array)
loop do
  while socket = server.accept
    info = {}
    client_reader, client_writer = IO.pipe
    client_writers.push(client_writer)
    fork do
      info[:nickname] = read_nickname_from(socket)
      master_writer.puts "#{info[:nickname]}"
      puts "#{Process.pid}: Accepted connection from #{info[:nickname]}"
      return_result(info, client_reader, socket)
      while number = read_number_from(socket, info)
        if number != info[:number]
          info[:number] = number
          master_writer.puts "#{info[:nickname]}: #{info[:number]}"
        end
      end
      puts "#{Process.pid}: Disconnected #{info[:nickname]}"
    end
  end
end
