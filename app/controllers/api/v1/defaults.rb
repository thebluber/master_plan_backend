module API
  module V1
    module Defaults
      extend ActiveSupport::Concern
      included do

        version 'v1'
        format :json

        helpers do
          def warden
            env['warden']
          end

          def current_user
            warden.user
          end

          def authenticated?
            warden.authenticated?
          end

          def ensure_authentication!
            error! 'Not authenticated', 401 unless authenticated?
          end
        end

      end
    end
  end
end
