Rails.application.routes.draw do

  scope :api do
    post 'auth' => 'auth#auth'

    scope ':vhost' do
      scope 'exchanges' do
        post '' => 'exchange#create'
        get '' => 'exchange#list'
        scope ':name' do
          get '' => 'exchange#show'
          delete '' => 'exchange#delete'
          scope 'bonds' do
            get '' => 'exchange#bonds'
          end
        end
      end
      scope 'channels' do
        get '' => 'channel#list'
        post '' => 'channel#create'
        scope ':name' do
          get '' => 'channel#show'
          delete '' => 'channel#delete'
          scope 'bonds' do
            get '' =>'channel#bonds'
            post '' =>'channel#create_bond'
            scope ':id' do
              get '' => 'channel#get_bond'
              delete '' => 'channel#delete_bond'
            end
          end
          scope 'messages' do
            post '' => 'message#create'
            scope ':id' do
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
