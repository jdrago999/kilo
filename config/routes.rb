Rails.application.routes.draw do

  scope :api, format: false do
    post 'auth' => 'auth#auth'

    scope ':vhost' do
      scope 'channels' do
        get '' => 'channel#list'
        post '' => 'channel#create'
        scope ':channel' do
          get '' => 'channel#show', as: :show_channel
          delete '' => 'channel#delete'
          scope 'publish' do
            post '' => 'channel#publish'
          end
          scope 'subscribe' do
            get '' => 'channel#subscribe'
          end
          scope 'messages' do
            scope ':message_id' do
              get '' => 'message#show'
              put '' => 'message#update'
              delete '' => 'message#delete'
            end
          end
        end
      end
    end
  end

end
