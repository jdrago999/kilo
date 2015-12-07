require 'spec_helper'

describe ChannelController do
  describe '#create' do
    before do
      @vhost_user = FactoryGirl.create(:vhost_user)
      @user = @vhost_user.user
      @vhost = @vhost_user.vhost
      controller.sign_in(@vhost_user.user)
    end
    context 'when the name' do
      context 'is not already in use' do
        before do
          @form = {
            vhost: @vhost.name,
            name: SecureRandom.hex(8)
          }
          post :create, @form
        end
        it 'creates a channel' do
          expect(@vhost.channels.find_by(name: @form[:name])).not_to be_nil
        end
        it 'returns 201' do
          expect(response.status).to eq 201
        end
        it 'returns JSON' do
          expect{JSON.parse(response.body)}.not_to raise_error
        end
        context 'the JSON returned' do
          before do
            @json = JSON.parse(response.body, symbolize_names: true)
          end
          it 'includes success:true' do
            expect(@json).to have_key :success
            expect(@json[:success]).to be_truthy
          end
          it 'includes path' do
            expect(@json).to have_key :path
          end
        end
      end
      context 'is already in use' do
        before do
          @original_channel = FactoryGirl.create(:channel, vhost: @vhost)
          @form = {
            vhost: @vhost.name,
            name: @original_channel.name
          }
          post :create, @form
        end
        it 'returns 201' do
          expect(response.status).to eq 201
        end
        it 'returns JSON' do
          expect{JSON.parse(response.body)}.not_to raise_error
        end
        context 'the JSON returned' do
          before do
            @json = JSON.parse(response.body, symbolize_names: true)
          end
          it 'includes success:true' do
            expect(@json).to have_key :success
            expect(@json[:success]).to be_truthy
          end
          it 'includes path' do
            expect(@json).to have_key :path
          end
        end
      end
      context 'is missing' do
        before do
          @form = {
            vhost: @vhost.name,
            name: nil
          }
          post :create, @form
        end
        it 'returns a 400 status' do
          expect(response.status).to eq 400
        end
        it 'returns JSON' do
          expect{JSON.parse(response.body)}.not_to raise_error
        end
        context 'the JSON returned' do
          before do
            @json = JSON.parse(response.body, symbolize_names: true)
          end
          it 'contains success:false' do
            expect(@json).to have_key :success
            expect(@json[:success]).to be_falsey
          end
          it 'contains error' do
            expect(@json).to have_key :errors
            expect(@json[:errors]).to be_an Array
            expect(@json[:errors]).not_to be_empty
          end
        end
      end
    end
  end

  describe '#bind' do
  end
end
