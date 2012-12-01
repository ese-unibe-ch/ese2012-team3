# Contains requirements for app and tests
require_relative 'models/passwordcheck'
require_relative 'models/simple_email_client'
require_relative 'models/helpers'
require_relative 'models/localized_message'

require_relative 'models/market/agent'
require_relative 'models/market/item'
require_relative 'models/market/auction'
require_relative 'models/market/organization'
require_relative 'models/market/user'
require_relative 'models/market/comment'
require_relative 'models/market/activity'

require_relative 'models/market/timed_event'
require_relative 'models/market/safe'

include Market

