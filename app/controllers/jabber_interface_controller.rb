class JabberInterfaceController < ApplicationController
  before_filter :login_required
  before_filter :jabber_login_required
end
