# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{atom-tools}
  s.version = "2.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brendan Taylor"]
  s.date = %q{2009-08-14}
  s.description = %q{atom-tools is an all-in-one Atom library. It parses and builds Atom (RFC 4287) entries and feeds, and manipulates Atom Publishing Protocol (RFC 5023) Collections.

It also comes with a set of commandline utilities for working with AtomPub Collections.

It is not the fastest Ruby Atom library, but it is comprehensive and makes handling extensions to the Atom format very easy.}
  s.email = %q{whateley@gmail.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["COPYING", "README", "Rakefile", "setup.rb", "bin/atom-grep", "bin/atom-post", "bin/atom-purge", "bin/atom-cp", "test/test_constructs.rb", "test/runtests.rb", "test/test_feed.rb", "test/test_protocol.rb", "test/conformance/updated.rb", "test/conformance/xmlnamespace.rb", "test/conformance/title.rb", "test/conformance/order.rb", "test/conformance/xhtmlcontentdiv.rb", "test/test_xml.rb", "test/test_http.rb", "test/test_general.rb", "spec/entry_spec.rb", "spec/ext_spec.rb", "spec/spec_helper.rb", "spec/feed_spec.rb", "spec/fixtures/feed-w-ext.xml", "spec/fixtures/service-w-xhtml-ns.xml", "spec/fixtures/entry-w-ext.xml", "spec/fixtures/service.xml", "spec/fixtures/entry.xml", "spec/service_spec.rb", "lib/atom/cache.rb", "lib/atom/feed.rb", "lib/atom/text.rb", "lib/atom/collection.rb", "lib/atom/service.rb", "lib/atom/entry.rb", "lib/atom/tools.rb", "lib/atom/element.rb", "lib/atom/http.rb"]
  s.homepage = %q{http://github.com/bct/atom-tools/wikis}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ibes}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Tools for working with Atom Entries, Feeds and Collections.}
  s.test_files = ["test/runtests.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
