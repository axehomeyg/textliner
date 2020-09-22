require 'ostruct'
require 'uri'

module Textliner
  class Conversation < Base
    class << self
      def find_by_phone_number(phone)
        by_phone_number(phone).find(:first)
      end

      def find_or_create_by_phone_number(phone, attrs = {})
        find_by_phone_number(phone) ||
          create(attrs.merge(phone_number: phone))
      end
    end

    has_one :customer, class_name: "textliner/customer"
    has_many :posts, class_name: "textliner/post"

    scope :page, ->(page) { { params: { page: page } }}

    scope :by_phone_number, ->(phone) {
      {params: { phone_number: phone } }
    }


    formatted do |dsl|
      dsl.decoder do |decoded|
        normalize = ->(conversation) {
          conversation
            .merge(
              "id" => conversation["id"] || conversation["uuid"])
        }

        decoded.is_a?(Array) ?
          decoded.map do |conversation|
            normalize.call(conversation["conversation"] || conversation)
          end :
          normalize.call(decoded["conversation"] || decoded)
      end
    end

    def to_json(opts = {})
      self.class.format.encode(
        attributes
      )
    end
  end
end

