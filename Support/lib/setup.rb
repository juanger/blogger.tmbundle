$LOAD_PATH.unshift "#{ENV["TM_BUNDLE_SUPPORT"]}/vendor/gems/bundler-0.9.3/lib",
                   "#{ENV["TM_BUNDLE_SUPPORT"]}/lib",
                   "#{ENV["TM_SUPPORT_PATH"]}/lib/"
                   
require "bundler"

ENV['BUNDLE_GEMFILE'] = ENV["TM_BUNDLE_PATH"] + "/Gemfile"
Bundler.setup