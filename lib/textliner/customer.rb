require 'ostruct'
require 'uri'

module CustomerJsonFormat 
  include ActiveResource::Formats::JsonFormat
  extend self
  def decode(json)
    decoded = ActiveSupport::JSON
      .decode(json)

    puts "DECODED: #{decoded.inspect}"

    # decoded.dig("conversation", "customer", "phone_number")
m    decoded["customer"]
      # .map do |post|
      # post["phone_number"] ||= 
  end
end

module Textliner
  class Customer < Base
    self.format = CustomerJsonFormat 

    def to_flattened
      {
        operational_id: uuid,
        operational_created_at: created_at,
        body: body,
        name: creator.name,
        email: creator.email

      }
    end

    # headers['X-TGP-ACCESS-TOKEN '] = Textliner::ACCESS_TOKEN # (Rails.application.credentials.textline || {})[:access_token]
    class << self
      def to_source_relation
        ['textline', 'conversation']
      end

      def find_all_by_phone(phone)
        find(
          :all,
          params: {
            phone_number: phone,
            access_token: ::Textliner::ACCESS_TOKEN
          })
      end

      def since(worthless_date)
        last_uuid = TextMessage
          .last
          &.operational_id

        last_uuid ?
          find( :all, params: { after_uuid: last_uuid }) :
          find(:all)
      end
    end
  end
end

