module Textliner
  VERSION = "0.1.0"
end
# require 'ostruct'
# require 'uri'
#
# module PostJsonFormat 
#   include ActiveResource::Formats::JsonFormat
#   extend self
#   def decode(json)
#     ActiveSupport::JSON
#       .decode(json)
#       .yield_self do |decoded|
#         phone_number = decoded.dig("conversation", "customer", "phone_number")
#
#         decoded["posts"].map do |post|
#           # push phone from convo onto each record
#           post.merge(
#             "id" => post["uuid"],
#             "phone_number" => phone_number,
#             "name" => post.dig("creator", "name"),
#             "email" => post.dig("creator", "email"))
#         end
#       end
#   end
# end
#
# module Textline
#   class Post < Base
#     self.format = PostJsonFormat
#
#     self.collection_name = "conversation"
#     # self.element_name = "conversation"
#
#     belongs_to :conversation, class_name: "textline/conversation"
#
#     class << self
#       def collection_path(prefix_options = {}, query_options = nil)
#         # Posts are retrieved from /conversation/uuid.jss, as a nested array
#         if conversation_id = query_options&.delete(:conversation_id)
#           return element_path(conversation_id, prefix_options, query_options)
#         elsif phone_number = query_options&.key?(:phone_number)
#           return Textline::Conversation::collection_path(prefix_options, query_options) 
#         end
#
#         super
#
#       end
#     end
#
#     def to_flattened
#       {
#         operational_id: uuid,
#         operational_created_at: created_at,
#         conversation_uuid: conversation_uuid,
#         body: body,
#         name: name,
#         email: email
#       }
#     end
#
#     class << self
#       def to_source_relation
#         ['textline', 'conversation']
#       end
#
#       def find_all_by_phone(phone)
#         find(
#           :all,
#           params: {
#             phone_number: phone,
#             access_token: ::Textline::ACCESS_TOKEN
#           })
#       end
#
#       def since(worthless_date)
#         last_uuid = TextMessage
#           .last
#           &.operational_id
#
#         last_uuid ?
#           find( :all, params: { after_uuid: last_uuid }) :
#           find(:all)
#       end
#     end
#   end
# end
