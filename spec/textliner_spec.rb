# RSpec.describe Textliner do
#   it "has a version number" do
#     expect(Textliner::VERSION).not_to be nil
#   end
#
#   it "does something useful" do
#     expect(false).to eq(true)
#   end
# end
#
require 'spec_helper'

RSpec.describe Textliner do
  include TextlinerSpecHelper
  before :each do
    stub_textline!
  end

  describe "Authentication" do

  end

  describe "Conversations" do
    it "list conversations" do
      conversations = Textliner::Conversation.find(:all)

      expect(conversations.length).to eql(1)

      expect(conversations.first.customer.name).to eql("Chuck Finley")

      expect(conversations.first.id).to eql("84a2c56f-6b79-4764-811d-90880e2757b4")
    end

    it "list conversation page" do
      conversations = Textliner::Conversation.find(:all, params: { page: 3 })

      expect(conversations.length).to eql(1)

      expect(conversations.first.customer.name).to eql("Chuck Finley")

      expect(conversations.first.id).to eql("84a2c56f-6b79-4764-811d-90880e2757b4")
 
    end

    it "retrieve conversation" do
      posts = Textliner::Post.find(:all, params: {conversation_id: "1234"})

      expect(posts.length).to eql(1)

      expect(posts.first.phone_number).to eql("(222) 222-2222")

      expect(posts.first.body).to eql("hello world")

      expect(posts.first.conversation_uuid).to eql("84a2c56f-6b79-4764-811d-90880e2757b4")

    end

    it "retrieve conversation page" do
      posts = Textliner::Post.find(:all, params: {conversation_id: "1234", page: "1"})

      expect(posts.length).to eql(1)

      expect(posts.first.phone_number).to eql("(222) 222-2222")

      expect(posts.first.body).to eql("hello world")
    end


    it "retrieve conversation by phone" do
      posts = Textliner::Post.find(:all, params: {phone_number: "+2222222222"})

      expect(posts.length).to eql(1)

      expect(posts.first.phone_number).to eql("(222) 222-2222")

      expect(posts.first.body).to eql("hello world")
    end

  end

  it "List Conversations" do

  end

  describe "Meta Actions" do
    it "retrieves ALL posts" do
      posts = Textliner.all_posts
      expect(posts.length).to eql(1)

      expect(posts.first.phone_number).to eql("(222) 222-2222")
    end
  end
end
