require 'net/http'
require 'net/https'
class GoogleAuth
  
  class AuthenticationFailedError < StandardError; end
  class NotLoggedInError < StandardError; end
  
  GA_SOURCE = 'beforefilter.blogspot.com-rubypost'
  GA_GOOGLE = 'www.google.com'
  GA_SERVICE = '/accounts/ClientLogin'
  
  def self.authenticate(username, password, print_debug = false)
    http = Net::HTTP.new(GA_GOOGLE, 443)
    http.use_ssl = true
    login_url = GA_SERVICE

    # Setup HTTPS request post data to obtain authentication token.
    data = 'Email=' + username +'&Passwd=' + password + '&source=' + GA_SOURCE + '&service=blogger'
    headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

    # Submit HTTPS post request
    response, data = http.post(login_url, data, headers)
    pp response.inspect if print_debug
    pp data.inspect     if print_debug
    unless response.code.eql? '200' 
      raise AuthenticationFailedError.new("Error during authentication: #{resp.message}")
    else
      data.split("\n").map {|l| l.split("=")}.assoc("Auth")[1]
    end
  end
  
  def self.default_headers(token)
    {
      'Authorization' => 'GoogleLogin auth=' + token,
      'Content-Type' => 'application/atom+xml',
      'GData-Version' => '2'
    }
  end
  
  def self.get(path, token, etag = nil)
    headers = self.default_headers(token)
    headers.merge!('If-None-Match' => "#{etag}") if etag
    
    http = Net::HTTP.new('www.blogger.com')
    
    http.get(path, headers)
  end
  
  
  def self.delete(path, token, etag = nil)
    headers = self.default_headers(token)
    
    http = Net::HTTP.new('www.blogger.com')
    req  = Net::HTTP::Delete.new(path, headers)
    http.request(req)
  end
  
  def self.put(path, data, token, etag = nil)
    headers = self.default_headers(token)
    
    http = Net::HTTP.new('www.blogger.com')
    req  = Net::HTTP::Put.new(path, headers)
    http.request(req, data)
  end
  
  def self.post(path, data, token)
    headers = self.default_headers(token)
    
    http = Net::HTTP.new('www.blogger.com')
    
    http.post(path, data, headers)
  end
  
end