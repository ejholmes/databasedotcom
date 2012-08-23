require 'rack'
require 'oauth2'

module Databasedotcom
  module Auth
    class Middleware

      # Our default options
      DEFAULT_OPTIONS =  {
        # Default to debugging off
        :debugging => false,

        # Default endpoint points to production with client_id and
        # client_secret pull from environment variables.
        :endpoints => {
          'login.salesforce.com' => {
            :client_id     => ENV['DATABASEDOTCOM_CLIENT_ID'],
            :client_secret => ENV['DATABASEDOTCOM_CLIENT_SECRET']
          }
        },

        # Default auth params
        :scope     => nil,
        :display   => nil,
        :immediate => nil,
        :prompt    => nil,

        # The url to trigger authentication
        :auth_url => '/auth/salesforce',

        # The url where the provider redirects to after a successful
        # authentication
        :callback_url => '/auth/salesforce/callback'
      }

      def initialize(app, options = {})
        @app = app
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def call(env)
        dup.call!(env)
      end

      def call!(env)
        @env = env
        return authorize if authorization_request?
        return callback if callback_request?
        @app.call(env)
      end

      # Called when a user hits the /auth/salesforce path
      def authorize
        debug 'authorize phase'
        redirect oauth_client.auth_code.authorize_url(auth_params)
      end

      # Called when the app recieves a callback request at
      # /auth/salesforce/callback with the authorization code
      def callback
        debug 'callback phase'
        @token = oauth_client.auth_code.get_token(code, :redirect_uri => redirect_uri)
        authenticated!
        redirect full_host
      end

      # Store stuff in the session
      def authenticated!
        session['databasedotcom'] = {
          :oauth_token   => token.token,
          :refresh_token => token.refresh_token,
          :instance_url  => token.params['instance_url']
        }
      end

      # The authorization code
      def code
        request.params['code']
      end

      # The endpoint to use. If an endpoint param is passed in through the url
      # it will attempt to find and use that endpoint, otherwise it defaults to
      # the first configured endpoint.
      def endpoint
        endpoint = request.params['endpoint']
        @options[:endpoints].each do |key, value|
          endpoint = [key, value] if key == endpoint
        end
        endpoint = nil unless endpoint.is_a?(Array)
        endpoint ? endpoint : @options[:endpoints].first
      end

      def mydomain
        return unless mydomain = request.params['mydomain']
        "https://#{mydomain}"
      end

      # The client_id for the current endpoint
      def client_id
        endpoint[1][:client_id]
      end

      # The client_secret for the current endpoint
      def client_secret
        endpoint[1][:client_secret]
      end

      # URL parameters that get passed to the oauth2 endpoint
      def auth_params
        {}.tap do |params|
          params[:redirect_uri] = redirect_uri
          %w(scope display immediate prompt).each do |param|
            param = param.to_sym
            params[param] = @options[param] if @options[param]
          end
        end
      end

      # Base endpoint for OAuth2 provider
      def site
        "https://#{endpoint[0]}"
      end

      # Where to redirect to after authenticated by the provider
      #
      # Example:
      #   
      #   http://localhost:9292/auth/salesforce/callback
      def redirect_uri
        "#{full_host}#{callback_url}"
      end

      # The token obtained from the authorization code received
      def token
        @token
      end

      def auth_url
        @options[:auth_url]
      end

      def callback_url
        @options[:callback_url]
      end

      # Rack session
      def session
        @env['rack.session'] ||= {}
        @env['rack.session']
      end

      # Retrieve the rack request
      def request
        @request ||= Rack::Request.new(@env)
      end

      # Our OAuth2 client
      def oauth_client
        @oauth_client ||= OAuth2::Client.new client_id, client_secret, {
          :site          => mydomain || site,
          :authorize_url => '/services/oauth2/authorize',
          :token_url     => '/services/oauth2/token'
        }
      end

      # Attempts to retrieve the hostname + port from the environment. If it
      # fails, it attempts to pull the host from the request.
      def full_host
        full_host = ENV['FULL_HOST']
        unless full_host
          full_host = URI.parse(request.url.gsub(/\?.*$/, ''))
          full_host.path = ''
          full_host.query = nil
          full_host.scheme = 'https' if (request.env['HTTP_X_FORWARDED_PROTO'] == 'https')
          full_host = full_host.to_s
        end
        full_host
      end

      # Returns true if the user is attempting to authenticate by hitting
      # the /auth/salesforce path.
      def authorization_request?
        request.path_info =~ %r{^#{auth_url}$}i
      end

      # Returns true if the request is an oauth callback
      def callback_request?
        request.path_info =~ %r{^#{callback_url}$}i
      end

      # Rack::Response object that redirects
      def redirect(url)
        Rack::Response.new.tap do |response|
          response.write("Redirecting")
          response.redirect(url)
          response.finish
        end
      end

      # Returns true if debugging is turned on
      def debugging?
        @options[:debugging]
      end

      # Print message if debugging is turned on
      def debug(message)
        $stdout.puts "#{message}\n" if debugging?
      end

    end
  end
end
