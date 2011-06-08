class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :get_address

  def get_address
    port = request.port
    host = request.host
    return "http://"+host.to_s+":"+port.to_s
  end


end


