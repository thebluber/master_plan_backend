module API
  module V1
    class Session < Grape::API
      include API::V1::Defaults

      resources :session do
        before do
          ensure_authentication!
        end

        desc "GET /session"
        get do
          represent_variant current_user
        end
      end

    end
  end
end
