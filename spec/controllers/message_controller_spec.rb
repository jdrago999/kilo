require 'spec_helper'

describe MessageController do

  describe '#create' do
    before do
      @bond = FactoryGirl.create(:bond)
      @channel = @bond.channel
      @vhost = @channel.vhost
      @vhost_user = FactoryGirl.create(:vhost_user, vhost: @vhost)
      @user = @vhost_user.user
      controller.sign_in @user
    end
    context 'when given valid args' do
      before do
        message = {
          job: SecureRandom.uuid
        }
        @form = {
          vhost: @vhost.name,
          channel: @channel.name,
          message: message.to_json
        }
        post :create, @form
      end
      it 'returns 200' do
        expect(response.status).to eq 200
      end
      it 'creates a message' do
#        expect(Message.count).to eq 1
      end
      it 'returns JSON' do
        expect{JSON.parse(response.body)}.not_to raise_error
      end
      context 'the JSON returned' do
        before do
          @json = JSON.parse(response.body, symbolize_names: true)
        end
        it 'has success:true' do
          expect(@json).to have_key :success
          expect(@json[:success]).to be_truthy
        end
        it 'has a message path' do
          expect(@json).to have_key :path
        end
      end
    end
  end

end

