module RubyRedInk
  class Engine
    attr_accessor :state, :story, :call_stacks, :current_call_stack, :named_container_pool, :output_stream

    def initialize(state, story, call_stack_to_start_from = :root)
      self.state = state
      self.story = story
      build_named_container_pool
      if call_stack_to_start_from == :root
        process_global_declaration
        self.call_stacks = [CallStack.new(story.root.stack, state, self)]
      else
        self.call_stacks = [call_stack_to_start_from]
      end

      self.current_call_stack = call_stacks.first
      self.output_stream = StringIO.new
    end

    def step
      if current_call_stack.nil?
        puts "🙅‍♂️🙅‍♂️🙅‍♂️🙅‍♂️🙅‍♂️ END"
        return nil
      end

      stack_output = current_call_stack.step
      value_from_stack = stack_output[:element]
      self.current_pointer = stack_output[:path]

      case stack_output[:action]
      when :set_randomizer_seed
        state.randomizer_seed = stack_output[:element]
        return step
      when :new_callstack
        new_callstack = CallStack.new(value_from_stack, state, self, current_call_stack.debug_padding + 1)
        call_stacks << new_callstack
        new_callstack.evaluation_stack.rebuild_from_attributes(current_call_stack.evaluation_stack.clone_attributes)
        self.current_call_stack = new_callstack
        return step
      when :clone_thread
        new_callstack = CallStack.new(value_from_stack, state, self, current_call_stack.debug_padding + 1)
        new_callstack.current_stack_index = current_call_stack.current_stack_index
        # Increment this call stack's current_stack_index so that it will resume *after*
        # the thread point upon return
        current_call_stack.current_stack_index += 1
        call_stacks << new_callstack
        self.current_call_stack = new_callstack
        return step
      when :tunnel, :function, :standard_divert
        tunnel_divert = value_from_stack
        target_container = named_container_pool[tunnel_divert.target]
        if target_container.nil?
          target_container = Path.navigate(story.root, current_call_stack.container_stack.container, tunnel_divert.target)
        end
        puts "-----"
        new_callstack = CallStack.new(target_container.stack, state, self, current_call_stack.debug_padding + 1)
        new_callstack.evaluation_stack.rebuild_from_attributes(current_call_stack.evaluation_stack.clone_attributes)
        call_stacks << new_callstack
        self.current_call_stack = new_callstack
        return step
      when :pop_stack
        call_stacks.delete(current_call_stack)
        self.current_call_stack = call_stacks.last
        return step
      when :glue
        # Seeking back 1 character allows us to
        # remove the newline from the stream
        output_stream.seek(-1, IO::SEEK_END)
        return step
      when :noop, :pop
        return step
      when :output
        puts "📌ENGINE OUTPUT: #{value_from_stack}"
        output_stream << value_from_stack
        return step
      when :new_choice_point
        puts "🎯ADD CHOICE (#{value_from_stack.path_when_chosen}) #{value_from_stack}"
        current_choices << value_from_stack
        return step
      when :story_end, :done
        return nil
      end
    end

    def navigate_from(container, path_string)
      Path.navigate(story.root, container, path_string)
    end

    def closest_container_for(container, path_string)
      Path.closest_container(story.root, container, path_string)
    end

    def current_text
      output_stream.rewind
      output_stream.read.gsub(/\n{2,}/,"\n").strip
    end

    def current_pointer=(value)
      state.current_pointer = value
    end

    def current_pointer
      state.current_pointer
    end

    def current_choices
      state.current_choices
    end

    def current_choices=(value)
      state.current_choices = value
    end

    def pick_choice(choice_index)
      picked = current_choices[choice_index]
      raise ArgumentError, "not a valid choice!" if picked.nil?
      rebuild_thread!(picked.thread_at_generation)
      self.current_choices = []
      self.output_stream = StringIO.new

      target_container = named_container_pool[picked.path_when_chosen]
      if target_container.nil?
        target_container = Path.navigate(story.root, current_call_stack.container_stack.container, picked.path_when_chosen)
      end
      puts "✅" * 25
      new_callstack = CallStack.new(target_container.stack, state, self, current_call_stack.debug_padding + 1)
      call_stacks << new_callstack
      self.current_call_stack = new_callstack

      picked
    end

    def rebuild_thread!(thread_attributes)
      new_callstack = CallStack.new(thread_attributes[:container_stack], state, self, 0)
      new_callstack.rebuild_from_attributes(thread_attributes)
      call_stacks << new_callstack
      self.current_call_stack = new_callstack
    end

    def process_global_declaration
      return nil if !story.global_declaration
      global_declaration = story.global_declaration
      self.output_stream = StringIO.new
      self.call_stacks = [CallStack.new(global_declaration.stack, state, self, (current_call_stack.debug_padding + 1 rescue 0))]
      self.current_call_stack = call_stacks.first

      step_value = step

      while !step_value.nil?
        step_value = step
      end
    end

    def build_named_container_pool
      self.named_container_pool = {}

      add_to_named_container_pool(story.root)
    end

    def add_to_named_container_pool(container)
      named_container_pool.merge!(container.all_named_containers)

      container.stack.elements.select{|x| x.is_a?(Container)}.each do |container|
        add_to_named_container_pool(container)
      end
    end
  end
end