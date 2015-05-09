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
            represent_variant current_user.tasks.order(:flag).where(deadline: params[:date])
          else
            (represent_variant current_user.tasks.order(:flag)).to_hash({somearg: 'test'})
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
          nil
        end

        desc "GET /tasks/:id"
        params do
          requires :id, type: Integer
        end
        route_param :id do
          get do
            represent_variant current_user.tasks.find(params[:id])
          end
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
