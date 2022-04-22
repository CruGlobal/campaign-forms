require "rails_helper"

RSpec.describe BriteVerify do
  describe ".valid_email?" do

    context "valid email address" do
      subject { described_class.valid_email?("sales@validity.com") }

      it "returns true when service says 'valid'" do
        stub_request(:post, "https://#{BriteVerify::API_HOST}/api/v1/fullverify")
          .to_return(status: 200, body: {email: {status: "valid"}}.to_json, headers: {})

        expect(subject).to be true
      end

      it "returns true when service returns error" do
        stub_request(:post, "https://#{BriteVerify::API_HOST}/api/v1/fullverify")
          .to_return(status: 401, body: "", headers: {})

        expect(subject).to be true
      end
    end

    context "invalid email address" do
      subject { described_class.valid_email?("invalidtest@validity.com") }

      it "returns false when service says 'invalid'" do
        stub_request(:post, "https://#{BriteVerify::API_HOST}/api/v1/fullverify")
          .to_return(status: 200, body: {email: {status: "invalid"}}.to_json, headers: {})

        expect(subject).to be false
      end

      it "returns true when service returns bad JSON" do
        stub_request(:post, "https://#{BriteVerify::API_HOST}/api/v1/fullverify")
          .to_return(status: 200, body: "bad_json", headers: {})

        expect(subject).to be true
      end
    end
  end
end
