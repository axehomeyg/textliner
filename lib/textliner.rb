require "textliner/base"
require "textliner/conversation"
require "textliner/customer"
require "textliner/post"
require "textliner/version"

module Textliner
  class Error < StandardError; end
  # Your code goes here...
end

module Textliner
  def self.max_pages ; 30 ; end
  def self.throttle ; 0.2 ; end

  def self.every_page(&block)
    1.upto(self.max_pages, &block)
  end

  def self.to_source_relation
    ['textline', 'message']
  end

  # For full dump
  def self.since(unused_date) ; self.all_posts ; end

  def self.all_posts
    posts = {}
    self.every_page do |i|
      conversations  = Textliner::Conversation.find(:all, params: { page: i })
      break if conversations.empty?
      conversations.each do |conversation|
        sleep Textliner.throttle
        # puts "Conversation: #{conversation.inspect}"
        self.every_page do |j|
          psts = Textliner::Post.find(:all, params: { conversation_id: conversation.id, page: j })

          break if psts.empty?

          psts.each do |post|
            posts[post.id] = post
          end
        end
      end
    end
    posts.values
  end
end

