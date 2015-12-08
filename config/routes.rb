Rails.application.routes.draw do

  scope :api, format: false do
    post 'auth' => 'auth#auth'
    scope 'admin' do
      scope 'vhosts' do
        post '' => 'vhost#create'
        scope ':vhost' do
          delete '' => 'vhost#delete'
        end
      end
    end
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
          scope 'broadcast' do
            post '' => 'channel#broadcast'
          end
          scope 'subscribe' do
            get '' => 'channel#subscribe'
          end
          scope 'ack' do
            post '' => 'channel#ack'
          end
          scope 'nack' do
            post '' => 'channel#nack'
          end
        end
      end
    end
  end

end
