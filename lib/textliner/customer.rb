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


      def element_path(id, prefix_options = {}, query_options = nil)
        check_prefix_options(prefix_options)

        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}customer/#{URI.encode_www_form_component(id.to_s)}#{format_extension}#{query_string(query_options)}"

        # super
        # self.class.collection_path(options || prefix_options) #, { conversation_id: conversation_id })
      end

    end

    scope :by_phone_number, ->(phone) {
      {params: { phone_number: phone } }
    }

    def reachable?
      reachable_by_sms?
    end

  end
end

