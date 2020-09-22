require 'spec_helper'

RSpec.describe Textliner::Post do
  before :each do
    stub_textline!
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

  describe "scopes" do

    it "supports finding by phone scope" do
      posts = Textliner::Post.by_phone_number("+2222222222").find(:all)

      expect(posts.length).to eql(1)
    end

    it "supports find since without affecting subsequent queries" do
      posts = Textliner::Post.since("latest_id").find(:all, params: {phone_number: "+2222222222"})

      expect(posts.length).to eql(1)

      posts = Textliner::Post.find(:all, params: {conversation_id: "1234"})
    end
    
    it "supports multiple scopes" do
      posts = Textliner::Post
        .since("latest_id")
        .by_phone_number("+2222222222")
        .find(:all)

      expect(posts.length).to eql(1)
    end

  end
end

