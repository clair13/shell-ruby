def parse_input(line)
  args = []
  current = ""

  in_single = false
  in_double = false



  i = 0
  while i < line.length
    char = line[i]

    if char == "\\"
      if in_single
        # Backslash has no special meaning in single quotes.
        current << "\\"

      elsif in_double
        # Inside double quotes, only \" and \\ are special.
        if i + 1 < line.length
          next_char = line[i + 1]

          if next_char == '"' || next_char == "\\"
            current << next_char
            i += 1
          else
            # Keep the backslash literally.
            current << "\\"
          end
        else
          current << "\\"
        end

      else
        # Outside quotes, backslash escapes the next character.
        i += 1
        current << line[i] if i < line.length
      end

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

def with_stream(default_stream, redirect)
  stream = redirect ? File.open(redirect, "w") : default_stream
  yield stream
ensure
  stream.close if redirect && stream
end


loop do
  $stdout.write("$ ")
  $stdout.flush
  input = gets

  break if input.nil?

  parts = parse_input(input.chomp)
  next if parts.empty?

  stdout_redirect = nil
  stderr_redirect = nil

  i = 0
  while i < parts.length
    case parts[i]
    when ">", "1>"
      stdout_redirect = parts[i + 1]
      parts.slice!(i, 2)
    when "2>"
      stderr_redirect = parts[i + 1]
      parts.slice!(i, 2)
    else
      i += 1
    end
  end


  command = parts[0]
  args = parts[1..]

  builtins = ["echo", "exit", "type", "pwd", "cd"]

  case command
  when "echo"
    with_stream($stdout, stdout_redirect) do |out| 
      out.puts args.join(" ")
    end

  when "exit"
    exit(args[0].to_i)

  when "pwd"
    with_stream($stdout, stdout_redirect) do |out|
      out.puts Dir.pwd
    end

  when "cd"
    directory = args[0]

    directory = ENV["HOME"] if directory == "~"

    begin
      Dir.chdir(directory)
    rescue Errno::ENOENT
      with_stream($stderr, stderr_redirect) do |err|
        err.puts "cd: #{directory}: No such file or directory"
      end
    end

  when "type"
    target = args[0]
    with_stream($stdout, stdout_redirect) do |out|
      if builtins.include?(target)
        out.puts "#{target} is a shell builtin"
      else
        path = find_executable(target)

        if path 
          out.puts "#{target} is #{path}"
        else
          out.puts "#{target}: not found"
        end
      end
    end

    else
      path = find_executable(command)

      if path
        options = {}

        options[:out] = stdout_redirect if stdout_redirect
        options[:err] = stderr_redirect if stderr_redirect

        system([path, command], *args, **options)
      else
        puts "#{command}: not found"
      end
    end
  end

puts "DEBUG: cmd=#{command}, args=#{args}, out=#{stdout_redirect}, err=#{stderr_redirect}"
