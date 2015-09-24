require "rexml/document"
require "cgi"


module Rss
  def self.fetch_rss(uri)
    s = UniEnv.download_to_s(uri).read
    #s.gsub!(/&lt;/, '<')
    #s.gsub!(/&gt;/, '>')
    doc = REXML::Document.new(s)
    versions = {}
    doc.elements.each('rss/channel/item') do |e|
      ver = (e.elements['title'].text.strip =~ /\APatch\s+(.+)\Z/)? $1 : ''
      next if ver.empty? or ver[0] == '4'
      desc = CGI.unescapeHTML(e.elements['description'].text)
      editor = (desc =~ /Unity-#{ver}.pkg/)? $& : ''
      assets = (desc =~ /StandardAssets-#{ver}.pkg/)? $& : ''
      next if editor.empty? or assets.empty?
      versions[ver] = [editor, assets]
    end
    versions
  end
end
