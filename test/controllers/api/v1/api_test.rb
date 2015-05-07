module APITest
  @@API_ROOT = "/api/v1"
  def self.included(base)
    base.send :include, Rack::Test::Methods
  end

  def app
    Rails.application
  end
end
