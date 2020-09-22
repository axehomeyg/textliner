require 'spec_helper'

RSpec.describe Textliner::Conversation do

  it "list conversations - all for account" do
    mock_textline_request(:list_conversations)

    conversations = Textliner::Conversation.find(:all)

    expect(conversations.length).to eql(1)

    expect(conversations.first.customer.name).to eql("Chuck Finley")

    expect(conversations.first.id).to eql("84a2c56f-6b79-4764-811d-90880e2757b4")
  end

  it "list conversation - all for account, paginated" do
    mock_textline_request(:list_conversations_for_page)

    conversations = Textliner::Conversation.find(:all, params: { page: 3 })

    expect(conversations.length).to eql(1)

    expect(conversations.first.customer.name).to eql("Chuck Finley")

    expect(conversations.first.id).to eql("84a2c56f-6b79-4764-811d-90880e2757b4")

  end
end
