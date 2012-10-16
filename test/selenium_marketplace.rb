class CCCMarketplaceTest < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    SeleniumHelperMethods.new.login(@driver, "TeTeTe23*") 
    @driver.get("localhost:4567/")  
  end
  
  def teardown
    @driver.quit
  end

  def test_1_logged_in
    element = @driver.find_element :id => "content"
    assert(element.text.include?("Logged in as"), "no logged in info!")
  end
  
  def test_2_buy_item
    element = @driver.find_element :css => "form:nth-of-type(1)"
    element.submit
    element = @driver.find_element :css => "div.span10"
    assert(element.text.include?("Item bought!"), "no alert shown!")
  end

end
