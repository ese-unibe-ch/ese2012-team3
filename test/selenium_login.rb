class BBBLoginTest < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @driver.get("localhost:4567/login")
  end
  
  def teardown
    @driver.quit
  end

  def test_1_wrong_user_name
    element = @driver.find_element :name => "name"
    element.send_keys "lajlfösdjöysdfjaljdksadfjalnjsölaf"
    element = @driver.find_element :name => "password"
    element.send_keys "foo"
    element.submit
    element = @driver.find_element :id => "content"
    assert(element.text.include?("does not exist"), "should give an error!")
  end
  
  def test_2_wrong_password
    element = @driver.find_element :name => "name"
    element.send_keys "selenium"
    element = @driver.find_element :name => "password"
    element.send_keys "foofoofoofoofoofoofoofoo"
    element.submit
    element = @driver.find_element :id => "content"
    assert(element.text.include?("Wrong password"), "should give an error!")
  end
  
  def test_3_register_link
    element = @driver.find_element :id => "no_account_infolink"
    element.click
    element = @driver.find_element :id => "content"
    assert(element.text.include?("Registration"), "should be on the registration page now!")
  end
  
  def test_4_login_works
    element = @driver.find_element :name => "name"
    element.send_keys "selenium"
    element = @driver.find_element :name => "password"
    element.send_keys "TeTeTe23*"
    element.submit
    Selenium::WebDriver::Wait.new(:timeout => 10).until { @driver.find_element(:id => "loggedin") }
    element = @driver.find_element :id => "loggedin"
    assert(element.text.include?("logged in"), "login was not successfull!")
  end
end
