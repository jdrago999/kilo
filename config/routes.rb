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
          scope 'bindings' do
            get '' => 'exchange#bindings'
          end
        end
      end
      scope 'queues' do
        get '' => 'queue#list'
        post '' => 'queue#create'
        scope ':name' do
          get '' => 'queue#show'
          delete '' => 'queue#delete'
          scope 'bindings' do
            get '' =>'queue#bindings'
            post '' =>'queue#create_binding'
            scope ':id' do
              get '' => 'queue#get_binding'
              delete '' => 'queue#delete_binding'
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
