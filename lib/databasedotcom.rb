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

    def mock_db
      @db ||= begin
        hash = Hash.new

        def hash.<<(obj)
          self[obj.class.sobject_name] ||= []
          self[obj.class.sobject_name] << obj
        end

        def hash.get(id)
          self.each do |key, val|
            val.each do |record|
              return record if record.Id == id
            end
          end
        end

        def hash.delete(id)
          self.each do |key, val|
            val.each do |record|
              val.delete(record) if record.Id == id
            end
          end
        end
        
        hash
      end
    end

    def reset_db!
      @db = nil
    end
  end
end
