class BuddyListController < JabberInterfaceController
  before_filter :ensure_new_single_jabber_client_worker, :only => [:index]

protected
  def ensure_new_single_jabber_client_worker
    if MiddleMan.all_worker_info.detect{|w| w[:job_key] == current_user.jabber_user.login}
      MiddleMan.delete_worker :worker => :jabber_client_worker, :job_key => current_user.jabber_user.login
    end
    MiddleMan.new_worker(:worker => :jabber_client_worker, :job_key => current_user.jabber_user.login)
    MiddleMan.worker(:jabber_client_worker, current_user.jabber_user.login).handle_messaging( :login => current_user.jabber_user.login, :password => current_user.jabber_user.password)
  end

public
  def index
  end
end
