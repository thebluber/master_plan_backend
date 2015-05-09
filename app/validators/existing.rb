class Existing < Grape::Validations::Base
  def validate_param!(attr_name, params)
    klass = attr_name.to_s.split("_")[0].classify.constantize
    unless klass.find_by_id(params[attr_name])
      fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "#{klass} with id #{params[attr_name]} does not exist"
    end
  end
end
