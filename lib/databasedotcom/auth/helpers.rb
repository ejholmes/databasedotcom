module Databasedotcom
  module Auth
    module Helpers

      def databasedotcom_client
        Databasedotcom::Client.new.tap do |client|
          client.instance_url  = databasedotcom_session[:instance_url]
          client.oauth_token   = databasedotcom_session[:oauth_token]
          client.refresh_token = databasedotcom_session[:refresh_token]
        end
      end

      def authenticated?
        databasedotcom_session
      end

      def databasedotcom_session
        request.env['rack.session']['databasedotcom']
      end
      
    end
  end
end
