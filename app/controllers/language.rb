# A language stores a hash mapping "language-" or "localization keys" to literal strings.
# e.g. {'PRICE' => 'Prix'}
class Language
  #attr_reader :s # the strings
  attr_reader :icon # path to the icon, relative to the PUBLIC_FOLDER, including initial slash/

  # lookup language string
  def [](k)
    return @s[k] if @s.has_key?(k)
    return "<span style='color:red'>#{k} - MISSING TRANS.!</span>"
  end

  def set k,v
    @s[k] = v
  end

  # Loads the language langcode.
  # @param langcode [String] e.g. "en", "de",...
  # @param basefolder [String] a path to a folder containing a subfolder langcode which by itself must contain a file strings.txt
  def initialize(langcode,basefolder)
    basefolder = File.join(basefolder,langcode)
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

    @s["LANGUAGE_CODE"] = langcode # special value
  end

end

# @param basefolder [String] must contain only subfolders which can used to initialize a {Language}
# Loads all LANGUAGES and stores them in the LANGUAGES hash via langcode => Language
# Also loads the categorisations for the language keys used on the admin panel.
def load_languages(basefolder)
  print "loading langs from #{basefolder}\n"
  Dir.entries(basefolder).each {
      |entry|
      print "found entry #{entry}\n"
      next if (entry =='.' || entry == '..')
      e = File.join(basefolder,entry)
      next if !File.directory?(e)

      print "loading lang #{entry} from #{e}\n"
      begin
      LANGUAGES[entry] = Language.new(entry, basefolder)
      rescue  => e
        print "failed to load lang, error: #{e}\n"
      end
  }

  print "Loaded Langs: "
  LANGUAGES.each {| key, value | print key+", " }

  # Load lang key categories
  begin
    text=File.open(basefolder+'/key_categories.txt').read
  rescue
    fail "Failed to load #{basefolder+'/key_categories.txt'}"
    return
  end

  text.gsub!(/\r\n?/, "\n")

  cc = "" # current categroy
  text.each_line do |line|
    line = line.strip
    if line.include?(":")
      cc = line
      KEY_CATEGORIES[cc] = []
    else
      KEY_CATEGORIES[cc].push << line
    end
  end

  print "Loaded lang key categories: "
  KEY_CATEGORIES.each {| key, value | print key+", " }

end
