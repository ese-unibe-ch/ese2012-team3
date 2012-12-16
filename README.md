ese2012-team3
=============

See [our wiki](https://github.com/ese-unibe-ch/ese2012-team3/wiki) for more information.

To run:

* Simply run `ruby app/app.rb` (current directory doesn't matter). 
* Then access under http://localhost:4567 (you can specify another port via the [Sinatra commandline options](http://www.sinatrarb.com/intro.html#Command%20Line))
* There are usernames "ese" (member of "The ESE Org"), "John" (member of "UNO"), "Jack" with password "Ax1301!3" set up for testing.

* Access the admin panel under http://localhost:4567/admin The credentials are "admin", "password"

* View the code documentation: `gem install yard`, `yard server --reload` (from within this folder), http://localhost:8808 

To test: 

* Simply run `ruby test/tests.rb` (current directory doesn't matter).
* Run the UI tests with `ruby test/selenium.rb`

## Requirements 
* Ruby (Version 1.8.7 or later, but some gems might not be available for versions > 1.8.7)
* [Devkit](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit) (only when developing using this source code, not for production)
* `gem install bundler`
* `bundle install`

## License

* Uses [Bootstrap](http://twitter.github.com/bootstrap/)
* [flag icons by FAMFAMFAM](http://www.famfamfam.com/lab/icons/flags/)