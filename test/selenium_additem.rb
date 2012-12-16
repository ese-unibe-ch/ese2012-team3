class EEEAddItemTest < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    SeleniumHelperMethods.new.login(@driver, "TeTeTe23*") 
    @driver.get("localhost:4567/item/create")  
  end
  
  def teardown
    @driver.quit
  end

  def test_1_error_on_price
    element = @driver.find_element :name => "price"
    element.send_keys "1000"
    element.submit
    element = @driver.find_element :id => "content"
    assert(element.text.include?("item must have"), "no error shown!")
  end
  
  def test_2_error_on_name
    element = @driver.find_element :name => "name_0"
    element.send_keys "foo"
    element.submit
    element = @driver.find_element :id => "content"
    assert(element.text.include?("price must"), "no error shown!")
  end
  
  def test_3_add_works
    element = @driver.find_element :name => "name_0"
    element.send_keys "foo"
    element = @driver.find_element :name => "price"
    element.send_keys "100"
    element.submit
    element = @driver.find_element :tag_name => "h2"
    assert(element.text.include?("My profile"), "not redirected to account page!")
  end
end
