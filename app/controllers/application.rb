class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '0d5c817cd87ec951e652bc30ea6ae3d4'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def jabber_login_required
    unless logged_in? && current_user.jabber_user && current_user.jabber_user.active?
      flash[:error] = "You must have a jabber account set up first."
      redirect_to new_jabber_user_path and return
    end
  end
end
