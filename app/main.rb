# TODO: Uncomment the code below to pass the first stage
$stdout.write("$ ")

command = gets

command = command ? command.chomp : ""
$stdout.puts("#{command}: command not found")

