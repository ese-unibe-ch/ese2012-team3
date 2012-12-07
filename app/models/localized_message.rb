
String.class_eval do
  def to_string(lang)
    return self
  end
end

LOCALIZED_FALLBACKLANGCODE = "en"

class LocalizedLiteral
  attr_reader :s

  # Returns a localized version of the string this represents.
  # Falls back to LOCALIZED_FALLBACKLANGCODE if not present for requested key - if not even that is available, returns first available
  # @LANGCODE => string
  def [](langcode)
    return @s[langcode] if @s.has_key?(langcode)
    return @s[LOCALIZED_FALLBACKLANGCODE] if @s.has_key?(LOCALIZED_FALLBACKLANGCODE)
    return @s.first_value
  end

  def initialize(hash_langcode_to_string)
    @s = hash_langcode_to_string
  end

  def to_string(lang)
    return self[lang["LANGUAGE_CODE"]]
  end

  def defined_for_langcode? langcode
    @s.has_key?(langcode)
  end

  def set langcode,s
    @s[langcode]=s
  end

  def include? string
    return @s.values.join(" ").include? string
  end
end


class LocalizedMessage < RuntimeError # allows throwing localised errors

  class LangKey
    attr_reader :s

    # a Language's lookup key (or a literal string for LiteralString)
    def initialize(s)
      @s = s
    end

    def to_string(lang)
      return lang[s]
    end
  end

     # use string
  #class Literal < LangKey
   # def initialize(s)
    #  @s = s
    #end

    #def to_string(lang)
    #  return s
    #end
  #end


  attr_reader :message_ary # an array of LangIdentifiers, Strings and LocalizedLiterals

  def initialize(message_ary)
    @message_ary = message_ary

  end

  def to_string(lang)
     s = ""
     message_ary.each {|m| s += m.to_string(lang)}
    return s
  end
end


def localized_message_single_key(k)
  return LocalizedMessage.new([LocalizedMessage::LangKey.new(k)])
end