# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MonitorsController, type: :controller do
  describe 'lb' do
    it 'returns lb.txt' do
      # Test
      get :lb

      # Verify
      expect(response.status).to eq(200)
      expect(response.body).to eq("OK\n")
    end
  end
end
