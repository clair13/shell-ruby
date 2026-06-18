loop do
  $stdout.write("$ ")
  $stdout.flush
  command = gets
  command = command ? command.chomp : ""
  $stdout.puts("#{command}: command not found")
end

