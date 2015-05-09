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
            (represent_variant TasksService.fetch_all_for(current_user, params[:date])).to_hash({date: params[:date]})
          else
            represent_variant TasksService.fetch_all_for(current_user)
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
            represent_variant TasksService.fetch_one_for(current_user, params[:id])
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
