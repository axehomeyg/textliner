require 'spec_helper'

RSpec.describe Textliner::Conversation do
  include TextlinerSpecHelper

  before :each do
    stub_textline!
  end

  it "list conversations - all for account" do
    conversations = Textliner::Conversation.find(:all)

    expect(conversations.length).to eql(1)

    expect(conversations.first.customer.name).to eql("Chuck Finley")

    expect(conversations.first.id).to eql("84a2c56f-6b79-4764-811d-90880e2757b4")
  end

  it "list conversation - all for account, paginated" do
    conversations = Textliner::Conversation.find(:all, params: { page: 3 })

    expect(conversations.length).to eql(1)

    expect(conversations.first.customer.name).to eql("Chuck Finley")

    expect(conversations.first.id).to eql("84a2c56f-6b79-4764-811d-90880e2757b4")

  end
end
