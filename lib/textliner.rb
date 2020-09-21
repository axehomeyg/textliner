require 'active_resource'
require "textliner/collection"
require "textliner/format"
require "textliner/scope_proxy"
require "textliner/version"

# models
require "textliner/base"
require "textliner/conversation"
require "textliner/customer"
require "textliner/post"

module Textliner
  DEFAULT_MAX_PAGES = 30
  DEFAULT_THROTTLE = 0.2

  class Error < StandardError; end

  class << self
    attr_accessor :max_pages, :throttle

    def access_token=(value)
      Textliner::Base.access_token(value)
    end

    def upto(&block)
      1.upto(max_pages) do |n|
        apply_throttle
        block.call(n)
      end
    end

    def each(finder, &block)
      finder
        .tap do |results|
          return if results.empty?
        end
        .each(&block)
    end

    def apply_throttle
      sleep(throttle) if throttle
    end

    def all_posts(&block)
      upto do |i|
        each(Textliner::Conversation.page(i).find(:all)) do |conversation|
          upto do |j|
            each(Textliner::Post.page(j).by_conversation(conversation.id).find(:all), &block)
          end
        end
      end
    end
  end
end

Textliner.max_pages = Textliner::DEFAULT_MAX_PAGES
Textliner.throttle  = Textliner::DEFAULT_THROTTLE
