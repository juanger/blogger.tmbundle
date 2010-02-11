$LOAD_PATH.unshift "#{ENV["TM_BUNDLE_SUPPORT"]}/vendor/bundler-0.9.3/lib",
                   "#{ENV["TM_BUNDLE_SUPPORT"]}/lib",
                   "#{ENV["TM_SUPPORT_PATH"]}/lib/"
                   
require "bundler"

ENV['BUNDLE_GEMFILE'] = ENV["TM_BUNDLE_PATH"] + "/Gemfile"
begin
  Bundler.setup
rescue Bundler::GemNotFound => e
  require 'bundler/cli'
  puts "Installing dependencies with bundler..."
  Bundler::CLI.start ["install"]
  Bundler.setup
end