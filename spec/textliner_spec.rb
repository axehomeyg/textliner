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
end
