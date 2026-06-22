loop do
  $stdout.write("$ ")
  $stdout.flush
  command = gets

  break if command.nil?

  parts = command.strip.split
  next if parts.empty?

  order = parts[0]
  args = parts[1..]

  builtins = ["echo", "exit", "type"]

  case order
  when "echo"
    puts args.join(" ")

  when "exit"
    exit(args[0].to_i)

  when "type"
    target = args[0]

    if builtins.include?(target)
      puts "#{target} is a shell builtin"
    else
      puts "#{target}: not found"
    end

  else
    puts "#{order}: not found"
  end
end

