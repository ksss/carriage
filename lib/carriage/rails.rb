require File.expand_path("./config/application.rb")
::Rails::Application.initializer "carriage.eager_load" do
  ::Rails.application.config.eager_load = true
end

class Carriage
  class Rails < ::Rails::Engine
    initializer 'carriage' do
    end
  end
end

require File.expand_path("./config/environment.rb")
