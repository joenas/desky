module Desky
  # not an irresponsible module
  class ExitError < StandardError
    def initialize(msg)
      #puts msg
      say_status :msg
      exit
    end
  end
end