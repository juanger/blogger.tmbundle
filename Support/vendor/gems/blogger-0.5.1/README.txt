= blogger

* http://beforefilter.blogspot.com/

== DESCRIPTION:

The Blogger module provides services related to Blogger, and only blogger. The
GData gem is great, but it provides a much lower-level interface to Google's
Blogger API. With the Blogger gem, you have full access to the Blogger API, 
with easy to use classes, and it integrates with 6 different markup/markdown 
gems! What's more, you won't have to muck around with XML.

Sure, XML is easy. But why waste time messing around with it? With just 3 or 4
lines of Blogger.gem code, you'll be able to take a markdown-formatted string
and post it as a blog post, with categories, and comments.

You can also search through all of your comments, old posts, and pretty much
anything you can do at the blogger.com website, you can do with this gem.

== FEATURES/PROBLEMS:

* Full implementation of the Blogger API with simple to use classes
* Support for 6 different markup/markdown gems, some compiled and some pure ruby
* You'll never touch XML!
* ETags not fully respected yet, however


== SYNOPSIS:

If you know your blog_id, then you can use this code:

    require 'rubygems'
    require 'blogger'
    
    account     = Blogger::Account.new("username","password")
    new_post    = Blogger::Post.new(:title      => "New Post", 
                                    :content    => "This is an *awesome* post",
                                    :formatter  => :rdiscount,
                                    :categories => ["coolness", "awesomeness"])
    account.post(blog_id,post)
    
Otherwise, you'll need your username. You can perform

    account  = Blogger::Account.new(user_id,"username","password")
    new_post = Blogger::Post.new(:title => "New Post", 
                                 :content => "This is an *awesome* post")
    accounts.blogs.first.post(new_post)
    
and after that, throw a comment onto your new post:

    new_post.comment(:title     => "New Comment!",
                     :content   => "_freaking_ sweet",
                     :formatter => :bluecloth)

See the docs for different possibilities. The entirety of Google's Blogger API
is implemented.

== REQUIREMENTS:

* atom-utils

== INSTALL:

* sudo gem install blogger --include-dependencies

== LICENSE:

(The MIT License)

Copyright (c) 2009 Michael J. Edgar

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
