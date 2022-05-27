require "rails_helper"

RSpec.describe BriteVerify do
  describe ".valid_email?" do
    context "valid email address" do
      subject { described_class.valid_email?("sales@validity.com") }

      it "returns true when service says 'valid'" do
        stub_request(:post, BriteVerify::FULLVERIFY)
          .to_return(status: 200, body: {email: {status: "valid"}}.to_json)

        expect(subject).to be true
      end

      it "returns true when service returns error" do
        stub_request(:post, BriteVerify::FULLVERIFY)
          .to_return(status: 401, body: "")

        expect(subject).to be true
      end
    end

    context "invalid email address" do
      subject { described_class.valid_email?("invalidtest@validity.com") }

      it "returns false when service says 'invalid'" do
        stub_request(:post, BriteVerify::FULLVERIFY)
          .to_return(status: 200, body: {email: {status: "invalid"}}.to_json)

        expect(subject).to be false
      end

      it "returns true when service says 'invalid' but secondary reason is 'mailbox_full_invalid'" do
        stub_request(:post, BriteVerify::FULLVERIFY)
          .to_return(status: 200, body: {email: {status: "invalid", error_code: "mailbox_full_invalid"}}.to_json)

        expect(subject).to be true
      end

      it "returns true when service says 'invalid' but secondary reason is 'role_address'" do
        stub_request(:post, BriteVerify::FULLVERIFY)
          .to_return(status: 200, body: {email: {status: "invalid", error_code: "role_address"}}.to_json)

        expect(subject).to be true
      end

      it "returns true when service returns bad JSON" do
        stub_request(:post, BriteVerify::FULLVERIFY)
          .to_return(status: 200, body: "bad_json")

        expect(subject).to be true
      end
    end

    context "no API key" do
      subject { described_class.valid_email?("invalidtest@validity.com") }

      around do |example|
        env_value_before = ENV["BRITE_VERIFY_API_KEY"]
        ENV["BRITE_VERIFY_API_KEY"] = nil
        example.run
        ENV["BRITE_VERIFY_API_KEY"] = env_value_before
      end

      it "throws a KeyError" do
        expect { subject }.to raise_error(KeyError)
      end
    end
  end
end
