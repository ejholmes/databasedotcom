require 'databasedotcom/version'
require 'databasedotcom/core_extensions'
require 'databasedotcom/client'
require 'databasedotcom/sales_force_error'
require 'databasedotcom/collection'
require 'databasedotcom/sobject'
require 'databasedotcom/chatter'


module Databasedotcom
  class << self
    @mocking = false

    def mock!
      @mocking = true
      require 'databasedotcom/mock/client'
      require 'databasedotcom/mock/sobject'
    end

    def mocking?
      @mocking
    end

    def fixtures=(path)
      @fixtures = path
    end

    def fixtures
      @fixtures
    end
  end
end
