module API
  module V1
    class Categories < Grape::API
      include API::V1::Defaults

      resource :categories do
        before do
          ensure_authentication!
        end

        desc "GET /categories"
        get do
          represent_variant current_user.categories
        end

        desc "POST /categories"
        params do
          requires :name, type: String
        end
        post do
          new_category = current_user.categories.new(name: params[:name])
          if new_category.save
            represent_variant new_category
          else
            error! I18n.t("errors.categories.create"), 500
          end
        end

        desc "/categories/:id"
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before do
            @category = current_user.categories.find(params[:id])
          end

          desc "GET /categories/:id"
          get do
            represent_variant @category
          end

          desc "PUT /categories/:id"
          params do
            optional :name, type: String
          end
          put do
            @category.name = params[:name] if params[:name]
            if @category.save
              represent_variant @category
            else
              error! I18n.t("errors.categories.update"), 500
            end
          end

          desc "DELETE /categories/:id"
          delete do
            if @category.deletable?
              if @category.destroy
                status 200
              else
                error! I18n.t("errors.categories.delete"), 500
              end
            else
              error! I18n.t("errors.categories.deletable"), 403
            end
          end
        end
      end

    end
  end
end

