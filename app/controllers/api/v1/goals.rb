module API
  module V1
    class Goals < Grape::API
      include API::V1::Defaults

      resource :goals do
        before do
          ensure_authentication!
        end

        desc "GET /goals"
        get do
          represent_variant current_user.goals
        end

        desc "POST /goals"
        params do
          requires :title, type: String
          optional :description, type: String
          optional :deadline, type: Date
        end
        post do
          new_goal = current_user.goals.new(params)
          if new_goal.save
            represent_variant new_goal
          else
            error! I18n.t("errors.goals.create"), 500
          end
        end

        desc "/goals/:id"
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before do
            @goal = current_user.goals.find(params[:id])
          end

          desc "GET /goals/:id"
          get do
            represent_variant @goal
          end

          desc "PUT /goals/:id"
          params do
            optional :title, type: String
            optional :description, type: String
            optional :deadline, type: Date
          end
          put do
            @goal.title = params[:title] if params[:title]
            @goal.description = params[:description] if params[:description]
            @goal.deadline = params[:deadline] if params[:deadline]
            if @goal.save
              represent_variant @goal
            else
              error! I18n.t("errors.goals.update"), 500
            end
          end

          desc "POST /goals/:id/tasks"
          params do
            requires :description, type: String
            requires :category_id, type: Integer
            requires :flag, type: Integer, values: 0..3
            optional :deadline, type: Date
          end
          post 'tasks' do
            category = current_user.categories.find(params[:category_id])
            new_task = current_user.tasks.new({
              description: params[:description],
              category: category,
              flag: params[:flag],
              goal_id: @goal.id
            })
            new_task.deadline = params[:deadline] if params[:deadline]

            if new_task.save
              represent_variant new_task
            else
              error! I18n.t("errors.tasks.create"), 500
            end

          end
        end

      end

    end
  end
end

