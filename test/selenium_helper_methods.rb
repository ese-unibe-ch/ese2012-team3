class SeleniumHelperMethods

  def login(driver, pw)
    driver.get("localhost:4567/login")
    element = driver.find_element :name => "username"
    element.send_keys "selenium"
    element = driver.find_element :name => "password"
    element.send_keys pw
    element.submit
  end

end
