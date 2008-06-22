class JabberUsersController < ApplicationController
  before_filter :login_required
  before_filter :load_jabber_user

protected
  def load_jabber_user
    @jabber_user   = current_user.jabber_user
    @jabber_user ||= JabberUser.new(params[:jabber_user])
    @jabber_user.user ||= current_user # some stupid issues with .build that I don't have time to figure out.
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
