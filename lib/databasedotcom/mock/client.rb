module Databasedotcom
  class Client

    def authenticate(options = nil)
      self.version = "22.0"
      self.oauth_token = "foobar"
    end

    def list_sobjects
      body = File.read(File.join(Databasedotcom.fixtures, 'sobjects.json'))
      JSON.parse(body)["sobjects"].collect { |sobject| sobject["name"] }
    end
      
  end
end
