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

    def with_customer(customer_data, &block)
      Textliner::Customer
        .find_or_create_by_phone_number(
          customer_data[:phone_number],
          customer_data)
        .yield_self(&block)
    end

    def with_conversation(customer_data, &block)
      Textliner::Conversation
        .find_by_phone_number(customer_data[:phone_number])
        .yield_self(&block)
    end

    def validate_message_if(condition, message)
      if condition
        raise Textliner::Error.new(message)
      end
    end

    # the main interface for this gem for those that don't want to
    # think of the data model underneath the API
    def message(customer_data, msg, &error_block)
      phone_number = customer_data[:phone_number]

      payload = payload_for(msg)

      with_customer(customer_data) do |customer|
        validate_message_if(!customer, "Customer Creation Failed :: #{customer_data}")
        validate_message_if(!customer.reachable?, "Customer Creation Failed :: #{customer_data}")

        with_conversation(customer_data) do |conversation|
          conversation ?
            Textliner::Post
              .create({
                  conversation_id: conversation.id,
                }.merge(payload)) :
            Textliner::Conversation
              .create({
                  phone_number: phone_number
                }.merge(payload))
        end
      end
    rescue Textliner::Error => e
      if error_block
        error_block.call(e)
      else
        raise e
      end 
    rescue => e
      err = Textliner::Error.new(e)
      if error_block
        error_block.call(err)
      else
        raise err
      end 
    end

    def payload_for(msg)
      if msg.is_a?(String)
        { comment: { body: msg } }
      elsif msg.is_a?(Hash)
        if msg[:attachment] && !msg[:attachment].empty?
          { 
            comment: { body: msg[:body] },
            attachments: [ { url: msg[:attachment] } ]
          }
        else
          { comment: { body: msg[:body] } }
        end
      end
    end
  end
end

Textliner.max_pages = Textliner::DEFAULT_MAX_PAGES
Textliner.throttle  = Textliner::DEFAULT_THROTTLE
