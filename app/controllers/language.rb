
class Language
  #attr_reader :s # the strings
  attr_reader :icon # path to the icon, relative to the PUBLIC_FOLDER, including initial slash/


  # lookup language string
  def [](k)
    return @s[k] if @s.has_key?(k)
    return "<span style='color:red'>#{k} - MISSING TRANS.!</span>"
  end

  def initialize(basefolder)
    @icon = basefolder[PUBLIC_FOLDER.length..-1] + "/icon.png"
    print "lang icon path: #{@icon}\n"

    begin
    text=File.open(basefolder+'/strings.txt').read
    rescue
    fail "Failed to load #{basefolder+'/strings.txt'}"
    end

    text.gsub!(/\r\n?/, "\n")

    @s = {}
    k = ""
    text.each_line do |line|
      line = line.strip
      if k == ""
        k = line
      else
        value = line
        @s[k] = value
        print "loaded lang key '#{k}' = '#{value}'\n"
        k = ""
      end
    end
  end

end

# @param [String] basefolder
def load_languages(basefolder)
  print "loading langs from #{basefolder}\n"
  Dir.entries(basefolder).each {
      |entry|
      print "found entry #{entry}\n"
      next if (entry =='.' || entry == '..')
      e = File.join(basefolder,entry)
      print "loading lang #{entry} from #{e}\n"
      begin
      LANGUAGES[entry] = Language.new(e)
      rescue  => e
        print "failed to load lang, error: #{e}\n"
      end
  }

  print "Loaded Langs: "
  LANGUAGES.each {| key, value | print key+", " }
end
