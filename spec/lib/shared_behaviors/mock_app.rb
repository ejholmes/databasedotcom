shared_context "mock app" do
  include Rack::Test::Methods

  let(:options)    { {} }
  let(:middleware) { Databasedotcom::Auth::Middleware.new(lambda { |env| [200, {}, []]}, options) }
  let(:mock_app)   { Rack::MockRequest.new(middleware) }
end
