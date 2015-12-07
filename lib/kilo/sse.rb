require 'json'

module Kilo
  class SSE
    def initialize io
      @io = io
    end

    def write object, options = {}
      output = options.map do |k,v|
        "#{k}: #{v}"
      end
      output << "data: #{JSON.dump(object)}"
      # Do a single write:
      @io.write output.join("\n") + "\n\n"
    end

    def close
      @io.close
    end
  end
end
