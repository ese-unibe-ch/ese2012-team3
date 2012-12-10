# @internal_note Rubymine won't accept this as Ruby file if named password_check !?!

# Ensure a password is "strong".
# Strong as defined by
# http://windows.microsoft.com/en-US/windows-vista/Tips-for-creating-a-strong-password
class PasswordCheck

  # Reads the file containing the top 3000 US english words
  # from http://translateitbangkokpost.blogspot.ch/2010/06/nolls-top-3000-american-english-words.html
  # all lowercase
  def self.read_words_from_CSV
    file = File.new(File.dirname(__FILE__) + "/forbidden_pw_words.csv", "r")
    filecontent = ""
    while (line = file.gets)
      filecontent = filecontent + line.to_s
    end
    file.close
    filecontent.split(';')
  end

  PASSWORD_FORBIDDEN_WORDS = read_words_from_CSV

  # Maybe make return error enumeration instead?
  # Though exception seems fine, can be formatted.
  def self.ensure_password_strong(pw, username, previousPassword)
    fail localized_message_single_key("NO_PASS_AND_USER") unless pw and pw.length > 0 and username and username.length > 0

    fail localized_message_single_key("PNS_NOT_8") if pw.length < 8
    fail localized_message_single_key("PNS_USERNAME") if username.length > 0 and pw.include?(username) # Does not contain your user name, (real name, or company name).

    lpw = pw.downcase

    c = nil
    for w in PASSWORD_FORBIDDEN_WORDS
      c = w if w.length > 2 and lpw.include?(w)   # only test words long than 2 ('we', 'it' allowed)
    end
    fail LocalizedMessage.new([
                                  LocalizedMessage::LangKey.new("PNS_CONTAINS_WORD"),
                                  " '"+c+"'."
                              ]) if c
    # Does not contain a complete word.... use dictionary

    # Don't tell what exactly went wrong: Might give hints about current pw!
    fail localized_message_single_key("PNS_NOT_DIFF") unless previousPassword == nil or previousPassword.length == 0 or significantly_different?(pw, previousPassword)

    # Contains characters from each of the following four categories:
    # http://www.java2s.com/Code/Ruby/String/stringcontainsuppercasecharacters.htm
    fail localized_message_single_key("PNS_NOT_UPPER") unless pw =~ /[A-Z]/
    fail localized_message_single_key("PNS_NOT_LOWER") unless pw =~ /[a-z]/
    fail localized_message_single_key("PNS_NOT_NUMBER")   unless pw =~ /[0-9]/
    fail localized_message_single_key("PNS_NOT_SPECIAL") unless pw =~ /[\`\~\!\@\#\$\%\^\&\*\(\)\_\-\+\=\{\}\[\]\\\|\:\;\"\'\<\>\,\.\?\/\.]/
  end

  # Algorithm: Make sure no block of 3 characters in a is in b
  def self.significantly_different?(a,b)
    a = a.downcase
    b = b.downcase

    for i in 0..(a.length-3)
      s = a.slice(i,3)
      return false if b.include?(s)
    end
    true
  end


end
