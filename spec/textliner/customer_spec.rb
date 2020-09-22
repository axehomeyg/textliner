require 'spec_helper'

RSpec.describe Textliner::Customer do
  # include TextlinerSpecHelper
  let(:phone) { "(222) 222-2222" }

  it "#find_by_phone_number" do
    mock_textline_request(:retrieve_customer_by_phone)

    expect(
      Textliner::Customer
        .find_by_phone_number(phone)
        .phone_number)
      .to eql(phone)
  end

  it "#find_or_create_by_phone_number" do
    stub_textline_api!

    mock_textline_request(:retrieve_customer_by_phone_error_200)

    mock_textline_request(
      :create_customer_by_phone,
      "{\"customer\":{\"phone_number\":\"missing_but_valid\"}}")

    expect(
      Textliner::Customer
        .find_by_phone_number("missing_but_valid")
    ).to be_blank

    expect(
      Textliner::Customer
        .find_or_create_by_phone_number("missing_but_valid")
        .phone_number
    ).to eql(phone)
  end

  it "reports on reachability" do
    mock_textline_request(:retrieve_customer_by_phone)
    
    expect(Textliner::Customer.find_by_phone_number(phone))
      .to be_reachable
  end
end
