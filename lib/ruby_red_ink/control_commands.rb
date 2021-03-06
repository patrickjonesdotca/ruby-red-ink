module RubyRedInk
  module ControlCommands
    COMMANDS = {
      SEED_RANDOM: "srnd",
      GLUE: "<>",
      BEGIN_LOGICAL_EVALUATION_MODE: "ev",
      END_LOGICAL_EVALUATION_MODE: "/ev",
      MAIN_STORY_OUTPUT: "out",
      POP: "pop",
      TUNNEL_POP: "->->",
      FUNCTION_POP: "~ret",
      DUPLICATE_TOPMOST: "du",
      BEGIN_STRING_EVALUATION_MODE: "str",
      END_STRING_EVALUATION_MODE: "/str",
      NOOP: "nop",
      PUSH_CHOICE_COUNT: "choiceCnt",
      TURNS: "turns",
      VISIT: "visit",
      SEQ: "seq",
      CLONE_THREAD: "thread",
      DONE: "done",
      STORY_END: "end",
      # native functions
      ADDITION: "+",
      SUBTRACTION: "-",
      DIVIDE: "/",
      MULTIPLY: "*",
      MODULO: "%",
      UNARY_NEGATE: "~",
      EQUALS: "==",
      GREATER_THAN: ">",
      LESS_THAN: "<",
      GREATER_THAN_OR_EQUAL_TO: ">=",
      LESS_THAN_OR_EQUAL_TO: "<=",
      NOT_EQUAL: "!=",
      UNARY_NOT: "!",
      AND: "&&",
      OR: "||",
      MIN: "MIN",
      MAX: "MAX",
    }

    LOOKUP = COMMANDS.invert

    def self.is_control_command?(value)
      LOOKUP.has_key?(value)
    end

    def self.get_control_command(value)
      LOOKUP[value]
    end
  end

  module NativeFunctions
    ADDITION = "+"
    SUBTRACTION = "-"
    DIVIDE = "/"
    MULTIPLY = "*"
    MODULO = "%"
    UNARY_NEGATE = "~"
    EQUALS = "=="
    GREATER_THAN = ">"
    LESS_THAN = "<"
    GREATER_THAN_OR_EQUAL_TO = ">="
    LESS_THAN_OR_EQUAL_TO = "<="
    NOT_EQUAL = "!="
    UNARY_NOT = "!"
    AND = "&&"
    OR = "||"
    MIN = "MIN"
    MAX = "MAX"
  end
end