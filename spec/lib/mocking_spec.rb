require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom do
  before :all do
    Databasedotcom.mock!
    Databasedotcom.fixtures = File.expand_path('../../fixtures/mocks', __FILE__)
  end

  describe ".mocking?" do
    subject { Databasedotcom.mocking? }
    it { should be_true }
  end

  describe Databasedotcom::Client do
    let(:client) { Databasedotcom::Client.new }
    subject      { client }

    describe ".authenticate" do
      before do
        subject.authenticate
      end

      specify { subject.oauth_token.should eq 'foobar' }
    end

    describe ".list_sobjects" do
      subject { client.list_sobjects }

      it { should be_an Array }
      it { should have(2).items }
      it { should be_all { |n| n.should be_a String } }
    end
  end
end
