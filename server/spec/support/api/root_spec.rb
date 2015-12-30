require 'rails_helper'

describe 'api', type: :request do
  it "root exists" do
    get "/api/v1/doc.json"
    response.status.should == 200
    json_response = JSON.parse(response.body)
    json_response["apiVersion"].should == "v1"
    json_response["apis"].size.should > 0
  end
end
