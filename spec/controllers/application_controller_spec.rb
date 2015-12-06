
require 'spec_helper'

describe ApplicationController do

  controller do
    before_filter :authenticate!
    def foo
      render text: :foo
    end
  end

  before :each do
    # Make sure we start out each test with a clean slate:
    controller.send(:redis).flushall
  end

  describe '#redis' do
    it 'returns a redis connection' do
      expect(controller.send(:redis)).to be_a Redis
    end
  end

  describe '#sign_in(user)' do
    before do
      @user = FactoryGirl.create(:user)
      @redis = controller.send(:redis)
    end
    context 'assigning tokens to the correct places in redis' do
      before do
        expect(SecureRandom).to receive(:uuid){ 'fake-uuid' }
        @token = controller.sign_in(@user)
      end
      it 'returns the token' do
        expect(@token).to eq 'fake-uuid'
      end

      it 'puts the token in redis (uid -> [atok])' do
        uid_to_atok_token = @redis.get("kilo.auth-token:#{@user.uid}")
        expect(uid_to_atok_token).to eq @token
      end
    end

    context 'uid-to-auth-token entries' do
      context 'when the user signs in multiple times' do
        it 're-uses the same token as long as it is not expired' do
          token = nil
          10.times do
            new_token = controller.sign_in(@user)
            if token
              expect(new_token).to eq token
            end
            token ||= new_token
          end
        end
      end
    end
  end

  describe '#current_user' do
    context 'when the user' do
      before do
        @user = FactoryGirl.create(:user)
      end
      context 'is signed in' do
        before do
          controller.sign_in(@user)
        end
        it 'returns the user' do
          expect(controller.current_user).to be_a User
          expect(controller.current_user.id).to eq @user.id
        end
      end
      context 'is not signed in' do
        it 'returns nil' do
          expect(controller.current_user).to be_nil
        end
      end
    end
  end

  describe '#authenticate!' do
    before do
      @routes.draw do
        get '/anonymous/foo'
        post '/anonymous/foo'
      end
      @user = FactoryGirl.create(:user)
      @token = controller.sign_in(@user)
      @form = {
        hello: :world
      }
      @nonce = SecureRandom.uuid
      @headers = {
        'X-Auth-Uid' => @user.uid,
        'X-Auth-Nonce' => @nonce,
        'content-type' => 'application/json',
        'ACCEPT' => 'application/json'
      }
      @request.env['CONTENT_TYPE'] = 'application/json'
    end
    context 'when provided valid auth headers' do
      context 'when we make a POST request' do
        before do
          string_to_sign = [ @form.to_json, @nonce, @token ].join('')
          @headers['X-Auth-Digest'] = Digest::SHA2.new.hexdigest( string_to_sign )
          post :foo, @form.to_json, {}, @headers
        end
        it 'returns a 200 status' do
          expect(response.status).to eq 200
        end
        it 'sets @user and @user_id' do
          expect(assigns(:user)).to be_a User
          expect(assigns(:user).id).to eq @user.id
          expect(assigns(:user_id)).to eq @user.id
        end
      end
      context 'when we make a GET request' do
        before do
          string_to_sign = [ @form.to_json, @nonce, @token ].join('')
          @headers['X-Auth-Digest'] = Digest::SHA2.new.hexdigest( string_to_sign )
          get :foo, @form.to_json, {}, @headers
        end
        it 'returns a 200 status' do
          expect(response.status).to eq 200
        end
        it 'sets @user and @user_id' do
          expect(assigns(:user)).to be_a User
          expect(assigns(:user).id).to eq @user.id
          expect(assigns(:user_id)).to eq @user.id
        end
      end
    end
    context 'when provided invalid auth headers' do
      context 'because one of the headers is not provided' do
        before do
          post :foo, @form.to_json, {}, @headers
        end
        it 'returns 401 status' do
          expect(response.status).to eq 401
        end
      end
      context 'because the auth token is invalid' do
        before do
          string_to_sign = [ @form.to_json, @nonce, 'invalid-token' ].join('')
          @headers['X-Auth-Digest'] = Digest::SHA1.new.hexdigest( string_to_sign )
          post :foo, @form.to_json, {}, @headers
        end
        it 'returns 401 status' do
          expect(response.status).to eq 401
        end
      end
    end
  end

end
