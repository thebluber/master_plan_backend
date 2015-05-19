module API
  module V1
    class Base < Grape::API
      mount API::V1::Users
      mount API::V1::Tasks
      mount API::V1::Goals
      mount API::V1::Categories
      mount API::V1::Session
    end
  end
end
