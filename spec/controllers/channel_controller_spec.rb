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
    before do
      @vhost_user = FactoryGirl.create(:vhost_user)
      @user = @vhost_user.user
      @vhost = @vhost_user.vhost
      controller.sign_in(@vhost_user.user)
    end
    context 'when the channel' do
      context 'exists' do
        before do
          @channel = FactoryGirl.create(:channel, vhost: @vhost)
          @form = {
            vhost: @vhost.name,
            channel: @channel.name
          }
        end
        context 'and the exchange' do
          context 'exists' do
            context 'and input is valid' do
              before do
                @exchange = FactoryGirl.create(:exchange, vhost: @vhost)
                @form[:exchange] = @exchange.name
                post :bind, @form
              end
              it 'returns a 201 status' do
                expect(response.status).to eq 201
              end
              it 'returns JSON' do
                expect{JSON.parse(response.body)}.not_to raise_error
              end
              context 'the JSON returned' do
                before do
                  @json = JSON.parse(response.body, symbolize_names: true)
                end
                it 'contains success:true' do
                  expect(@json).to have_key :success
                  expect(@json[:success]).to be_truthy
                end
              end
            end
            context 'and input is invalid' do
              before do
                @exchange = FactoryGirl.create(:exchange, vhost: @vhost)
                @form[:exchange] = @exchange.name
                expect_any_instance_of(Bond).to receive(:valid?).at_least(1).times{ false }
                expect_any_instance_of(Bond).to receive(:errors){ [:foo, :bar]}
                post :bind, @form
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
                it 'contains success:true' do
                  expect(@json).to have_key :success
                  expect(@json[:success]).to be_falsey
                end
              end
            end
          end
          context 'does not exist' do
            before do
              @exchange = FactoryGirl.create(:exchange, vhost: @vhost)
              @form[:exchange] = 'invalid-exchange'
              post :bind, @form
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
              it 'contains success:true' do
                expect(@json).to have_key :success
                expect(@json[:success]).to be_falsey
              end
            end
          end
        end
      end
      context 'does not exist' do
        before do
          post :bind, {
            vhost: @vhost.name,
            channel: 'invalid-channel'
          }
        end
        it 'returns 404' do
          expect(response.status).to eq 404
        end
      end
    end
  end
end
