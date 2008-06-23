require 'ubygems'
require 'xmpp4r'
require 'xmpp4r-simple'

class JabberConnectionServer
  attr_accessor :connectinos

  def initialize
    @connections = {}
  end

  def get_connection_for login, pass
    @connections[login] ||= Jabber::Simple.new(login, pass)
  end
end
