def parse_input(line)
  args = []
  current = ""

  in_single = false
  in_double = false

  i = 0
  while i < line.length
    char = line[i]

    if !in_single && !in_double && char == "\\"
      i += 1
      current << line[i] if i < line.length

    elsif char == "'" && !in_double
      in_single = !in_single

    elsif char == '"' && !in_single
      in_double = !in_double

    elsif (char == " " || char == "\t") && !in_single && !in_double
      unless current.empty?
        args << current
        current = ""
      end

    else
      current << char
    end

    i += 1
  end

  args << current unless current.empty?
  args
end

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

  parts = parse_input(input.chomp)
  next if parts.empty?

  command = parts[0]
  args = parts[1..]

  builtins = ["echo", "exit", "type", "pwd", "cd"]

  case command
  when "echo"
    puts args.join(" ")

  when "exit"
    exit(args[0].to_i)

  when "pwd"
    puts Dir.pwd

  when "cd"
    directory = args[0]

    directory = ENV["HOME"] if directory == "~"

    begin
      Dir.chdir(directory)
    rescue Errno::ENOENT
      puts "cd: #{directory}: No such file or directory"
    end

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

