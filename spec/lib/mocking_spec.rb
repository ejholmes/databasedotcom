require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom do
  before :all do
    Databasedotcom.mock!
    Databasedotcom.fixtures = File.expand_path("../../fixtures/mocks", __FILE__)
  end

  before :each do
    Object.send :remove_const, "Account" if Object.const_defined?("Account")
    Databasedotcom.reset_db! if defined? client
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

      specify { subject.oauth_token.should eq "foobar" }
    end

    describe ".list_sobjects" do
      subject { client.list_sobjects }

      it { should have(2).items }
      it { should be_all { |n| n.should be_a String } }
    end

    describe ".describe_sobject" do
      subject { client.describe_sobject("Account") }

      its(["name"]) { should eq "Account" }
    end

    describe ".create" do
      subject { client.create("Account", "Name" => "foobar") }

      its(:Name) { should eq("foobar") }

      context "the mock db" do
        before do
          client.create("Account", "Name" => "foobar")
        end

        subject { client.send :mock_db }

        its(["Account"]) { should have(1).items }
      end
    end

    describe ".delete" do
      context "the mock db" do
        before do
          record = client.create("Account", "Name" => "foobar")
          client.delete("Account", record.Id)
        end

        subject { client.send :mock_db }

        its(["Account"]) { should have(0).items }
      end
    end

    describe ".find" do
      before do
        @record = client.create("Account", "Name" => "foobar")
      end

      subject { client.find("Account", @record.Id) }

      its(:Id) { should eq @record.Id }
    end

    describe ".query" do
      before do
        @record = client.create("Account", "Name" => "foobar")
      end

      subject { client.query("SELECT Id FROM Account") }

      it { should have(1).items }
    end
  end
end
