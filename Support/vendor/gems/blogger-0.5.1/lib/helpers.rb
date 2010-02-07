require 'atom/feed' 
class ::String
  
  # atom/feed fudges up the atom feed google gives us so we have to manually insert some stuff
  def clean_atom_junk
    str = self
    str = str.sub(/ xmlns/," xmlns:gd='http://schemas.google.com/g/2005' xmlns") unless str =~ /xmlns:gd/
    "<?xml version='1.0' encoding='utf-8'?>" + str.gsub(/ etag='.*?' /," ")
  end
end


module Atom
  GD = "http://schemas.google.com/g/2005"
  class Entry < Atom::Element
    attrb ["gd", Atom::GD], "etag"
  end
end