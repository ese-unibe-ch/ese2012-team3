class AAARegisterTest < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @driver.get("localhost:4567/register")
  end
  
  def teardown
    @driver.quit
  end

  def test_1_register_no_username
    element = @driver.find_element :name => "password"
    element.send_keys "TeTeTe23*"
    element = @driver.find_element :name => "passwordc"
    element.send_keys "TeTeTe23*"
    element.submit # this automatically finds the submit button
    element = @driver.find_element :id => "content"
    assert(element.text.include?("No username"), "Should display an error message!")
  end
  
  def test_2_register_error_on_pw
    element = @driver.find_element :name => "name"
    element.send_keys "selenium"
    element = @driver.find_element :name => "password"
    element.send_keys "TeTeTe23ç"
    element = @driver.find_element :name => "passwordc"
    element.send_keys "TeTeTe23*"
    element.submit
    element = @driver.find_element :id => "content"
    assert(element.text.include?("Password not strong"), "Should display an error message!")
  end
  
  def test_3_register_works
    element = @driver.find_element :name => "name"
    element.send_keys "selenium"
    element = @driver.find_element :name => "password"
    element.send_keys "TeTeTe23*"
    element = @driver.find_element :name => "passwordc"
    element.send_keys "TeTeTe23*"
    element.submit
    Selenium::WebDriver::Wait.new(:timeout => 10).until { @driver.find_element(:id => "registered") }
    element = @driver.find_element :id => "registered"
    assert(element.text.include?("successfully created"), "Register was not successfull!")
  end

end
