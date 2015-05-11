module API
  module V1
    module Defaults
      extend ActiveSupport::Concern
      included do

        version 'v1'
        format :json

        rescue_from ActiveRecord::RecordNotFound do |e|
          #remove sql expression in the returning message
          error_response(message: e.message.gsub(/\[.+\]/, "").strip, status: 400)
        end

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

          def represent_variant object_or_collection
            if object_or_collection.respond_to?(:each)
              return [] if object_or_collection.empty?
              object = object_or_collection.first
              representer = "#{object.class}Presenter".constantize
              object_or_collection.extend(representer.for_collection)
            else
              object = object_or_collection
              representer = "#{object.class}Presenter".constantize
              object_or_collection.extend(representer)
            end
          end
        end

      end
    end
  end
end
