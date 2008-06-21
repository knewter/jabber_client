class JabberUsersController < ApplicationController
  before_filter :login_required
  before_filter :load_jabber_user

protected
  def load_jabber_user
    @jabber_user   = current_user.jabber_user
    @jabber_user ||= current_user.jabber_user.build(params[:jabber_user])
  end

public
  def index
  end

  def new
  end

  def create
    if (@jabber_user.new_record? ? @jabber_user.save : @jabber_user.update_attributes(params[:jabber_user]))
      redirect_to '/buddy_list'
    else
      flash[:error] = "There was a problem saving your jabber user."
      render :action => 'new'
    end
  end
end
