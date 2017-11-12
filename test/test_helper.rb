$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "minitest/autorun"
require "minidbc"
require "shoulda/context"
require "minitest/reporters"
require "byebug"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter. new # spec-like progress

