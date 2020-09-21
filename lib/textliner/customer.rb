require 'ostruct'
require 'uri'

module Textliner
  class Customer < Base
    # keyed by phone 
    class << self
      def find_by_phone_number(phone)
        by_phone_number(phone).find(:first)
      end

      def find_or_create_by_phone_number(phone, attrs = {})
        find_by_phone_number(phone) ||
          create(attrs.merge(phone_number: phone))
      end
    end


    scope :by_phone_number, ->(phone) {
      {params: { phone_number: phone } }
    }
  end
end

