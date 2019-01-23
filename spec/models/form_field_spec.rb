# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormField, type: :model do
  describe 'label_value' do
    it 'should return label value' do
      # Prepare
      field = create(:field, label: 'field label', name: 'field_name')
      tested = build(:form_field, label: 'nice field', field: field)

      # Test and verify
      expect(tested.label_value).to eq('nice field')
    end

    it 'should return label of the field' do
      # Prepare
      field = create(:field, label: 'field label', name: 'field_name')
      tested = build(:form_field, label: nil, field: field)

      # Test and verify
      expect(tested.label_value).to eq('field label')
    end

    it 'should return name of the field' do
      # Prepare
      field = create(:field, label: 'field label', name: 'field_name')
      tested = build(:form_field, label: nil, field: field)
      field.label = nil

      # Test and verify
      expect(tested.label_value).to eq('field_name')
    end
  end

  describe 'placeholder_value' do
    it 'should return placeholder from form_field' do
      # Prepare
      field = create(:field, placeholder: 'field placeholder', name: 'field_name')
      tested = build(:form_field, label: 'nice field', placeholder: 'ff placeholder', field: field)

      # Test and verify
      expect(tested.placeholder_value).to eq('ff placeholder')
    end

    it 'should return placeholder from field' do
      # Prepare
      field = create(:field, placeholder: 'field placeholder', name: 'field_name')
      tested = build(:form_field, label: 'nice field', placeholder: nil, field: field)

      # Test and verify
      expect(tested.placeholder_value).to eq('field placeholder')
    end

    it 'should return label as placeholder' do
      # Prepare
      field = create(:field, placeholder: nil, name: 'field_name')
      tested = build(:form_field, label: 'nice field', placeholder: nil, field: field)

      # Test and verify
      expect(tested.placeholder_value).to eq('nice field')
    end
  end

  describe 'partial' do
    it 'should return value of input for "radio"' do
      # Prepare
      field = create(:field, input: 'radio')
      tested = build(:form_field, field: field)

      # Test and verify
      expect(tested.partial).to eq('radio')
    end

    it 'should return word "input" when input is not select, radio or campaign' do
      # Prepare
      field = create(:field, input: 'email')
      tested = build(:form_field, field: field)

      # Test and verify
      expect(tested.partial).to eq('input')
    end
  end
end
