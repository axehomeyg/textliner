module Textliner
  module SpecHelper
    def textline_stubs(&block)
      has_block = block_given?

      {
        list_conversations: [ :get, "https://application.textline.com/api/conversations.json" ],
        retrieve_conversation: [ :get, /https:\/\/application.textline.com\/api\/conversation\/[0-9a-f\-]+.json/ ],
        retrieve_conversation_for_page: [ :get, /^https:\/\/application.textline.com\/api\/conversation\/[0-9a-f\-]+\.json\?page=\d+$/ ],
        conversation_by_phone: [ :get, "https://application.textline.com/api/conversations.json?phone_number=%2B2222222222" ],
        conversation_by_phone_error_200: [ :get, /https:\/\/application.textline.com\/api\/conversations\.json\?phone_number=missing.*/ ],
        list_conversations_for_page: [ :get, /^https:\/\/application.textline.com\/api\/conversations\.json\?page=\d+$/ ],

        update_customer: [ :put, /^https:\/\/application.textline.com\/api\/customer\/[0-9a-f\-]+.json/],

        retrieve_customer_by_phone: [ :get, /^https:\/\/application.textline.com\/api\/customers\.json\?phone_number=[^a-z]+$/ ],
        retrieve_customer_by_phone_error_200: [ :get, /^https:\/\/application.textline.com\/api\/customers\.json\?phone_number=missing.*$/ ],
        create_customer_by_phone: [ :post, "https://application.textline.com/api/customers.json" ] ,
        create_conversation_by_phone: [ :post, "https://application.textline.com/api/conversations.json" ] ,

        append_conversation: [ :post, /https:\/\/application.textline.com\/api\/conversation\/[0-9a-f\-]+.json/ ],
        conversation_by_phone_since: [ :get, /^https:\/\/application.textline.com\/api\/conversations\.json\?after_uuid=[^&]+&phone_number=%2B2222222222/ ],
      }.yield_self do |st|
        has_block ?
          block.call(st) :
          st
      end
    end

    def load_textline_response(name)
      File.read(File.expand_path(File.join(File.dirname(__FILE__), "../../spec/fixtures/#{name}.json")))
    end

    def stub_textline_api!
      Textliner::Base.access_token("dummy")
      Textliner.throttle = 0.01 
      Textliner.max_pages = 2
    end

    def mock_textline_request(fixture_name, body = nil, status = 200)
      opts = textline_stubs[fixture_name]

      write = [:post, :put, :delete].include?(opts[0])

      response = load_textline_response(fixture_name)

      payload = body ? { body: body } : {}
      
      stub_request(*opts)
        .with({
          headers: {
            'Accept'=> write ? "*/*" : 'application/json',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }
          .merge(write ? { 'X-Tgp-Access-Token'=>'dummy' } : {})}
        .merge(payload)).to_return(status: status, body: response, headers: {})
    end
  end
end
