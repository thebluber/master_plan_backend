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
            (represent_variant TasksService.fetch_for(current_user, params[:date])).to_hash({date: params[:date]})
          else
            represent_variant TasksService.fetch_for(current_user)
          end
        end

        desc "create a new task"
        params do
          requires :description, type: String
          requires :category_id, type: Integer
          requires :flag, type: Integer, values: 0..3
          optional :deadline, type: Date
          optional :goal_id, type: Integer
        end
        post do
          goal = current_user.goals.find(params[:goal_id]) if params[:goal_id]
          category = current_user.categories.find(params[:category_id])

          new_task = current_user.tasks.new({
            description: params[:description],
            category: category,
            flag: params[:flag]
          })

          new_task.deadline = params[:deadline] if params[:deadline]
          new_task.goal = goal if goal

          if new_task.save
            represent_variant new_task
          else
            error! I18n.t('errors.tasks.create'), 500
          end
        end

        desc "/tasks/:id"
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before do
            @task = current_user.tasks.find(params[:id])
            current_user.categories.find(params[:category_id]) if params[:category_id]
            current_user.goals.find(params[:goal_id]) if params[:goal_id]
          end

          desc "Get the task with given id"
          get do
            represent_variant @task
          end

          desc "Update the task with given id"
          params do
            optional :description, type: String
            optional :category_id, type: Integer
            optional :flag, type: Integer, values: 0..3
            optional :deadline, type: Date
            optional :goal_id, type: Integer
          end
          put do
            params.each do |key, val|
              @task[key] = val
            end
            if @task.save
              represent_variant @task
            else
              error! I18n.t("errors.tasks.update"), 500
            end
          end

        end

      end
    end
  end
end
