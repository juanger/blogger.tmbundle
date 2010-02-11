require "#{ENV["TM_BUNDLE_SUPPORT"]}/lib/setup"
require "post"

post = Post.new(:content => File.read(ENV['TM_FILEPATH']))

puts post.format_content