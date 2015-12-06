require 'spec_helper'

describe AuthController do
  describe '#auth' do
    context 'when credentials' do
      context 'are valid' do
        before do
        end
        it 'stores an auth token'
        it 'returns 200 status'
        it 'returns JSON'
        context 'the JSON returned' do
          it 'contains an auth_token attribute'
        end
      end
      context 'are invalid' do
        it 'returns 401 status'
      end
    end
  end
end
