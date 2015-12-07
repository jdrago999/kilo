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
    before do
      @vhost_user = FactoryGirl.create(:vhost_user)
      @vhost = @vhost_user.vhost
      @user = @vhost_user.user
      controller.sign_in @user
    end
    context 'when the vhost' do
      context 'is valid' do
        context 'and the user' do
          context 'has read access' do
            context 'and the vhost' do
              context 'has exchanges' do
                before do
                  @exchange = FactoryGirl.create(:exchange, vhost_id: @vhost.id)
                  get :list, vhost: @vhost.name
                end
                it 'returns a 200 response' do
                  expect(response.status).to eq 200
                end
                it 'returns JSON' do
                  expect{JSON.parse(response.body)}.not_to raise_error
                end
                context 'the JSON returned' do
                  before do
                    @json = JSON.parse(response.body, symbolize_names: true)
                  end
                  it 'has success=true' do
                    expect(@json).to have_key :success
                    expect(@json[:success]).to be_truthy
                  end
                  it 'has items=[list of {name: "foo"}]' do
                    expect(@json).to have_key :items
                    expect(@json[:items]).to be_an Array
                    expect(@json[:items]).not_to be_empty
                    expect(@json[:items].count).to eq @vhost.exchanges.count
                    @json[:items].each do |item|
                      expect(item).to have_key :name
                      expect(item[:name]).to eq @exchange.name
                    end
                  end
                end
              end
              context 'does not have any exchanges' do
                before do
                  get :list, vhost: @vhost.name
                end
                it 'returns a 200 response' do
                  expect(response.status).to eq 200
                end
                it 'returns JSON' do
                  expect{JSON.parse(response.body)}.not_to raise_error
                end
                context 'the JSON returned' do
                  before do
                    @json = JSON.parse(response.body, symbolize_names: true)
                  end
                  it 'has success=true' do
                    expect(@json).to have_key :success
                    expect(@json[:success]).to be_truthy
                  end
                  it 'has items=[empty list]' do
                    expect(@json).to have_key :items
                    expect(@json[:items]).to be_an Array
                    expect(@json[:items]).to be_empty
                  end
                end
              end
            end
          end
          context 'does not have read access' do
            before do
              @vhost_user.update_attributes! read: false
              get :list, vhost: @vhost.name
            end
            it 'returns 401' do
              expect(response.status).to eq 401
            end
          end
        end
      end
      context 'is invalid' do
        before do
          get :list, vhost: 'invalid-vhost'
        end
        it 'returns 404' do
          expect(response.status).to eq 404
        end
      end
    end
  end

  describe '#show' do
  end

  describe '#delete' do
  end

  describe '#bindings' do
  end
end
