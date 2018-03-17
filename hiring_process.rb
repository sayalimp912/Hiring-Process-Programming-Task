class HiringProcess

  COMMANDS = ['DEFINE', 'CREATE', 'ADVANCE', 'DECIDE', 'STATS']

  def initialize(input_file_name, output_file_name)
    @validation_errors = []
    @stages = []
    @applicant_info = {}
    @output = '';
    @input_file_name = input_file_name
    @output_file_name = output_file_name
  end

  def start_hiring
    File.open(@input_file_name, "r") do |input_file|
      input_file.each_line do |line|
        response = process_line(line)
        write_output(response)
      end
    end
    write_to_file()
    puts "Hiring Complete. Please check #{@output_file_name}"
  end

  protected

  def process_line(line)
    if valid_line?(line)
      cmd = line.split(' ')
      return process_cmd(cmd)
    else
      return "Command not found for #{line}"
    end
  end

  def valid_line?(line)
    cmd_keyword = line.split(' ')[0]
    COMMANDS.include?(cmd_keyword)
  end

  def process_cmd(cmd)
    return case cmd[0]
      when 'DEFINE' then define_cmd(cmd)
      when 'CREATE' then create_cmd(cmd)
      when 'ADVANCE' then advance_cmd(cmd)
      when 'DECIDE' then decide_cmd(cmd)
      when 'STATS' then stats_cmd(cmd)
    end
  end

  def wrap_error(cmd, msg = '')
    "Error: Command #{cmd.join(' ')} is invalid. #{msg}"
  end

  def is_email(str)
    str.match(/\A[^@]+@([^@\.]+\.)+[^@\.]+\z/) != nil
  end

  def is_at_last_stage(applicant)
    @applicant_info[applicant] == @stages.count - 1
  end

  def write_output(op)
    if op.kind_of?(Array)
      @output += op.join(' ') + "\n"
    else
      @output += op+ "\n"
    end
  end

  def write_to_file()
    File.open(@output_file_name, 'w') do |output_file|
      output_file.write(@output)
    end
  end

  def define_cmd(cmd)
    return wrap_error(cmd) if (cmd.length <= 1)
    cmd[1..-1].each{ |stage| @stages.push(stage) }
    return cmd
  end

  def create_cmd(cmd)
    return wrap_error(cmd) if (cmd.length != 2)
    return wrap_error(cmd, "Email is invalid.") if (!is_email(cmd[1]))

    applicant_email = cmd[1]
    if @applicant_info.key?(applicant_email)
      return "Duplicate applicant"
    else
      @applicant_info[applicant_email] = 0
      return cmd
    end
  end

  def advance_cmd(cmd)
    return wrap_error(cmd) unless cmd.length == 2 || cmd.length == 3
    return wrap_error(cmd, "Email does not exist in database.") if (!@applicant_info.key?(cmd[1]))

    applicant_stage = @applicant_info[cmd[1]]
    next_stage = (cmd.length == 2) ? applicant_stage + 1 : @stages.find_index(cmd[2])

    if (@applicant_info[cmd[1]] == next_stage || next_stage >= @stages.length )
      return "Already in #{@stages[applicant_stage]}"
    else
      @applicant_info[cmd[1]] = next_stage
      return cmd
    end
  end

  def decide_cmd(cmd)
    return wrap_error(cmd) unless cmd.length == 3
    return wrap_error(cmd, "Email does not exist in database.") unless @applicant_info.key?(cmd[1])

    if cmd[2] == "0"
      @applicant_info[cmd[1]] = "R"
      return "Rejected #{cmd[1]}"
    elsif cmd[2] == "1" && is_at_last_stage(cmd[1])
      @applicant_info[cmd[1]] = "H"
      return "Hired #{cmd[1]}"
    else
      return "Failed to decide for #{cmd[1]}"
    end
  end

  def stats_cmd(cmd)
    return wrap_error(cmd) unless cmd.length == 1

    response = ''
    applicants_in_stages = Array.new(@stages.length, 0)
    @applicant_info.each do |k, v|
      applicants_in_stages[v] += 1 if(v != "H" && v != "R")
    end
    applicants_in_stages.each_with_index do |k, i|
      response += "#{@stages[i]} #{k} "
    end
    hired_count = @applicant_info.select {|k, v| v == "H"}.count
    reject_count = @applicant_info.select {|k, v| v == "R"}.count
    response += "Hired #{hired_count} Rejected #{reject_count}"
    return response
  end

end

process = HiringProcess.new('input.txt', 'output.txt')
process.start_hiring