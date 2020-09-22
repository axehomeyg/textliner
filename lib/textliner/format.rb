module Textliner
  class FormatDSL
    attr_accessor :enc, :dec

    def encoder(&block)
      self.enc = block
    end

    def decoder(&block)
      self.dec = block
    end

    def formatter
      Textliner::Formatter.with_coders(enc, dec)
    end
  end

  module Format
    def self.included(base)

      class << base

        def formatted(&block)
          self.format = FormatDSL
            .new
            .tap do |format_dsl|
              block.call(format_dsl)
          end.formatter
        end
      end
    end
  end

  module Formatter
    include ActiveResource::Formats::JsonFormat

    extend self

    def self.customized
      Class
        .new
        .include(self)
        .new
    end

    def self.with_coders(encoder, decoder)
      # we allow each class to define its own decoder
      # to handle inconsistent api response nesting 

      customized
        .tap do |kustom|
          kustom
            .class
            .tap do |k|
              if decoder
                k.instance_variable_set("@decoder", decoder)
              end

              if encoder
                k.instance_variable_set("@encoder", encoder)
              end
            end
        end
    end

    def decode_json(json)
      ActiveSupport::JSON.decode(json)
    end
    
    def encode_hash(hash, options = {})
      ActiveSupport::JSON.encode(hash, options)
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

    def apply_custom_encoder(hash)
      return if hash.nil?

      self
        .class
        .instance_variable_get("@encoder")
        .yield_self do |encoder|
          encoder ?
            encoder.call(hash) :
            hash
      end

    end

    def encode(hash, options = {})
      encode_hash(apply_custom_encoder(hash), options)
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
