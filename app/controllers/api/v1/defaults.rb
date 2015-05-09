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

        #TODO find out why this validator class can not be found in testing environment if it is in the validator/ directory
        class Existing < Grape::Validations::Base
          def validate_param!(attr_name, params)
            klass = attr_name.to_s.split("_")[0].classify.constantize
            unless klass.find_by_id(params[attr_name])
              fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "#{klass} with id #{params[attr_name]} does not exist"
            end
          end
        end
      end
    end
  end
end
