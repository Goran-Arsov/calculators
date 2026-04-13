# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    skip_before_action :set_http_cache
    before_action :authenticate_admin

    private

    def authenticate_admin
      redirect_to admin_login_path unless session[:admin_authenticated] == true
    end
  end
end
