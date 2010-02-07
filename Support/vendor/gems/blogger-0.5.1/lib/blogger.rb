require File.dirname(__FILE__)+'/google_auth.rb'
require 'atom/feed' 
require File.dirname(__FILE__)+'/helpers.rb'
module Blogger
  VERSION = '0.5.1'
  class PostingError < StandardError # :nodoc:
  end
  
  # = Formattable
  # This mixin provides a number of formatters to any object with a content method. A large number of
  # formatters are provided to acommodate those who are hosting on servers that limit their gem usage.
  #
  # The available formatters are:
  #
  # [:raw] content is passed directly into the post, with no formatting.
  # [:redcloth] content is parsed as textile (using RedCloth[http://redcloth.org/] gem)
  # [:bluecloth] content is parsed as textile (using BlueCloth[http://www.deveiate.org/projects/BlueCloth] gem)
  # [:rdiscount] content is parsed as markdown (using rdiscount[http://tomayko.com/writings/ruby-markdown-libraries-real-cheap-for-you-two-for-price-of-one] gem)
  # [:peg_markdown] content is parsed as markdown (using peg_markdown[http://tomayko.com/writings/ruby-markdown-libraries-real-cheap-for-you-two-for-price-of-one] gem)
  # [:maruku] content is parsed as markdown (using maruku[http://maruku.rubyforge.org/] gem)
  # [:haml] content is parsed as haml[http://haml.hamptoncatlin.com/]
  
  module Formattable
    # Specifies how the content will be formatted. Can be any of the following:
    #
    # [:raw] content is passed directly into the post
    # [:redcloth] content is parsed as textile (using RedCloth gem)
    # [:bluecloth] content is parsed as textile (using BlueCloth gem)
    # [:rdiscount] content is parsed as markdown (using rdiscount gem)
    # [:peg_markdown] content is parsed as markdown (using peg_markdown gem)
    # [:maruku] content is parsed as markdown (using maruku gem)
    # [:haml] content is parsed as haml
    #
    # Note that these aren't all offered for the hell of it - some people have access to
    # compiled gems, and some don't - some don't even get easy access to new
    # pure Ruby gems on their server
    attr_accessor   :formatter
    
    def format_content #:nodoc:
      send("format_#{@formatter}".to_sym)
    end
    
    def format_raw #:nodoc:
      @content
    end
    
    def format_redcloth #:nodoc:
      require 'redcloth'
      RedCloth.new(@content).to_html
    end
    
    def format_bluecloth #:nodoc:
      require 'bluecloth'
      BlueCloth.new(@content).to_html
    end
    
    def format_rdiscount #:nodoc:
      require 'rdiscount'
      RDiscount.new(@content).to_html
    end
    
    def format_peg_markdown #:nodoc:
      require 'peg_markdown'
      PEGMarkdown.new(@content).to_html
    end
    
    def format_maruku #:nodoc:
      require 'maruku'
      Maruku.new(@content).to_html
    end
    
    def format_haml #:nodoc:
      require 'haml'
      Haml::Engine.new(@content).render
    end
    
    ACCEPTABLE_FORMATTERS = [:raw, :rdiscount, :redcloth, :bluecloth, :peg_markdown, :maruku, :haml]
    
    def formatter=(format)  # :nodoc:
      raise ArgumentError.new("Invalid formatter: #{format.inspect}") unless ACCEPTABLE_FORMATTERS.include?(format)
      @formatter = format
    end
  end
  
  # = Account
  #
  # The Account class is how you interface with your Blogger.com account. You just
  # need to know your username (google email address), password, and blog ID, and
  # you're good to go. 
  #
  # Connect by creating a new Account as such:
  #
  #    account = Blogger::Account.new('username','password')
  #
  # You can make sure you're authenticated by calling account.authenticated?
  #
  # Example usage:
  #
  #    post = Blogger::Post.new(:title => "Sweet post", :categories = ["awesome", "sweet"])
  #    post.draft = true
  #    post.content = "I'll fill this in later"
  #    Blogger::Account.new('username','password').post(blogid,post)
  #
  class Account

    attr_accessor :username
    attr_accessor :password
    attr_accessor :auth_token
    attr_accessor :user_id
    
    # Returns the blogs in this account. pass +true+ to force a reload.
    def blogs(force_reload=false)
      return @blogs if @blogs && !force_reload
      retrieve_blogs
    end
    
    # Returns the blog with the given ID
    def blog_for_id(id)
      blogs.select{|b| b.id.eql? id}.first
    end
    
    # Creates a new Account object, and authenticates if the usename and password are
    # provided.
    def initialize(*args)
      @user_id, @username, @password = args[0], "", ""  if args.size == 1 && args[0] =~ /^[0-9]+$/
      @username, @password           = args[0], args[1] if args.size == 2
      @user_id, @username, @password = args[0], args[1], args[2] if args.size == 3
      authenticate unless @username.empty? || @password.empty?
      self
    end
    
    # Downloads the list of all the user's blogs and stores the relevant information.
    def retrieve_blogs(user_id="")
      NotLoggedInError.new("You aren't logged into Blogger.").raise unless authenticated?
      
      user_id = (user_id.empty?) ? @user_id : user_id
      
      path = "/feeds/#{user_id}/blogs"   
      resp = GoogleAuth.get(path, @auth_token)
      feed = Atom::Feed.parse resp.body
      
      @blogs = []
      feed.entries.each do |entry|
        blog = Blogger::Blog.new(:atom => entry, :account => self)
        @blogs << blog
      end
      @blogs
    end
    
    # Re-authenticates (or authenticates if we didn't provide the user/pass earlier)
    def authenticate(_username = "", _password = "")
      username = (_username.empty?) ? @username : _username
      password = (_password.empty?) ? @password : _password
      
      @auth_token = GoogleAuth::authenticate(username, password)
      @authenticated = !( @auth_token.nil? )
    end
    
    # Are we authenticated successfully? This method won't detect timeouts.
    def authenticated?
      @authenticated
    end
    
    # Posts the provided post to the blog with the given ID. You can find your blog
    # id by going to your blogger dashboard and selecting your blog - you'll find an
    # address such as this in your bar:
    #      http://www.blogger.com/posts.g?blogID=6600774877855692384 <-- your blog id
    #
    # Then just create a Blogger::Post, pass that in as well, and you're done!
    #
    def post(blog_id, post)
      NotLoggedInError.new("You aren't logged into Blogger.").raise unless authenticated?

      path = "/feeds/#{blog_id}/posts/default"
      data = post.to_s
      
      resp = GoogleAuth.post(path, data, @auth_token)
      
      raise Blogger::PostingError.new("Error while posting to blog_id #{blog_id}: #{resp.message}") unless resp.code.eql? '201'
      # Expect resp.code == 200 and resp.message == 'OK' for a successful.
      Post.new(:atom => Atom::Entry.parse(resp.body), :blog => blog_for_id(blog_id)) if @user_id
    end
  end
  
  # = Blog
  # Encapsulates a Blog retrieved from your user account. This class can be used
  # for searching for posts, or for uploading posts via the +post+ method. Blog
  # objects are only safely retrieved via the Blogger::Account class, either via
  # Account#blogs or Account#blog_for_id.
  #
  class Blog
    attr_accessor :title
    attr_accessor :id
    attr_accessor :authors
    attr_accessor :published
    attr_accessor :updated
    attr_accessor :account
    def initialize(opts = {}) #:nodoc:
      entry = opts[:atom]
      @authors = []
      @title = entry.title.html.strip
      @id = $2 if entry.id =~ /tag:blogger\.com,1999:user\-([0-9]+)\.blog\-([0-9]+)$/
      entry.authors.each do |author|
        @authors << author
      end
      @updated = entry.updated
      @published = entry.published
      @account = opts[:account] if opts[:account]
    end
    
    # Uploads the provided post to this blog. Requires that you be logged into your
    # blogger account via the Blogger::Account class.
    def post(post)
      NotLoggedInError.new("You aren't logged into Blogger.").raise unless @account.authenticated?

      path = "/feeds/#{@id}/posts/default"
      data = post.to_s
      
      resp = GoogleAuth.post(path, data, @account.auth_token)
      
      raise Blogger::PostingError.new("Error while posting to blog_id #{@id}: #{resp.message}") unless resp.code.eql? '201'
      post.parse Atom::Entry.parse(resp.body)
    end
    
    def posts(force_reload = false)
      return @posts if @posts && !(force_reload)
      retrieve_posts
    end
    
    # Downloads all the posts for this blog.
    def retrieve_posts
      NotLoggedInError.new("You aren't logged into Blogger.").raise unless @account.authenticated?
      
      path = "/feeds/#{@id}/posts/default"
      
      resp = GoogleAuth.get(path, @account.auth_token)
      
      raise Blogger::RetrievalError.new("Error while retrieving posts for blog id ##{@id}: #{resp.message}") unless resp.code.eql? '200'
      feed = Atom::Feed.parse(resp.body)
      
      @posts = []
      feed.entries.each do |entry|
        @posts << Post.new(:atom => entry, :blog => self)
      end
      @posts
    end
  end
    
  # = Post
  # The post is the representation of a post on your blogger.com blog. It can handle
  # the title, content, categories, and draft status of the post. These are used for
  # uploading posts (just set the information to your liking) or retrieving them
  # (read from the structure)
  #
  # Example:
  #
  #    post = Blogger::Post.new(:title => "Sweet post", :categories = ["awesome", "sweet"])
  #    post.draft = true
  #    post.content = "I'll fill this in later"
  #    Blogger::Account.new('username','password').post(blogid,post)
  #
  class Post
    # the id of the post
    attr_accessor :id #:nodoc:
    # the title of the post
    attr_accessor :title
    # the content of the post
    attr_accessor :content 
    # the categories of the post - array of strings
    attr_accessor :categories 
    # whether or not the post is a draft
    attr_accessor :draft 
    # list of all the comments on this post
    attr_accessor :comments
    # reference to the blog we belong to
    attr_accessor :blog #:nodoc:
    attr_accessor :etag #:nodoc:
    
    # Pass in a hash containing pre-set values if you'd like, including
    #    * :title  -  the title of the post
    #    * :content - the content of the post, either marked up or not
    #    * :categories - a list of categories, or just one string as a category
    #    * :draft - boolean, whether the post is a draft or not
    #    * :formatter - the formatter to use. :raw, :bluecloth, :redcloth, :peg_markdown, :maruku, :haml or :rdiscount
    #    * :blog - the blog this post belongs to
    #
    def initialize(opts = {})
      @categories = []
      if opts[:atom]
        parse opts[:atom]
      else
        opts.each do |key, value|
          next if key =~ /blog/
          instance_variable_set("@#{key}".to_sym, value)
        end
      end
      @blog = opts[:blog]
      @categories = [@categories] unless @categories.is_a? Array
      @formatter = (opts[:formatter]) ? opts[:formatter] : :raw
    end
    
    def parse(entry) #:nodoc:
      @atom = entry
      @full_id = entry.id
      @id = $2 if entry.id =~ /^tag:blogger\.com,1999:blog\-([0-9]+)\.post\-([0-9]+)$/
      @title = entry.title.html.strip
      @content = entry.content.html
      @categories = entry.categories.map {|c| c.term}
      @draft = entry.draft?
      @etag = entry.etag
      self
    end
    
    # Saves any local changes to the post, and submits them to blogger.
    def save
      NotLoggedInError.new("You aren't logged into Blogger.").raise unless @blog.account.authenticated?
      
      update_base_atom(@atom)
      path = "/feeds/#{@blog.id}/posts/default/#{@id}"
      
      data = @atom.to_s.clean_atom_junk
      
      puts path+"\n\n"
      puts data+"\n\n"
      
      
      resp = GoogleAuth.put(path,data,@blog.account.auth_token, @etag)
      
      raise Blogger::PostingError.new("Error while updating post \"#{@title}\": #{resp.message}") unless resp.code.eql? '200'
      
      parse Atom::Entry.parse(resp.body)
    end
    alias_method :push, :save
    
    # Deletes the post from your blog.
    def delete
      NotLoggedInError.new("You aren't logged into Blogger.").raise unless @blog.account.authenticated?
      
      path = "/feeds/#{@blog.id}/posts/default/#{@id}"
      
      resp = GoogleAuth.delete(path,@blog.account.auth_token, @etag)
      
      raise Blogger::PostingError.new("Error while deleting post \"#{@title}\": #{resp.message}") unless resp.code.eql? '200'
      @blog.posts.delete self
      self
    end
    
    def update_base_atom(entry) #:nodoc:
      entry.title = @title
      
      @categories.each do |cat|
        atom_cat = Atom::Category.new
        atom_cat.term = cat
        atom_cat.scheme = 'http://www.blogger.com/atom/ns#'
        entry.categories << atom_cat
      end
      
      content = Atom::Content.new(format_content)
      content.type = 'xhtml'
      entry.content = content
      entry.content.type = 'xhtml'
      
      entry.draft = @draft
      entry
    end
      
    
    # Reloads the post from blogger.com, using ETags for efficiency.
    def reload
      NotLoggedInError.new("You aren't logged into Blogger.").raise unless @blog.account.authenticated?
      
      path = "/feeds/#{@blog.id}/posts/default/#{@id}"
      
      resp = GoogleAuth.get(path, @blog.account.auth_token, @etag)
      
      raise Blogger::RetrievalError.new("Error while reloading post \"#{@title}\": #{resp.message}") unless resp.code.eql?('200') || resp.code.eql?('304')
      unless resp.code.eql? '304'
        parse Atom::Entry.parse(resp.body)
      end
      self
    end
    
    # Returns whether the post is a draft or not
    def draft?
      @draft
    end
    
    # Converts the post to an atom entry in string form. Internally used.
    def to_s
      entry = Atom::Entry.new
      update_base_atom(entry)
      
      entry.to_s
    end
    
    # Uploads this post to the provided blog.
    def post_to(blog)
      blog.post self
    end
    
    include Formattable
    
    def inspect #:nodoc:
      {:title => @title, :content => @content, :categories => @categories, :draft => @draft}.to_yaml
    end
    
    # Submits a comment to this post. You can use 2 methods of submitting your comment:
    #
    #    my_comment = Comment.new(:title => "cool", :content => "I *loved* this post!", :formatter => :rdiscount)
    #    mypost.comment(my_comment)
    #
    # or, more easily
    #
    #    mypost.comment(:title => "cool", :content => "I *loved* this post!", :formatter => :rdiscount)
    #
    # The currently authenticated user will be the comment author. This is a limitation of Blogger (and
    # probably a good one!)
    def comment(*args)
      comm = (args[0].is_a? Blogger::Comment) ? args[0] : Blogger::Comment.new(args[0])
      comm.post = self
      
      NotLoggedInError.new("You aren't logged into Blogger.").raise unless @blog.account.authenticated?

      path = "/feeds/#{@blog.id}/#{@id}/comments/default"
      data = comm.to_s
      
      puts data+"\n\n"
      
      resp = GoogleAuth.post(path, data, @blog.account.auth_token)
      
      raise Blogger::PostingError.new("Error while commenting to post #{@title}: #{resp.message}") unless resp.code.eql? '201'
      comm.parse Atom::Entry.parse(resp.body)
    end
    
    # Returns all comments from the post. Passing +true+ to this method will cause a forced re-download of comments
    def comments(force_download=false)
      return @comments if @comments && !(force_download)
      retrieve_comments
    end
    
    # Downloads all comments from the post, and returns them ass Blogger::Comment objects.
    def retrieve_comments
      NotLoggedInError.new("You aren't logged into Blogger.").raise unless @blog.account.authenticated?
      
      path = "/feeds/#{@blog.id}/#{@id}/comments/default"
      
      resp = GoogleAuth.get(path, @blog.account.auth_token)
      
      raise Blogger::RetrievalError.new("Error while retrieving comments for post id ##{@id}: #{resp.message}") unless resp.code.eql? '200'
      feed = Atom::Feed.parse(resp.body)
      
      @comments = []
      feed.entries.each do |entry|
        @comments << Comment.new(:atom => entry, :post => self)
      end
      @comments
    end
  end
  
  # = Comment
  # Represents a comment on a Blogger blog. Currently, Blogger only supports titles and contents
  # for comments. The currently authenticated user will be used as the poster. To post a comment
  # in response to a blogger post, simply use something like the following:
  #
  #    my_comment = Comment.new(:title => "cool", :content => "I *loved* this post!", :formatter => :rdiscount)
  #    mypost.comment(my_comment)
  #
  # or, more easily
  #
  #    mypost.comment(:title => "cool", :content => "I *loved* this post!", :formatter => :rdiscount)
  #
  class Comment
    # title of the comment
    attr_accessor :title
    # content of the comment, possibly in a markdown/textile format
    attr_accessor :content
    # the blog this comment belongs to (for already posted comments)
    attr_accessor :post
    # the comment's ID (for deletion)
    attr_accessor :id
    
    # Creates a new comment. You can pass the following options:
    #    * :title  -  the title of the comment
    #    * :content - the content of the comment, either marked up or not
    #    * :formatter - the formatter to use. :raw, :bluecloth, :redcloth, :peg_markdown, :maruku, :haml or :rdiscount
    def initialize(opts={})
      if opts[:atom]
        parse(opts[:atom])
      else
        opts.each do |key, value|
          next if key =~ /blog/
          instance_variable_set("@#{key}".to_sym, value)
        end
      end
      @post = opts[:post]
      @formatter = :raw
    end
    
    def parse(atom) #:nodoc:
      @id = $2 if atom.id =~ /^tag:blogger\.com,1999:blog\-([0-9]+)\.post\-([0-9]+)$/
      @title = atom.title
      @content = atom.content
    end
    
    include Formattable
    
    # formats the comment as an atom entry
    def to_s
      entry = Atom::Entry.new
      entry.title = @title

      content = Atom::Content.new(format_content)
      content.type = 'html'
      entry.content = content
      entry.content.type = 'html'

      entry.to_s
    end
    
    # Deletes the comment from your blog.
    def delete
      NotLoggedInError.new("You aren't logged into Blogger.").raise unless @post.blog.account.authenticated?
      
      path = "/feeds/#{@post.blog.id}/#{@post.id}/comments/default/#{@id}"
      
      resp = GoogleAuth.delete(path,@post.blog.account.auth_token, @etag)
      
      raise Blogger::PostingError.new("Error while deleting comment \"#{@title}\": #{resp.message}") unless resp.code.eql? '200'
      @post.comments.delete self
      
      self
    end
    
    # Submits the comment to the provided post. Must be an actual post object, not an ID.
    def post_to(post)
      post.comment(self)
    end
    
    def inspect #:nodoc:
      {:title => @title, :content => @subject}.to_yaml
    end
  end
end
