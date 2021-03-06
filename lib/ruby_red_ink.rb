module RubyRedInk
  class Error < StandardError; end
end

require "ruby_red_ink/version"
require 'ruby_red_ink/path'
require 'ruby_red_ink/container'
require 'ruby_red_ink/container_stack'
require 'ruby_red_ink/control_commands'
require 'ruby_red_ink/values'
require 'ruby_red_ink/divert'
require 'ruby_red_ink/variable_target'
require 'ruby_red_ink/choice_point'
require 'ruby_red_ink/story'
require 'ruby_red_ink/story_state'
require 'ruby_red_ink/engine'
require 'ruby_red_ink/call_stack'