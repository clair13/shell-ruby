def find_executable(command)
  ENV["PATH"].split(File::PATH_SEPARATOR).each do |dir|
    path = File.join(dir, command)

    return path if File.file?(path) && File.executable?(path)
  end

  nil
end


loop do
  $stdout.write("$ ")
  $stdout.flush
  input = gets

  break if input.nil?

  parts = input.chomp.split
  next if parts.empty?

  command = parts[0]
  args = parts[1..]

  builtins = ["echo", "exit", "type", "pwd"]

  case command
  when "echo"
    puts args.join(" ")

  when "exit"
    exit(args[0].to_i)
  when "pwd"
    puts Dir.pwd

  when "type"
    target = args[0]

    if builtins.include?(target)
      puts "#{target} is a shell builtin"
    else
      path = find_executable(target)

      if path 
        puts "#{target} is #{path}"
      else
        puts "#{target}: not found"
      end
    end

  else
    path = find_executable(command)

    if path
      system([path, command], *args)
    else
      puts "#{command}: not found"
    end
  end
end

