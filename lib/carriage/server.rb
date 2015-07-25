class Carriage
  module Server
    attr_accessor :carriage
    def before_run
      @carriage = Carriage.new
    end
  end
end
