require 'spec_helper'

describe VhostController do
  describe '#create' do
    before do
      @user = FactoryGirl.create(:user, is_admin: true)
      controller.sign_in @user
    end
    context 'when the name given' do
      before do
        @form = {
          name: SecureRandom.hex(10)
        }
      end
      context 'is not already used' do
        before do
          post :create, @form
        end
        it 'creates the vhost' do
          expect(Vhost.find_by(name: @form[:name])).to be_a Vhost
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
        end
      end
      context 'is already in use' do
        before do
          @original_vhost = FactoryGirl.create(:vhost)
          @form = {
            name: @original_vhost.name,
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
        end
      end
      context 'is missing' do
        before do
          @form = {
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
    context 'when the user is not an admin' do
      before do
        @user = FactoryGirl.create(:user, is_admin: false)
        controller.sign_in @user
        post :create, {name: SecureRandom.hex(8)}
      end
      it 'returns 401' do
        expect(response.status).to eq 401
      end
    end
  end

  describe '#delete' do
    before do
      @user = FactoryGirl.create(:user, is_admin: true)
      controller.sign_in @user
    end
    context 'when the vhost' do
      context 'exists' do
        before do
          @vhost = FactoryGirl.create(:vhost)
          delete :delete, {name: @vhost.name}
        end
        it 'deletes the vhost' do
          expect{@vhost.reload}.to raise_error ActiveRecord::RecordNotFound
        end
        it 'returns 200' do
          expect(response.status).to eq 200
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
        end
      end
      context 'does not exist' do
        before do
          post :delete, {name: 'invalid-vhost'}
        end
        it 'returns 404' do
          expect(response.status).to eq 404
        end
      end
    end
  end
end
