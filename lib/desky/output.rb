module Desky

  # I dont know if this is better but still
  class Output
    def initialize(result_output = default_output, error_output = default_error)
      @result_output = result_output
      @error_output = error_output
    end

    def result(cmd, result)
      @result_output.call cmd, result
    end

    def error(cmd, error)
      @error_output.call cmd, error
    end

    def exit_error(cmd, message)
      error cmd, message
      exit 1
    end

    alias :output :result

  private
    def default_output
      ->(cmd, result) { puts "#{cmd}: #{result}" }
    end

    def default_error
      ->(cmd, error) { puts "Error: #{cmd} #{error}" }
    end
  end
end