require 'spec_helper'

describe AuthController do
  describe '#auth' do
    context 'when credentials' do
      before do
        @user = FactoryGirl.create(:user)
      end
      context 'are valid' do
        before do
          @form = {
            username: @user.username,
            password: @user.password
          }
        end
        it 'stores an auth token' do
          expect(controller).to receive(:sign_in).and_call_original
          post :auth, @form
        end
        it 'returns 200 status' do
          post :auth, @form
          expect(response.status).to eq 200
        end
        it 'returns JSON' do
          post :auth, @form
          expect{JSON.parse(response.body)}.not_to raise_error
        end
        context 'the JSON returned' do
          before do
            post :auth, @form
            @json = JSON.parse(response.body, symbolize_names: true)
          end
          it 'contains an auth_token attribute' do
            expect(@json).to have_key :auth_token
          end
        end
      end
      context 'are invalid' do
        context 'because of invalid password' do
          before do
            post :auth, {username: @user.username, password: 'fake-password'}
          end
          it 'returns 401 status' do
            expect(response.status).to eq 401
          end
        end
        context 'because of invalid username' do
          before do
            post :auth, {username: 'invalid-username', password: 'fake-password'}
          end
          it 'returns 401 status' do
            expect(response.status).to eq 401
          end
        end
      end
    end
  end
end
