Rails.application.routes.draw do

  scope :api, format: false do
    post 'auth' => 'auth#auth'

    scope ':vhost' do
      scope 'exchanges' do
        post '' => 'exchange#create', as: :create_exchange
        get '' => 'exchange#list'
        scope ':exchange' do
          get '' => 'exchange#show', as: :show_exchange
          delete '' => 'exchange#delete'
        end
      end
      scope 'channels' do
        get '' => 'channel#list'
        post '' => 'channel#create'
        scope ':channel' do
          get '' => 'channel#show', as: :show_channel
          delete '' => 'channel#delete'
          post 'bind' => 'channel#bind'
          scope 'bonds' do
            get '' =>'channel#bonds'
            scope ':bond_id' do
              get '' => 'channel#get_bond', as: :show_bond
              delete '' => 'channel#unbind'
            end
          end
          scope 'subscribe' do
            get '' => 'channel#subscribe'
          end
          scope 'publish' do
            post '' => 'channel#publish'
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
