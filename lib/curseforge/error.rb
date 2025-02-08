class CurseForge
  class Error < StandardError
    attr_reader :response

    def initialize(response, message)
      super(message)

      @response = response
    end
  end
end