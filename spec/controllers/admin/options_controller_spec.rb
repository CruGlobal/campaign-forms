
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::OptionsController, type: :controller do
  render_views
  before(:each) do
    @user = create(:user, has_access: true)
    sign_in @user
  end

  describe 'GET index' do
    it 'returns something' do
      # Prepare
      option_value = create(:option_value)

      # Test
      get :index

      # Verify
      expect(response.status).to eq(200)
      expect(response.body).to match(option_value.name)
      expect(response.body).to match(option_value.label)
    end
  end
end
