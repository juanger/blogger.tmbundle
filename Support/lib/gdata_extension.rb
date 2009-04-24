module GData
  class Blogger < GData::Base
    attr_writer :blog_id, :entry_id
    
    def metafeed()
      request 'http://www.blogger.com/feeds/default/blogs'
    end
    
    def entry(*args)
      
      title, body, categories = if args.size > 1
        args
      else
        if args.size == 0
          @entry ||= Hpricot(request("/feeds/#{@blog_id}/posts/default/#{@entry_id}"))
          return @entry
        end
        
        args = args[0]
        [args[:title], args[:content], args[:categories]]
      end
      
      x = Builder::XmlMarkup.new :indent => 2
      x.entry 'xmlns' => 'http://www.w3.org/2005/Atom' do
        x.title title, 'type' => 'text'
        x.content 'type' => 'xhtml' do
          x.div 'xmlns' => 'http://www.w3.org/1999/xhtml' do |div|
            div << body
          end
        end
        categories.each do |category|
          x.category :scheme => 'http://www.blogger.com/atom/ns#',:term => category
        end
      end
      
      @entry ||= x
      path = "/feeds/#{@blog_id}/posts/default"
      post(path, entry.target!)
    end
    
  end
end

unless ENV['GDATA_USER']
  puts "You need to set GDATA_USER as your google login.\n" + 
        "Also, ensure that you have installed GData and RedCloth as gems"
  exit
end