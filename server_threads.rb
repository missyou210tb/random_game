require 'socket'
# Read a line and strip any newlines
def read_nickname_from(socket)
  if read = socket.gets
    read.chomp
  end
end
def read_line_from(socket)
  if read = socket.gets
    read.chomp
  end
end
def operate_random(nickname_array, nickname_play_game_array, nickname_notification, number_array, info, result, mutex, socket)
  mutex.synchronize do
    if (nickname_play_game_array.size >= 2) && (nickname_play_game_array.sort == nickname_array.sort)
      unless nickname_notification.include?(info[:nickname])
        result[:number] ||= number_array.sample
        if result[:number] == info[:number]
          socket.puts "you win, result is #{info[:number]}\nstart new game\nplease enter from 1 to 10: "
        else
          socket.puts "you lose, result is #{info[:number]}\nstart new game\nplease enter from 1 to 10: "
        end
        info[:number] = nil
        nickname_notification << info[:nickname]
      end
    end
  end
end
Thread.abort_on_exception = true
puts "Starting server on port 2000 with pid #{Process.pid}"
server = TCPServer.open(2000)
mutex = Mutex.new
result = {}
nickname_array = []
nickname_play_game_array = []
number_array = []
nickname_notification = []
result[:number] = nil
loop do
  Thread.new(server.accept) do |socket|
    info = {}
    info[:nickname] = read_nickname_from(socket)
    mutex.synchronize do
      nickname_array << info[:nickname]
    end
    Thread.new do
      loop do
        operate_random(nickname_array, nickname_play_game_array, nickname_notification, number_array, info, result, mutex, socket)
        if (nickname_play_game_array.size >= 2) && (nickname_notification.sort == nickname_play_game_array.sort)
          nickname_play_game_array = []
          number_array = []
          nickname_notification = []
          result[:number] = nil
        end
        sleep 0.2
      end
    end
    while number = read_line_from(socket)
      info[:number] = number
      mutex.synchronize do
        nickname_play_game_array << info[:nickname]
        number_array << number
      end
    end
    puts "Disconnect #{nickname}"
  end
end