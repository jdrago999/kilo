require 'spec_helper'

describe ExchangeController do

  describe '#create' do
    before do
      @vhost_user = FactoryGirl.create(:vhost_user)
      @user = @vhost_user.user
      @vhost = @vhost_user.vhost
      controller.sign_in(@vhost_user.user)
    end
    context 'when the vhost' do
      context 'is valid' do
        context 'when the name' do
          context 'is already used' do
            before do
              @original_exchange = FactoryGirl.create(:exchange, vhost: @vhost)
              @form = {
                vhost: @vhost.name,
                name: @original_exchange.name
              }
              post :create, @form
            end
            it 'returns a 400 response' do
              expect(response.status).to eq 400
            end
          end
          context 'is not already used' do
            before do
              @form = {
                vhost: @vhost.name,
                name: SecureRandom.hex(8)
              }
              post :create, @form
            end
            it 'creates the exchange' do
              expect(Exchange.where(name: @form[:name]).count).to eq 1
            end
            it 'returns a 201 response' do
              expect(response.status).to eq 201
            end
            it 'returns a JSON body' do
              expect{JSON.parse(response.body)}.not_to raise_error
            end
            context 'the JSON body' do
              before do
                @json = JSON.parse(response.body, symbolize_names: true)
              end
              it 'includes a success attribute' do
                expect(@json).to have_key :success
              end
              it 'includes a path attribute' do
                expect(@json).to have_key :path
              end
            end
          end
        end
      end
      context 'is invalid' do
        before do
          post :create, {vhost: 'invalid-name', name: 'anything'}
        end
        it 'returns 404' do
          expect(response.status).to eq 404
        end
      end
    end
  end

  describe '#list' do
  end

  describe '#show' do
  end

  describe '#delete' do
  end

  describe '#bindings' do
  end
end
