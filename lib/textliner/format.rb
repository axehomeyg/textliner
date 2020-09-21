module Textliner
  module Format
    def self.included(base)

      class << base
        def decoder(&block)
          self.format = Textliner::Formatter.with_decoder(block)
        end
      end
    end
  end

  module Formatter
    include ActiveResource::Formats::JsonFormat

    extend self

    def self.with_decoder(decoder)
      # we allow each class to define its own decoder
      # to handle inconsistent api response nesting 
      Class
        .new
        .include(self)
        .tap do |klass|
          klass.instance_variable_set("@decoder", decoder)
        end.new
    end

    def decode_json(json)
      ActiveSupport::JSON.decode(json)
    end

    # let's normalize UUID (sometime's its called id, uuid, OBJECT_uuid)
    def push_uuid(data)
      data["id"].blank? &&
        data["uuid"].present? ?
        data.merge("id" => data["uuid"]) :
        data
    end

    def push_uuids(data)
      return if data.nil?

      data.is_a?(Array) ?
        data.map(&method(:push_uuid)) :
        push_uuid(data)
    end

    # empty search comes back with
    # 200 status and { $root : nil }
    def filter_empty(data)
      return if data.nil?

      data.is_a?(Hash) &&
          data.keys.length == 1 &&
          data.values.first.nil? ?
        nil :
        data
    end

    # some responses have the normal railsy nesting
    def unroot(data)
      return if data.nil?

      ActiveResource::Formats
        .remove_root(data)
        .yield_self do |rootless|
        rootless.nil? ?
          nil :
          rootless
      end

    end

    def apply_custom_decoder(data)
      return if data.nil?

      self
        .class
        .instance_variable_get("@decoder")
        .yield_self do |decoder|
          decoder ?
            decoder.call(data) :
            data
      end
    end

    def decode(json)
      push_uuids(
        apply_custom_decoder(
          unroot(
            filter_empty(
              decode_json(json)))))
    end
  end
end
