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

          def represent(*args)
            opts = args.last.is_a?(Hash) ? args.pop : {}
            with = opts[:with] || (raise ArgumentError.new(":with option is required"))

            raise ArgumentError.new("nil can't be represented") unless args.first

            if with.is_a?(Class) #as Decorator
              with.new(*args)
            elsif args.length > 1
              raise ArgumentError.new("Can't represent using module with more than one argument")
            else #as Module
              args.first.extend(with)
            end
          end

          def represent_each(collection, *args)
            collection.map {|item| represent(item, *args) }
          end

        end

        #TODO find out why this validator class can not be found in testing environment if it is in the validator/ directory
        class Existing < Grape::Validations::Base
          def validate_param!(attr_name, params)
            klass = attr_name.split("_")[0].classify.constantize
            unless klass.find_by_id(params[attr_name])
              fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "#{klass} with id #{params[attr_name]} does not exist"
            end
          end
        end
      end
    end
  end
end
