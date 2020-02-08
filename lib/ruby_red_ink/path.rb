module RubyRedInk
  module Path
    PARENT = :PARENT
    RELATIVE_PATH = :RELATIVE_PATH
    ROOT_PATH = :ROOT_PATH

    def self.parse(path_string)
      path_tree = {}
      if path_string.start_with?(".")
        start = RELATIVE_PATH
      else
        start = ROOT_PATH
      end

      path_tree[start] = {}

      elements = path_string.split(".")

      current_pointer = path_tree[start]
      elements.each do |element|
        next if element == ""
        new_path = {}
        if element == "^"
          current_pointer[PARENT] = new_path
        elsif element.start_with?(/\d/)
          current_pointer[Integer(element)] = new_path
        else
          current_pointer[element] = new_path
        end

        current_pointer = new_path
      end

      path_tree
    end
  end
end