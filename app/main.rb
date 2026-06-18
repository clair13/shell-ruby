loop do
  $stdout.write("$ ")

  command = gets

  command = command ? command.chomp : ""
  $stdout.puts("#{command}: command not found")
end

