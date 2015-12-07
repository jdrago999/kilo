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
              context 'has channels' do
                before do
                  @channel = FactoryGirl.create(:channel, vhost_id: @vhost.id)
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
                    expect(@json[:items].count).to eq @vhost.channels.count
                    @json[:items].each do |item|
                      expect(item).to have_key :name
                      expect(item[:name]).to eq @channel.name
                    end
                  end
                end
              end
              context 'does not have any channels' do
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

  describe '#delete' do
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
          delete :delete, @form
        end
        it 'returns 200' do
          expect(response.status).to eq 200
        end
        it 'deletes the channel' do
          expect{@channel.reload}.to raise_error ActiveRecord::RecordNotFound
        end
      end
      context 'does not exist' do
        before do
          @form = {
            vhost: @vhost.name,
            channel: 'invalid-channel'
          }
          delete :delete, @form
        end
        it 'returns 404' do
          expect(response.status).to eq 404
        end
      end
    end
  end

  describe '#bonds' do
    before do
      @vhost_user = FactoryGirl.create(:vhost_user)
      @user = @vhost_user.user
      @vhost = @vhost_user.vhost
      @channel = FactoryGirl.create(:channel, vhost: @vhost)
      @exchange = FactoryGirl.create(:exchange, vhost: @vhost)
      controller.sign_in(@vhost_user.user)
    end
    context 'when the channel has bonds' do
      before do
        @bond = FactoryGirl.create(:bond, channel: @channel, exchange: @exchange)
        @form = {
          vhost: @vhost.name,
          channel: @channel.name,
        }
        get :bonds, @form
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
        it 'contains success:true' do
          expect(@json).to have_key :success
          expect(@json[:success]).to be_truthy
        end
        it 'contains a list of items containing the bonds' do
          expect(@json).to have_key :items
          expect(@json[:items]).to be_an Array
          expect(@json[:items].count).to eq @channel.bonds.count
        end
      end
    end
    context 'when the channel has no bonds' do
      before do
        @form = {
          vhost: @vhost.name,
          channel: @channel.name,
        }
        get :bonds, @form
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
        it 'contains success:true' do
          expect(@json).to have_key :success
          expect(@json[:success]).to be_truthy
        end
        it 'contains an empty list of items' do
          expect(@json).to have_key :items
          expect(@json[:items]).to be_an Array
          expect(@json[:items]).to be_empty
        end
      end
    end
  end

  describe '#get_bond' do
    before do
      @bond = FactoryGirl.create(:bond)
      @channel = @bond.channel
      @vhost = @channel.vhost
      @vhost_user = FactoryGirl.create(:vhost_user, vhost: @vhost)
      @user = @vhost_user.user
      controller.sign_in @user
    end
    context 'when the id given' do
      context 'is valid' do
        before do
          @form = {
            vhost: @vhost.name,
            channel: @channel.name,
            bond_id: @bond.id
          }
          get :get_bond, @form
        end
        it 'returns 200' do
          expect(response.status).to eq 200
        end
        it 'returns JSON' do
          expect{JSON.parse(response.body)}.not_to raise_error
        end
      end
      context 'is invalid' do
        before do
          @form = {
            vhost: @vhost.name,
            channel: @channel.name,
            bond_id: 'fake-bond-id'
          }
          get :get_bond, @form
        end
        it 'returns 404' do
          expect(response.status).to eq 404
        end
      end
    end
  end

  describe '#unbind' do
    before do
      @bond = FactoryGirl.create(:bond)
      @channel = @bond.channel
      @vhost = @channel.vhost
      @vhost_user = FactoryGirl.create(:vhost_user, vhost: @vhost)
      @user = @vhost_user.user
      controller.sign_in @user
    end
    context 'when the id given' do
      context 'is valid' do
        before do
          @form = {
            vhost: @vhost.name,
            channel: @channel.name,
            bond_id: @bond.id
          }
          delete :unbind, @form
        end
        it 'returns 200' do
          expect(response.status).to eq 200
        end
        it 'returns JSON' do
          expect{JSON.parse(response.body)}.not_to raise_error
        end
        it 'deletes the bond' do
          expect{@bond.reload}.to raise_error ActiveRecord::RecordNotFound
        end
      end
      context 'is invalid' do
        before do
          @form = {
            vhost: @vhost.name,
            channel: @channel.name,
            bond_id: 'fake-bond-id'
          }
          delete :unbind, @form
        end
        it 'returns 404' do
          expect(response.status).to eq 404
        end
      end
    end
  end

  describe '#subscribe' do
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
        context 'and the client is still connected' do
          context 'and there are no messages' do
            before do
              get :subscribe, @form
            end
            it 'returns 200' do
              expect(response.status).to eq 200
            end
            it 'returns an empty list of messages' do
              expect(response_stream_data[:messages]).to be_an Array
              expect(response_stream_data[:messages]).to be_empty
            end
          end
        end
        context 'and the client has disconnected' do
          before do
            expect_any_instance_of(Kilo::SSE).to receive(:write){ raise IOError }
          end
          it 'closes the SSE connection' do
            expect_any_instance_of(Kilo::SSE).to receive(:close).and_call_original
            get :subscribe, @form
          end
        end
      end
      context 'does not exist' do
        before do
          @form = {
            vhost: @vhost.name,
            channel: 'invalid-channel'
          }
          get :subscribe, @form
        end
        it 'returns 404' do
          expect(response.status).to eq 404
        end
      end
    end
  end
end
