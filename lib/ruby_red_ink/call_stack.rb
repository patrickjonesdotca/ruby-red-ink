module RubyRedInk
  class CallStack
    attr_accessor :current_stack_index, :container_stack, :evaluation_stack, :state, :engine

    def initialize(container_stack, state, engine)
      @current_stack_index = 0
      @container_stack = container_stack
      @evaluation_stack = EvaluationStack.new
      @state = state
      @engine = engine

      if container_stack.container.record_visits? && !container_stack.container.count_start_only?
        state.record_visit(container_stack.container.path_string)
      end
    end

    def visits_for_current_container
      state.visits[container_stack.container.path_string]
    end

    def step
      if container_stack.container.record_visits? && container_stack.container.count_start_only?
        if current_stack_index == 0
          state.record_visit(container_stack.container.path_string)
        end
      end

      current_stack_element = container_stack.elements[current_stack_index]
      current_stack_path = container_stack.path_string_for_key(current_stack_index)
      @current_stack_index += 1

      # Process diverts first
      case current_stack_element
      when TunnelDivert
        return {
          action: :tunnel,
          element: current_stack_element,
          path: current_stack_path
        }
      when StandardDivert
        run_divert = true
        if current_stack_element.is_conditional?
          boolean_value = evaluation_stack.pop
          run_divert = false if boolean_value == 0
        end

        if run_divert
          target_element = engine.navigate_from(container_stack.container, current_stack_element.target)

          if target_element.is_a?(Container)
            return new_callstack(target_element.stack, current_stack_element.target)
          else
            current_stack_path = current_stack_element.target
            current_stack_element = target_element
          end
        else
          return noop(current_stack_element, current_stack_path)
        end
      end

      if current_stack_element.is_a?(Container)
        return new_callstack(current_stack_element.stack, current_stack_path)
      end

      if current_stack_element.nil?
        return tunnel_or_function_pop(current_stack_element, current_stack_path)
      end

      output_stream = StringIO.new

      if ControlCommands::COMMANDS.has_key?(current_stack_element)
        case current_stack_element
        when :NOOP
          return noop(current_stack_element, current_stack_path)
        when :POP
          evaluation_stack.pop
          return noop(current_stack_element, current_stack_path)
        when :GLUE
          return glue(current_stack_element, current_stack_path)
        when :DONE, :TUNNEL_POP, :FUNCTION_POP
          return tunnel_or_function_pop(current_stack_element, current_stack_path)
        end

        if current_stack_element == :BEGIN_LOGICAL_EVALUATION_MODE
          # evaluation_stack = EvaluationStack.new

          # self.evaluation_stack << evaluation_stack

          reached_end = false
          items_in_evaluation_stack = []

          while !reached_end
            next_item = container_stack.elements[self.current_stack_index]
            case next_item
            when :END_LOGICAL_EVALUATION_MODE
              reached_end = true
            when :MAIN_STORY_OUTPUT
              output_stream << evaluation_stack.pop
            when :POP
              evaluation_stack.pop
            when :DUPLICATE_TOPMOST
              evaluation_stack.duplicate_topmost
            when :BEGIN_STRING_EVALUATION_MODE
              evaluation_stack.begin_string_evaluation_mode!
            when :END_STRING_EVALUATION_MODE
              evaluation_stack.end_string_evaluation_mode!
            when :NOOP
              next
            when :PUSH_CHOICE_COUNT
              raise NotImplementedError, "not tracking choice counts yet"
            when :PUSH_CHOICE_COUNT
              raise NotImplementedError, "turns not implemented yet"
            when :VISIT
              evaluation_stack.push(visits_for_current_container)
            when :SEQ
              raise NotImplementedError, "sequence count not implemented yet"
            when :CLONE_THREAD
              raise NotImplementedError, "Thread Cloning not done yet"
            when :DONE
              raise NotImplementedError, "EV MODE DONE not imeplemented yet"
            when :STORY_END
              raise NotImplementedError, "EV MODE END not imeplemented yet"
            when :ADDITION
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              evaluation_stack.push(value_2 + value_1)
            when :SUBTRACTION
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              evaluation_stack.push(value_2 - value_1)
            when :DIVIDE
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              result = value_2 / value_1

              result = result.round(6) if result.is_a?(Float)

              evaluation_stack.push(result)
            when :MULTIPLY
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              result = value_2 * value_1

              result = result.round(6) if result.is_a?(Float)

              evaluation_stack.push(result)
            when :MODULO
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              evaluation_stack.push(value_2 % value_1)
            when :UNARY_NEGATE
              value_1 = evaluation_stack.pop

              evaluation_stack.push(~value_1)
            when :EQUALS
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              result = (value_2 == value_1) ? 1 : 0

              evaluation_stack.push(result)
            when :GREATER_THAN
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              result = (value_2 > value_1) ? 1 : 0

              evaluation_stack.push(result)
            when :GREATER_THAN_OR_EQUAL_TO
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              result = (value_2 >= value_1) ? 1 : 0

              evaluation_stack.push(result)
            when :LESS_THAN
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              result = (value_2 < value_1) ? 1 : 0

              evaluation_stack.push(result)
            when :LESS_THAN_OR_EQUAL_TO
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              result = (value_3 <= value_1) ? 1 : 0

              evaluation_stack.push(result)
            when :NOT_EQUAL
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              result = (value_2 != value_1) ? 1 : 0

              evaluation_stack.push(result)
            when :UNARY_NOT
              value_1 = evaluation_stack.pop

              evaluation_stack.push(!value_1)
            when :AND
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              result = (value_2 && value_1) ? 1 : 0

              evaluation_stack.push(result)
            when :OR
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              result = (value_2 || value_2) ? 1 : 0

              evaluation_stack.push(result)
            when :MIN
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              result = [value_1, value_2].min

              evaluation_stack.push(result)
            when :MAX
              value_1 = evaluation_stack.pop
              value_2 = evaluation_stack.pop

              result = [value_1, value_2].max

              evaluation_stack.push(result)
            when GlobalVariableTarget
              state.globals[next_item.name] = evaluation_stack.pop
            when VariableReference
              evaluation_stack.push(state.get_variable_value(next_item.name))
            else
              evaluation_stack.push(next_item)
            end

            self.current_stack_index += 1
          end

          output_stream.rewind
          return {
            action: :output,
            element: output_stream.read,
            path: current_stack_path
          }
        end
      end

      return {
        action: :output,
        element: current_stack_element,
        path: current_stack_path
      }
    end

    def tunnel_or_function_pop(stack_element, path)
      return {
        action: :pop_stack,
        element: stack_element,
        path: path
      }
    end

    def glue(stack_element, path)
      {
        action: :glue,
        element: stack_element,
        path: path
      }
    end
  end

  class EvaluationStack
    include ControlCommands

    attr_accessor :stack, :string_evaluation_mode_stack, :mode

    def initialize
      self.stack = []
      self.string_evaluation_mode_stack = []
      self.mode = :evaluation_mode
    end

    def begin_string_evaluation_mode!
      self.mode = :string_evaluation_mode
    end

    def end_string_evaluation_mode!
      self.mode = :evaluation_mode
      push(string_evaluation_mode_stack.join)
      self.string_evaluation_mode_stack = []
    end

    def string_evaluation_mode?
      self.mode == :string_evaluation_mode
    end

    def push(value)
      # debugger if value.is_a?(StandardDivert)
      if string_evaluation_mode?
        self.string_evaluation_mode_stack.unshift(value)
        puts self.string_evaluation_mode_stack.inspect
      else
        self.stack.unshift(value)
        puts self.stack.inspect
      end
    end

    def pop
      if string_evaluation_mode?
        self.string_evaluation_mode_stack.shift
      else
        self.stack.shift
      end
    end

    def duplicate_topmost
      push(topmost.dup)
    end

    def topmost
      if string_evaluation_mode?
        self.string_evaluation_mode_stack.first
      else
        self.stack.first
      end
    end
  end
end