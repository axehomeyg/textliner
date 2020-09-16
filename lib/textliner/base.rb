require 'ostruct'
require 'uri'
require 'active_resource'

module Textliner
  class Base < ::ActiveResource::Base
    self.site = "https://application.textline.com/api"
    self.include_root_in_json = true

    headers['X-TGP-ACCESS-TOKEN'] = "dummy" # (Rails.application.credentials.textline || {})[:access_token]
  end
end

