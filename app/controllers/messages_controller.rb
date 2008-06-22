class MessagesController < JabberInterfaceController
  def index
  end

  def new
  end

  def create
    current_user.jabber_user.jabber_connection.deliver(params[:to], params[:message])
    flash[:notice] = "Message delivered."
    redirect_to '/buddy_list'
  end
end
