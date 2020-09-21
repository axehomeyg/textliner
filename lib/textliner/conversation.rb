require 'ostruct'
require 'uri'

module Textliner
  class Conversation < Base
    has_one :customer, class_name: "textliner/customer"
    has_many :posts, class_name: "textliner/post"

    scope :page, ->(page) { { params: { page: page } }}
  end
end

