class DDDAllUsersTest < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    SeleniumHelperMethods.new.login(@driver, "TeTeTe23*") 
    @driver.get("localhost:4567/all_users")  
  end
  
  def teardown
    @driver.quit
  end

  def test_1_click_on_user
    element = @driver.find_element :css => "td:nth-of-type(2) a:nth-of-type(1)"
    element.click
    element = @driver.find_element :tag_name => "h1"
    assert(element.text.include?("User: John"), "not redirected to user page")
  end
end
