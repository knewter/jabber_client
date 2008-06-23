class MessagesController < JabberInterfaceController
  def index
  end

  def new
  end

  def create
    current_user.jabber_user.jabber_connection.deliver(params[:to], params[:message])
    respond_to do |format|
      format.html do
        flash[:notice] = "Message delivered."
        redirect_to '/buddy_list'
      end
      format.js
    end
  end
end
