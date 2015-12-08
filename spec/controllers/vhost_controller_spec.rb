require 'spec_helper'

describe VhostController do
  describe '#create' do
    context 'when the name given' do
      context 'is not already used' do
        it 'creates the vhost'
        it 'returns 200'
        it 'returns JSON'
        context 'the JSON returned' do
          it 'has success:true'
        end
      end
      context 'is already used' do
        it 'returns 400'
      end
    end
  end

  describe '#delete' do
    context 'when the vhost' do
      context 'exists' do
        it 'deletes the vhost'
        it 'returns 200'
        it 'returns JSON'
        context 'the JSON returned' do
          it 'has success:true'
        end
      end
      context 'does not exist' do
        it 'returns 404'
      end
    end
  end
end
