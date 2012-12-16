class CCCMarketplaceTest < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    SeleniumHelperMethods.new.login(@driver, "TeTeTe23*")  
  end
  
  def teardown
    @driver.quit
  end

  def test_1_logged_in
    element = @driver.find_element :id => "loggedin"
    assert(element.text.include?("Logged in"), "no logged in info!")
  end
  
  def test_2_buy_item
    element = @driver.find_element :tag_name => "button"
    element.submit
    element = @driver.find_element :id => "itembought"
    assert(element.text.include?("Item bought!"), "no alert shown!")
  end

end
