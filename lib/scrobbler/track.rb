# Below is an example of how to get the top fans for a track.
# 
#   track = Scrobbler::Track.new('Carrie Underwood', 'Before He Cheats')
#   puts 'Fans'
#   puts "=" * 4
#   track.fans.each { |u| puts u.username }
#   
# Which would output something like:
# 
#   track = Scrobbler::Track.new('Carrie Underwood', 'Before He Cheats')
#   puts 'Fans'
#   puts "=" * 4
#   track.fans.each { |u| puts "(#{u.weight}) #{u.username}" }
# 
#   Fans
#   ====
#   (69163) PimpinRose
#   (7225) selene204
#   (7000) CelestiaLegends
#   (6817) muehllr
#   (5387) Mudley
#   (5368) ilovejohnny1984
#   (5232) MeganIAD
#   (5132) Veric
#   (5097) aeVnar
#   (3390) kristaaan
#   (3239) kelseaowns
#   (2780) syndication
#   (2735) mkumm
#   (2706) Kimmybeebee
#   (2648) skorpcroze
#   (2549) mistergreg
#   (2449) mlmjcace
#   (2302) tiNEey
#   (2169) ajsbabiegirl
module Scrobbler
  class Track < Base
    attr_accessor :artist, :artist_mbid, :name, :mbid, :playcount, :rank, :url, :reach
    attr_accessor :streamable, :album, :album_mbid, :date, :date_uts, :now_playing
    
    # only seems to be used on top tracks for tag
    attr_accessor :count, :thumbnail, :image
    
    # for weekly top tracks
    attr_accessor :chartposition
    
    class << self
      def new_from_xml(xml, doc=nil)
        artist          = xml.at('/artist/name').inner_html if xml.at('/artist/name')
        artist          = xml.at(:artist).inner_html        if artist.nil? && xml.at(:artist)
        name            = xml.at(:name).inner_html          if xml.at(:name)
        t               = Track.new(artist, name)
        t.artist_mbid   = xml.at(:artist)['mbid']           if xml.at(:artist) && xml.at(:artist)['mbid']
        t.artist_mbid   = xml.at('/artist/mbid').inner_html if t.artist_mbid.nil? && xml.at('/artist/mbid')
        t.mbid          = xml.at(:mbid).inner_html          if xml.at(:mbid)
        t.playcount     = xml.at(:playcount).inner_html     if xml.at(:playcount)
        t.chartposition = xml.at(:chartposition).inner_html if xml.at(:chartposition)
        t.rank          = xml['rank'] if xml['rank']
        t.url           = xml.at('/url').inner_html         if xml.at('/url')
        t.streamable    = xml.at('/streamable').inner_html  if xml.at('/streamable')
        t.count         = xml.at('/tagcount').inner_html    if xml.at('/tagcount')
        t.album         = xml.at(:album).inner_html         if xml.at(:album)
        t.album_mbid    = xml.at(:album)['mbid']            if xml.at(:album) && xml.at(:album)['mbid']
        t.date          = Time.parse((xml).at(:date).inner_html)  if xml.at(:date)
        t.date_uts      = xml.at(:date)['uts']              if xml.at(:date) && xml.at(:date)['uts']
        t.thumbnail = xml.at('/image[@size="small"]').inner_html if xml.at('/image[@size="small"]')
        t.image = xml.at('/image[@size="medium"]').inner_html   if xml.at('/image[@size="medium"]')
        t.now_playing = true if xml['nowplaying'] && xml['nowplaying'] == 'true'
        t.now_playing = false unless t.now_playing
        t
      end
    end
    
    def initialize(artist, name)
      raise ArgumentError, "Artist is required" if artist.blank?
      raise ArgumentError, "Name is required" if name.blank?
      @artist = artist
      @name = name
    end
    
    def fans(force=false)
      get_instance2('track.gettopfans', :fans, :user, {'artist'=>@artist, 'track'=>@name}, force)
    end
    
    def tags(force=false)
      get_instance2('track.gettoptags', :tags, :tag, {'artist'=>@artist, 'track'=>@name}, force)
    end
  end
end
