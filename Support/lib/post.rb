require 'RedCloth'

class Post
  attr_reader :title, :content
  attr_accessor :categories
  
  def initialize(file, format = 'Text')
    @format = format
    parse(file)
  end
  
  private
  
  def parse(file)
    content = open(file).read
    groups = content.scan(/Title:(.*?)\n(.*?)(?:✂------)+\n(.*)/im)
    
    @title = groups[0][0].strip
    @content = format_contents(groups[0][1].strip, groups[0][2].strip)
  end
  
  def format_contents(summary, extended)
    case @format
    when 'Text'
      summary + fullpost(extended)
    when 'Textile'
      RedCloth.new(summary).to_html + fullpost(RedCloth.new(extended).to_html)
    end
  end
  
  def fullpost(text)
    unless text.empty? then "\n<span id=\"fullpost\">\n #{text}\n </span>\n" else '' end
  end
end