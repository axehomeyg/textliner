module Textliner

  class Base < ::ActiveResource::Base
    self.site = "https://application.textline.com/api"
    self.include_root_in_json = true
    self.collection_parser = ::Textliner::Collection
    self.format = ::Textliner::Formatter

    include Textliner::ScopeProxy
    include Textliner::Format

    class << self
      def access_token(value)
        # e.g. headers['X-TGP-ACCESS-TOKEN'] = (Rails.application.credentials.textline || {})[:access_token]
        headers['X-TGP-ACCESS-TOKEN'] = value
      end
    end


    def comment_payload
      {}.merge(
        attributes[:comment].present? ?
        { comment: comment } :
        {}
      ).merge(
        attributes[:attachments].present? ?
        { attachments: attachments } :
        {}
      )
    end


  end
end

