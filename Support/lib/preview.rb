require "#{ENV["TM_BUNDLE_SUPPORT"]}/lib/setup"
require "post"

TextMode = ENV['TM_MODE'].scan(/Post — (.*)/)[0][0]

post = Post.new(ENV['TM_FILEPATH'], TextMode)

puts post.content