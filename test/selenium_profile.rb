class FFFProfileTest < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    SeleniumHelperMethods.new.login(@driver, "TeTeTe23*")
    @driver.get("localhost:4567/profile/35")
  end
  
  def teardown
    @driver.quit
  end

  def test_1_has_item
    element = @driver.find_element :id => "content"
    assert(element.text.include?("foo"), "user should have an item and it should be displayed!")
  end
  
  def test_2_add_item_button
    element = @driver.find_element :id => "new_item_button"
    element.submit
    element = @driver.find_element :tag_name => "h2"
    assert(element.text.include?("Create new item"), "there should be the add item form!")
  end
  
  def test_3_edit_button
    element = @driver.find_element :css => ".edit_item:nth-of-type(1)"
    element.submit
    element = @driver.find_element :id => "content"
    assert(element.text.include?("Edit item"), "wrong redirect!")
  end
  
=begin
  # TODO: WE SHOULD HAVE A WAY TO ADD AN ITEM HERE AND THEN ACTIVATE IT (second form on the page)
  def test_4_activate_item
    element = @driver.find_element :css => "form:nth-of-type(2)"
    element.submit
    element = @driver.find_element :id => "content"
    assert(element.text.include?("Item bought!"), "not showing buy alert!")
  end
  
  # TODO: NOW WE COULD INACTIVATE IT AND CLICK ON EDIT
  def test_5_inactivate_works_shows_edit_click_edit
    element = @driver.find_element :css => "form:nth-of-type(1)"
    element.submit
    element = @driver.find_element :css => "td:nth-of-type(1)"
    assert(element.text.include?("Edit item"), "there is no edit items button")

    element = @driver.find_element :css => "form[action='/item/4/edit']"
    element.submit
    element = @driver.find_element :tag_name => "h1"
    assert(element.text.include?("Edit item"), "not redirected to edit page")
  end
=end
  
  def test_6_add_offer_button
    element = @driver.find_element :id => "new_offer_button"
    element.submit
    element = @driver.find_element :tag_name => "h2"
    assert(element.text.include?("Create new offer"), "there should be the add offer form!")
  end
  
end
