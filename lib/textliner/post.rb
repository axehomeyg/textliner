module Textliner
  class Post < Base

    self.collection_name = "conversation"

    class << self
      def collection_path(prefix_options = {}, query_options = nil)
        # Posts are retrieved from /conversation/uuid.jss, as a nested array
        if conversation_id = query_options&.delete(:conversation_id)
          return element_path(conversation_id, prefix_options, query_options)
        elsif phone_number = query_options&.key?(:phone_number)
          return Textliner::Conversation::collection_path(prefix_options, query_options) 
        end

        super

      end
    end

    def collection_path(options = nil)
      self.class.collection_path(options || prefix_options, { conversation_id: conversation_id })
    end

    belongs_to :conversation, class_name: "textliner/conversation"

    # posts
    formatted do |dsl|
      dsl.decoder do |decoded|
        normalize = ->(post) {
          post
            .merge(
              "id" => post["id"] || post["uuid"],
              "phone_number" => decoded.dig("conversation", "customer", "phone_number"),
              "name" => post.dig("creator", "name"),
              "email" => post.dig("creator", "email"),
              "conversation_id" => (
                post["conversation_id"] ||
                post["conversation_uuid"] ||
                decoded.dig("conversation", "conversation_uuid") ||
                decoded.dig("conversation", "uuid"))
            ) }

        decoded["posts"].nil? ?
          normalize.call(decoded) :
          decoded["posts"].map do |post|
            normalize.call(post)
          end
      end
    end

    def to_json(opts = {})
      self.class.format.encode(
        {comment: comment}, opts)
    end

    scope :by_conversation, ->(id) {
      { params: { conversation_id: id } }
    }

    scope :since, ->(after_uuid) {
      { params: { after_uuid: after_uuid }}
    }

    scope :page, ->(page) { 
      { params: { page: page } }
    }

    scope :by_phone_number, ->(phone) {
      { params: { phone_number: phone } }
    }

  end
end
