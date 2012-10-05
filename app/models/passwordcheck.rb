# Rubymine won't accept this as Ruby file if named password_check !?!

# ensure password is strong
# Strong as defined by
# http://windows.microsoft.com/en-US/windows-vista/Tips-for-creating-a-strong-password
class PasswordCheck

  # Maybe make return error enumeration instead?
  # Though exception seems fine, can be formatted.
  def self.ensure_password_strong(pw, username, previousPassword)
    fail "Password not strong: Is not at least eight characters long (is "+pw.length.to_s+")." if pw.length < 8
    fail "Password not strong: Contains your user name." if username.length > 0 and pw.include?(username) # Does not contain your user name, (real name, or company name).

    lpw = pw.downcase
    @PASSWORD_FORBIDDEN_WORDS = read_words_from_CSV
    c = nil
    for w in @PASSWORD_FORBIDDEN_WORDS
      c = w if w.length > 1 and lpw.include?(w)
    end
    fail "Password not strong: Contains a known word '"+c+"' completely" if c
    # Does not contain a complete word.... use dictionary

    # Don't tell what exactly went wrong: Might give hints about current pw!
    fail "Password not strong: Is not significantly different from previous password." unless previousPassword.length == 0 or significantly_different?(pw, previousPassword)

    # Contains characters from each of the following four categories:
    # http://www.java2s.com/Code/Ruby/String/stringcontainsuppercasecharacters.htm
    fail "Password not strong: Contains no uppercase letters A-Z." unless pw =~ /[A-Z]/
    fail "Password not strong: Contains no lowercase letters a-z." unless pw =~ /[a-z]/
    fail "Password not strong: Contains no numbers letters 0-9."   unless pw =~ /[0-9]/
    fail "Password not strong: Contains no special characters ` ~ ! @ # $ % ^ & * ( ) _ - + = { } [ ] \ | : ; \" ' < > , . ? /." unless pw =~ /[\`\~\!\@\#\$\%\^\&\*\(\)\_\-\+\=\{\}\[\]\\\|\:\;\"\'\<\>\,\.\?\/\.]/
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
end
