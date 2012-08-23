require 'rspec'
require 'spec_helper'
require 'databasedotcom'
require 'databasedotcom/auth'
require 'rack/test'

describe Databasedotcom::Auth::Middleware do
  include_context "mock app"

  describe "authorization request" do
    let(:response) { mock_app.get '/auth/salesforce' }
    subject { response }

    context "with default options" do
      its(:status) { should eq 302 }
      its(["Location"]) { should =~ %r{https://login.salesforce.com/services/oauth2/authorize.*}}
    end

    context "with an endpoint passed in as a parameter" do
      let(:options)  { { :endpoints => { 'foo.bar.com' => { :client_id => 'foo', :client_secret => 'bar' } } } }
      let(:response) { mock_app.get '/auth/salesforce?endpoint=foo.bar.com' }

      its(:status) { should eq 302 }
      its(["Location"]) { should =~ %r{https://foo.bar.com/services/oauth2/authorize.*}}
    end

    context "with an invalid endpoint passed in as a parameter" do
      let(:response) { mock_app.get '/auth/salesforce?endpoint=foo.bar.com' }

      its(:status) { should eq 302 }
      its(["Location"]) { should =~ %r{https://login.salesforce.com/services/oauth2/authorize.*}}
    end

    context "with mydomain passed in as a parameter" do
      let(:response) { mock_app.get '/auth/salesforce?mydomain=foo.my.salesforce.com' }

      its(:status) { should eq 302 }
      its(["Location"]) { should =~ %r{https://foo.my.salesforce.com/services/oauth2/authorize.*}}
    end
  end

  describe "callback request" do
    before do
      stub_request(:post, "https://login.salesforce.com/services/oauth2/token").
       to_return(:status => 200, :body => File.read(File.expand_path('../../../fixtures/oauth/payload.json', __FILE__)), :headers => {'Content-Type' => 'application/json'})
    end

    let(:response) { mock_app.get '/auth/salesforce/callback?code=oauth_code' }
    subject { response }

    context "with default options" do
      its(:status) { should eq 302 }
      its(["Location"]) { should =~ %r{http://example.org} }
    end
  end
end
