# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{blogger}
  s.version = "0.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael J. Edgar"]
  s.date = %q{2009-03-24}
  s.description = %q{The Blogger module provides services related to Blogger, and only blogger. The GData gem is great, but it provides a much lower-level interface to Google's Blogger API. With the Blogger gem, you have full access to the Blogger API,  with easy to use classes, and it integrates with 6 different markup/markdown  gems! What's more, you won't have to muck around with XML.  Sure, XML is easy. But why waste time messing around with it? With just 3 or 4 lines of Blogger.gem code, you'll be able to take a markdown-formatted string and post it as a blog post, with categories, and comments.  You can also search through all of your comments, old posts, and pretty much anything you can do at the blogger.com website, you can do with this gem.}
  s.email = ["edgar@triqweb.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/blogger.rb", "lib/google_auth.rb", "lib/helpers.rb", "test/test_blogger.rb"]
  s.homepage = %q{http://beforefilter.blogspot.com/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{blogger}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{The Blogger module provides services related to Blogger, and only blogger}
  s.test_files = ["test/test_blogger.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<atom-tools>, [">= 2.0.1"])
      s.add_development_dependency(%q<hoe>, [">= 1.11.0"])
    else
      s.add_dependency(%q<atom-tools>, [">= 2.0.1"])
      s.add_dependency(%q<hoe>, [">= 1.11.0"])
    end
  else
    s.add_dependency(%q<atom-tools>, [">= 2.0.1"])
    s.add_dependency(%q<hoe>, [">= 1.11.0"])
  end
end
