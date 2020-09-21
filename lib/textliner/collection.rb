module Textliner
  class Collection < ActiveResource::Collection
    def initialize(parsed = {})
      @elements = parsed.is_a?(Hash) ?
        [parsed] :
        parsed
    end
  end
end

