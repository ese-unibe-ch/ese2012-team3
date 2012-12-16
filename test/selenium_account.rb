class GGGAccountTest < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    SeleniumHelperMethods.new.login(@driver, "TeTeTe23*")
    @driver.get("localhost:4567/settings")
  end
  
  def teardown
    @driver.quit
  end

  def test_1_change_password
    element = @driver.find_element :name => "currentpassword"
    element.send_keys "TeTeTe23*"
    element = @driver.find_element :name => "password"
    element.send_keys "Ax1301!3"
    element = @driver.find_element :name => "passwordc"
    element.send_keys "Ax1301!3"
    element.submit
    element = @driver.find_element :id => "passwordchanged"
    assert(element.text.include?("Password changed!"), element.text)
  end
  
end
