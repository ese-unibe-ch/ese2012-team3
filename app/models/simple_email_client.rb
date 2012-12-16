
##
# Used in {Auction}.
# Sends E-mail
# Not implemented because not required to be functional.
##
class SimpleEmailClient

  def self.setup
    return self.new()
  end

  ##
  # Sets email address that sends the mail and the password for this email address
  ##
  def initialize()

  end

  ##
  #
  # Sending email from specified email address
  #
  # @param [String] to Receiver of the e-mail
  # @param [String] subject e-mail header
  # @param [String] content text to be send
  #
  ##
  def send_email(to, subject, content)

  end
end



