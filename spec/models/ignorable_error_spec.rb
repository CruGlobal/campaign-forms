
# frozen_string_literal: true

RSpec.describe IgnorableError do
  describe 'new' do
    it 'creates an instance' do
      error = IgnorableError.new('hello')
      expect(error).to be_a(StandardError)
    end
  end
end
