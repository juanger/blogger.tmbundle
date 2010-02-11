$LOAD_PATH.unshift "#{ENV["TM_BUNDLE_SUPPORT"]}/vendor/bundler-0.9.3/lib",
                   "#{ENV["TM_BUNDLE_SUPPORT"]}/lib",
                   "#{ENV["TM_SUPPORT_PATH"]}/lib/"
                   
require "bundler"

ENV['BUNDLE_GEMFILE'] = ENV["TM_BUNDLE_PATH"] + "/Gemfile"

class QuietShell
  def say(message="", color=nil, force_new_line=nil)
    # I do nothing
  end
end

begin
  Bundler.setup
rescue Bundler::GemNotFound => e
  require 'UI'
  params = {
    'title' => "Building dependencies", 
    'summary' => "I'm downloading and installing dependencies, please wait…\n",
    'isIndeterminate' => true,
    'progressAnimate' => true
  }
      
  TextMate::UI.dialog('ProgressDialog.nib', params, nil, true) do |dialog|
    Bundler.ui = Bundler::UI::Shell.new(QuietShell.new)
    Gem::DefaultUserInteraction.ui = Bundler::UI::RGProxy.new(Bundler.ui)
    Bundler::Installer.install(Bundler.root, Bundler.definition, {:without => []})
    Bundler.setup
  end
end