module TextlinerSpecHelper
  def stubs(&block)
    has_block = block_given?

    {
      list_conversations: [ :get, "https://application.textline.com/api/conversations.json" ],
      retrieve_conversation: [ :get, /https:\/\/application.textline.com\/api\/conversation\/[0-9a-f\-]+.json/ ],
      retrieve_conversation_for_page: [ :get, /^https:\/\/application.textline.com\/api\/conversation\/[0-9a-f\-]+\.json\?page=\d$/ ],
      conversation_by_phone: [ :get, "https://application.textline.com/api/conversations.json?phone_number=%2B2222222222" ],
      list_conversations_for_page: [ :get, /^https:\/\/application.textline.com\/api\/conversations\.json\?page=\d$/ ]
    }.yield_self do |st|
      has_block ?
        block.call(st) :
        st
    end
  end

  def load_textline_response(name)
    File.read(File.expand_path(File.join(File.dirname(__FILE__), "../fixtures/#{name}.json")))
  end

  def stub_textline_request!(name, opts)
    stub_request(*opts)
      .with(
        headers: {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
          #,
          # 'X-Tgp-Access-Token'=>''
        })
      .to_return(status: 200, body: load_textline_response(name), headers: {})
  end

  def stub_textline!(&block)
    # puts "stubbing textline"
    allow(Textliner).to receive(:max_pages).and_return(2)

    self
      .stubs(&block)
      .map do |name, opts|
        stub_textline_request!(name, opts)
      end
  end
end

