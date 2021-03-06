module API
  module V1
    class Tasks < Grape::API
      include API::V1::Defaults
      resource :tasks do
        before do
          ensure_authentication!
        end

        desc "GET /tasks"
        get do
          represent_variant TasksService.fetch_for(current_user)
        end

        namespace :for_date do
          desc "GET /tasks/for_date/:date"
          params do
            requires :date, type: Date
          end
          route_param :date do
            desc "return user'tasks on the given date"
            get do
              tasks = represent_variant TasksService.fetch_for(current_user, params[:date])
              if tasks.empty?
                tasks
              else
                tasks.to_hash({ date: params[:date] })
              end
            end
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

          new_task = TasksService.create_task_for current_user, params

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

          desc "Delete the task with given id"
          delete do
            if @task.destroy
              status 200
            else
              error! I18n.t("errors.tasks.delete"), 500
            end
          end

          desc "Create execution for task with given id"
          namespace :check_for_date do
            params do
              requires :date, type: Date
            end
            route_param :date do
              desc "POST /tasks/:id/check_for_date/:date"
              post do

                if @task.done? params[:date]
                  status 200
                else
                  new_execution = @task.executions.create
                  if new_execution.calendar_date = params[:date]
                    status 201
                  else
                    error! I18n.t("errors.executions.create"), 500
                  end
                end

              end
            end
          end

          desc "Delete execution for task with given id"
          namespace :uncheck_for_date do
            params do
              requires :date, type: Date
            end
            route_param :date do
              desc "DELETE /tasks/:id/uncheck_for_date/:date"
              delete do

                #TODO differenciate server error and client error
                #2 situations could cause error:
                #1.task is not yet done on the given date => 400 client error
                #2.execution can't be destroyed => 500 server error
                if @task.delete_execution_for params[:date]
                  status 200
                else
                  error! I18n.t("errors.tasks.undone"), 400
                end

              end
            end
          end
        end

      end
    end
  end
end
