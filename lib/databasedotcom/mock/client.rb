module Databasedotcom
  class Client

    def authenticate(options = nil)
      self.version = "22.0"
      self.oauth_token = "foobar"
    end

    def list_sobjects
      describe_sobjects.collect { |sobject| sobject["name"] }
    end

    def describe_sobjects
      body = File.read(File.join(Databasedotcom.fixtures, 'sobjects.json'))
      JSON.parse(body)["sobjects"]
    end

  end
end
