module API
  module V1
    class Tasks < Grape::API
      include API::V1::Defaults
      resource :tasks do
        before do
          ensure_authentication!
        end

        desc "return user's tasks or user's tasks on given date"
        params do
          optional :date, type: Date
        end
        get do
          if params[:date]
          else
            (represent_variant current_user.tasks.order(:flag)).to_json({somearg: 'test'})
          end
        end

        desc "create a new task"
        params do
          requires :description, type: String
          requires :category_id, type: Integer, existing: true #custom validator
          requires :flag, type: Integer, values: 0..3
          optional :deadline, type: Date
          optional :goal_id, type: Integer, existing: true
        end
        post do
        end

        desc "GET /tasks/:id"
        params do
          requires :id, type: Integer
        end
        get ':id' do
        end

        desc "PUT /tasks/:id"
        params do
          requires :id, type: Integer
        end
        put ':id' do
        end
      end
    end
  end
end
