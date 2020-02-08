module RubyRedInk
  class Divert
    class UnknownDivert < Error ; end

    attr_accessor :original_object

    def self.parse(original_object)
      if original_object.has_key?("->") && original_object.has_key?("var")
        return VariableTargetDivert.new(original_object)
      end

      if original_object.has_key?("->")
        return StandardDivert.new(original_object)
      end

      if original_object.has_key?("f()")
        return FunctionCallDivert.new(original_object)
      end

      if original_object.has_key?("->t->")
        return TunnelDivert.new(original_object)
      end

      if original_object.has_key?("x()")
        return ExternalFunctionDivert.new(original_object)
      end

      raise UnknownDivert, ""
    end

    def initialize(original_object)
      self.original_object = original_object
    end
  end

  class StandardDivert < Divert
    def target
      original_object["->"]
    end

    def is_conditional?
      original_object["c"] == true
    end
  end

  class VariableTargetDivert < Divert
    def target
      original_object["->"]
    end
  end

  class FunctionCallDivert < Divert
    def target
      original_object["f()"]
    end
  end

  class TunnelDivert < Divert
    def target
      original_object["->t->"]
    end
  end

  class ExternalFunctionDivert < Divert
    def target
      original_object["x()"]
    end

    def number_of_arguments
      original_object["exArgs"]
    end
  end
end