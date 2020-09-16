require 'ostruct'
require 'uri'

module ConversationJsonFormat 
  include ActiveResource::Formats::JsonFormat
  extend self
  def decode(json)
    decoded = ActiveSupport::JSON.decode(json)

    decoded["conversations"]
      .map do |conversation|
      # push uuid onto each record
      conversation.merge("id" => conversation["uuid"])
    end
  end
end

module Textliner
  class Conversation < Base
    self.format = ConversationJsonFormat

    has_one :customer, class_name: "textliner/customer"
    has_many :posts, class_name: "textliner/post"

    def uuid=(value)
      write_attribute(:uuid, value)
      self.id ||= value
    end
  end
end

