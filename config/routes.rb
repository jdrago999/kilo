Rails.application.routes.draw do

  scope :api do
    post 'auth' => 'auth#auth'

    scope ':vhost' do
      scope 'exchanges' do
        scope ':name' do
          scope 'bindings' do
          end
        end
      end
      scope 'queues' do
        scope ':name' do
          scope 'bindings' do
            scope ':id' do
            end
          end
          scope 'messages' do
          end
        end
      end
    end
  end

end
