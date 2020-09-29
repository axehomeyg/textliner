require 'spec_helper'

RSpec.describe Textliner::Customer do
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

  it "#updates" do
    mock_textline_request(:retrieve_customer_by_phone)

    mock_textline_request(:update_customer,
      "{\"customer\":{\"avatar_url\":\"https://example.com/image.png\",\"blocked\":false,\"archived\":false,\"name\":\"Billy Bawb\",\"notes\":null,\"phone_number\":\"(222) 222-2222\",\"reachable_by_sms\":true,\"tags\":\"a-tag\",\"uuid\":\"deb79a6a-0652-4e14-86f2-dc8c5c502369\",\"facebook_id\":\"null\",\"custom_fields\":{\"c43a1766-47e1-4c9c-a2cc-36bf424fcbc0\":\"Custom_Field_1_value\",\"116bad5a-6233-472d-bcf0-199d53342a82\":\"null\"},\"consent_status\":true,\"id\":\"deb79a6a-0652-4e14-86f2-dc8c5c502369\",\"email\":\"billy@bawb.com\"}}")

    expect(
      Textliner::Customer 
        .find_by_phone_number("1231231234")
        .update_attributes(
          name: "Billy Bawb",
          tags: "a-tag",
          email: "billy@bawb.com")).to be_truthy # Truthy() #eql("Billy Bawb")
  end

  it "reports on reachability" do
    mock_textline_request(:retrieve_customer_by_phone)

    expect(Textliner::Customer.find_by_phone_number(phone))
      .to be_reachable
  end
end
