require 'spec_helper'

RSpec.describe Textliner do
  describe "ETL Helpers" do
    it "retrieves ALL posts" do
      stub_textline_api!

      mock_textline_request(:list_conversations_for_page)
      mock_textline_request(:retrieve_conversation_for_page)

      posts = []

      Textliner.all_posts do |post| posts << post end

      expect(posts.length).to eql(4)

      expect(posts.first.phone_number).to eql("(222) 222-2222")
    end
  end

  it "supports sending a first time message" do
    # starts with a customer
    #
    # checks for existing  message
    #
    # sends new message to customer

    mock_textline_request(:retrieve_customer_by_phone_error_200)
    mock_textline_request(:conversation_by_phone_error_200)
    mock_textline_request(
      :create_customer_by_phone,
      "{\"customer\":{\"phone_number\":\"missing_but_valid\"}}")

    mock_textline_request(
      :create_conversation_by_phone,
      "{\"phone_number\":\"missing_but_valid\",\"comment\":{\"body\":\"bawdy\"}}")


    phone = "missing_but_valid"

    post = Textliner.message({phone_number: phone}, "bawdy")

    # since this is a full Post, we get back an id for the post
    expect(post.id).to eql("84a2c56f-6b79-4764-811d-90880e2757b4")
  end

  it "supports sending a subsequent message" do
    # starts with a customer
    #
    # checks for existing message
    #
    # sends to existing conversation
    phone = "+2222222222"

    mock_textline_request(:retrieve_customer_by_phone)

    mock_textline_request(:conversation_by_phone)

    mock_textline_request(
      :append_conversation,
      "{\"comment\":{\"body\":\"bawdy\"}}")

    conversation = Textliner.message({phone_number:  phone}, "bawdy")

    # we get back a Conversation, with an initial message
    # we don't get back the Post ID as part of this payload
    expect(conversation.conversation_id).to eql("84a2c56f-6b79-4764-811d-90880e2757b4")
  end

  it "supports sending a message to existing conversation with an attachment" do
    phone = "+2222222222"

    mock_textline_request(:retrieve_customer_by_phone)

    mock_textline_request(:conversation_by_phone)

    mock_textline_request(
      :append_conversation_with_attachment,
      "{\"comment\":{\"body\":\"bawdy\"},\"attachments\":[\"http://www.dwellsocial.com/map.jpg\"]}")

    conversation = Textliner.message({phone_number:  phone}, body: "bawdy", attachment: "http://www.dwellsocial.com/map.jpg")

    expect(conversation.conversation_id).to eql("84a2c56f-6b79-4764-811d-90880e2757b4")
  end

  it "supports sending a message to new conversation with an attachment" do
    mock_textline_request(:retrieve_customer_by_phone_error_200)
    mock_textline_request(:conversation_by_phone_error_200)
    mock_textline_request(
      :create_customer_by_phone,
      "{\"customer\":{\"phone_number\":\"missing_but_valid\"}}")

    mock_textline_request(
      :create_conversation_by_phone_with_attachment,
      "{\"phone_number\":\"missing_but_valid\",\"comment\":{\"body\":\"bawdy\"},\"attachments\":[\"http://www.dwellsocial.com/map.jpg\"]}")

    phone = "missing_but_valid"

    post = Textliner.message({phone_number: phone}, body: "bawdy", attachment: "http://www.dwellsocial.com/map.jpg")

    # since this is a full Post, we get back an id for the post
    expect(post.id).to eql("84a2c56f-6b79-4764-811d-90880e2757b4")
  end

end
