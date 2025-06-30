# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form, type: :model do
  describe "campaign_codes" do
    it "should remove empty arrays" do
      # Prepare
      value = [[], ["a"], ["b"]]
      tested = build(:form)
      tested.campaign_codes = value

      # Test
      result = tested.campaign_codes

      # Validate
      expect(result).to eq([["a"], ["b"]])
    end

    it "should handle a string with one campaign per line" do
      # Prepare
      value = "a\nb"
      tested = build(:form)
      tested.campaign_codes = value

      # Test
      result = tested.campaign_codes

      # Validate
      expect(result).to eq([["a"], ["b"]])
    end
  end

  describe "required_params" do
    it "returns only required field" do
      # Prepare
      field1 = create(:field, name: "name_1")
      field2 = create(:field, name: "name_2")
      tested = create(:form)
      create(:form_field, form: tested, field: field1, required: true)
      create(:form_field, form: tested, field: field2)

      # Test
      required_params = tested.required_params

      # Validate
      expect(required_params).to eq(["name_1"])
    end
  end

  describe "permitted_params" do
    it "returns permitted params" do
      # Prepare
      field_cam = create(:field, name: "the_campaign", input: "campaign")
      field_age = create(:field, name: "age", input: "number")

      tested = create(:form)
      create(:form_field, form: tested, field: field_cam)
      create(:form_field, form: tested, field: field_age)

      # Test
      tested_pp = tested.permitted_params

      # Validate
      expect(tested_pp.size).to eq(2)
      # noinspection RubyStringKeysInHashInspection
      expect(tested_pp).to include("the_campaign" => [])
      expect(tested_pp).to include("age")
    end
  end

  describe "initialize" do
    it "builds email field when attributes are empty" do
      # Prepare
      email_field = create(:email_field)

      # Test
      tested = build(:empty_form)

      # Validate
      expect(tested.form_fields.size).to eq(1)
      expect(tested.form_fields[0].field_id).to eq(email_field.id)
      expect(tested.form_fields[0].required).to eq(true)
    end

    it "does not build email field when attributes are not empty" do
      # Test
      tested = build(:form)

      # Validate
      expect(tested.form_fields.size).to eq(0)
    end
  end

  describe "recaptcha v3 validation" do
    it "requires recaptcha enabled" do
      form = create(:form)
      form.recaptcha_v3 = true
      form.validate
      expect(form.errors.count).to eq(3)
      expect(form.errors[:recaptcha_v3]).to include("requires recaptcha")
      expect(form.errors[:recaptcha_v3_threshold]).to include("is not included in the list")
      expect(form.errors[:recaptcha_v3_threshold]).to include("can't be blank")
    end
    it "does not require recaptcha if v3 is not set" do
      form = create(:form)
      form.recaptcha_v3 = false
      form.validate
      expect(form.errors.count).to eq(0)
    end
  end
end
