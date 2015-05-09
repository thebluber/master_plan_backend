module API::V1::APITestHelper
  extend ActiveSupport::Concern

  included do
    include Rack::Test::Methods
    include HelperMethods
  end

  module HelperMethods
    def app
      Rails.application
    end

    def log_in email, pw
      post "/api/v1/users/sign_in", { user: { email: email, password: pw } }
    end

    def log_out
      delete "/api/v1/users/sign_out"
    end
  end
end
