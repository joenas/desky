module Desky
  class ExitError < StandardError
    def initialize(msg)
      puts msg
      exit
    end
  end
end