require 'json'

class JsonCache
  def initialize filename
    @cache = filename
  end
  
  def write json
    File.open(@cache, 'w') do |f|
      f.write json
    end
  end
  
  def read
    out = nil
    if @cache && File.exists?(@cache)
      File.open(@cache, 'r') do |f|
        out = JSON.parse(f.read)
      end
    end
    out
  end
end
