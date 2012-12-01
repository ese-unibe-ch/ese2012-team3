
String.class_eval do
  def to_string(lang)
    return self
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


  attr_reader :message_ary # an array of LangIdentifiers and literalstrings

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