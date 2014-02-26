module V1
  class HomeController < ApplicationController
    def index
      render json: { version: '0.0.1' }
    end
  end
end
