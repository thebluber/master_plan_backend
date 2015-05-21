module API
  module V1
    class Users < Grape::API
      include API::V1::Defaults
      include Devise::Controllers::Rememberable
      
      resource :users do
        desc "sign in user"
        params do
          requires :user, type: Hash do
            requires :email, type: String
            requires :password, type: String
            optional :remember_me, type: Boolean
          end
        end
        post 'sign_in' do
          env['devise.allow_params_authentication'] = true
          warden.logout if authenticated?
          if warden.authenticate(scope: :user)
            represent_variant current_user
          else
            error! "Wrong email address or password", 401
          end
        end

        desc "sign out user"
        delete 'sign_out' do
          warden.logout
          status 200
        end
      end

    end
  end
end
