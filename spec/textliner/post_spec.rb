require 'spec_helper'

RSpec.describe Textliner::Post do
  
  it "retrieve conversation" do
    mock_textline_request(:retrieve_conversation)

    posts = Textliner::Post.find(:all, params: {conversation_id: "1234"})

    expect(posts.length).to eql(1)

    expect(posts.first.phone_number).to eql("(222) 222-2222")

    expect(posts.first.body).to eql("hello world")

    expect(posts.first.conversation_uuid).to eql("84a2c56f-6b79-4764-811d-90880e2757b4")

  end

  it "retrieve conversation page" do
    mock_textline_request(:retrieve_conversation_for_page)

    posts = Textliner::Post.find(:all, params: {conversation_id: "1234", page: "1"})

    expect(posts.length).to eql(1)

    expect(posts.first.phone_number).to eql("(222) 222-2222")

    expect(posts.first.body).to eql("hello world")
  end


  it "retrieve conversation by phone" do
    mock_textline_request(:conversation_by_phone)

    posts = Textliner::Post.find(:all, params: {phone_number: "+2222222222"})

    expect(posts.length).to eql(1)

    expect(posts.first.phone_number).to eql("(222) 222-2222")

    expect(posts.first.body).to eql("hello world")
  end

  it "supports sending a first time message" do
    # starts with a customer
    #
    # checks for existing  message
    #
    # sends new message to customer
  end

  it "supports sending a subsequent message" do
    # starts with a customer
    #
    # checks for existing message
    #
    # sends to existing conversation
  end

  describe "scopes" do

    it "supports finding by phone scope" do
      mock_textline_request(:conversation_by_phone)

      posts = Textliner::Post.by_phone_number("+2222222222").find(:all)

      expect(posts.length).to eql(1)
    end

    it "supports find since without affecting subsequent queries" do
      mock_textline_request(:conversation_by_phone_since)

      mock_textline_request(:retrieve_conversation)

      posts = Textliner::Post.since("latest_id").find(:all, params: {phone_number: "+2222222222"})

      expect(posts.length).to eql(1)

      posts = Textliner::Post.find(:all, params: {conversation_id: "1234"})
    end
    
    it "supports multiple scopes" do
      mock_textline_request(:conversation_by_phone_since)

      posts = Textliner::Post
        .since("latest_id")
        .by_phone_number("+2222222222")
        .find(:all)

      expect(posts.length).to eql(1)
    end

  end
end

