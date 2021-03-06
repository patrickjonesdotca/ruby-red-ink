$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ruby_red_ink"

Bundler.require(:default, :development)

require "minitest/autorun"
require 'pretty_diffs'
require 'json'

def load_json_export(filepath = "test/fixtures/the-intercept.js.json")
  JSON.parse(File.read(filepath, mode: "r:bom|utf-8"))
end

def build_container(object)
  RubyRedInk::Container.new(object)
end

def parse_path(path_string)
  RubyRedInk::Path.parse(path_string)
end