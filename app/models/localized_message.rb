
LOCALIZED_FALLBACKLANGCODE = "en" # This is defined here instead of in app.rb because it is also required in the tests.

# A string literal given in several different languages.
# @see LocalizedLiteral.[]
class LocalizedLiteral
  attr_reader :s # the <tt>Hash</tt> of Language codes ("en", "de",...) to string literals, e.g. {"en" => "Cheese", "de" => "Käse"}

  # @return [String] a localized version of the string this represents.
  # Falls back to LOCALIZED_FALLBACKLANGCODE if not present for requested key - if not even that is available, returns first available
  # Use with @LANGCODE from within views.
  #
  def [](langcode)
    return @s[langcode] if @s.has_key?(langcode)
    return @s[LOCALIZED_FALLBACKLANGCODE] if @s.has_key?(LOCALIZED_FALLBACKLANGCODE)
    return @s.values.first
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

  # @return whether any localised version includes the string given
  # @internal_note Is this still needed?
  def include? string
    return @s.values.join(" ").include? string
  end

  # @return whether any localised version includes the string given, comparison ignores case
  def include_i? string
    return @s.values.join(" ").downcase.include?(string.downcase)
  end
end


# A localized message is an ordered list of Strings and {LocalizedMessage#LangKey LangKeys}, e.g. ["John", LangKey("WROTE")]
# Given a {Language}, {LocalizedMessage#to_string} will compile this to e.g. "John wrote", "John schrieb", "John a écrit" etc.
# This allows throwing localised errors in {PasswordCheck} and storing {Activity} messages internally in a language independent format.
class LocalizedMessage < RuntimeError

  # A simple wrapper to mark an element of the array composing
  class LangKey
    attr_reader :s # <tt>String</tt> the key

    # a Language's lookup key (or a literal string for LiteralString)
    def initialize(s)
      @s = s
    end

    # @param lang [Language] the language that knows how to translate this key.
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

  # @param message_ary An array of String and {LangKey} objects, composing a message.
  def initialize(message_ary)
    @message_ary = message_ary
  end

  # Creates a sinlge localised string from this message.
  # @param lang [Language] The language that knows how to translate each LangKey.
  def to_string(lang)
     s = ""
     message_ary.each {|m| s += m.to_string(lang)}
    return s
  end
end

String.class_eval do
  # We overload this to be able to treat all elements in {LocalizedMessage#message_ary} the same way, instead of testing for LangKey type.
  def to_string(lang)
    return self
  end
end

# Shortcut.
# @return a {LocalizedMessage} created with only the key k <tt>LocalizedMessage.new([LocalizedMessage::LangKey.new(k)])</tt>.
# @param k [String] the key
def localized_message_single_key(k)
  return LocalizedMessage.new([LocalizedMessage::LangKey.new(k)])
end
