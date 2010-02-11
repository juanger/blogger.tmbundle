require 'blogger'

MODES = {"Text" => :raw, "Textile" => :redcloth}
CurrentMode = ENV['TM_MODE'].match(/Post — (.*)/)[1]

class Post < Blogger::Post
  def initialize(opts={})
    super
    @formatter = MODES[CurrentMode]
  end
  
  private
  
  def parse
    groups = @content.gsub('✂------'*10, "<!more>").scan(/Title:(.*?)\n(.*?)<!more>\n(.*)/im)
    if groups[0]
      @title = groups[0][0].strip
      @content = groups[0][1].strip
      @full = groups[0][2].strip
    else
      match = @content.match(/Title:(.*?)\n(.*)/im)
      @title = match[1]
      @content = match[2]
    end
  end
  
  def format_content #:nodoc:
    parse
    send("format_#{@formatter}".to_sym)
  end
  
  def format_raw #:nodoc:
    @content + @full.to_s
  end
  
  def format_redcloth #:nodoc:
    require 'redcloth'
    full = "\n<span id=\"fullpost\">\n #{RedCloth.new(@full).to_html}\n </span>\n" if @full
    RedCloth.new(@content).to_html + full.to_s
  end

end