class JabberUser < ActiveRecord::Base
  belongs_to :user
  before_save :set_active
  attr_accessor :j_connection

  def jabber_connection
    @j_connection ||= JABBER_CONNECTIONS.get_connection_for(login, password)
    @j_connection
  end

  def set_active
    self.active = valid_jabber_user?
  end

  def valid_jabber_user?
    !(self.login.blank? || self.password.blank?)
  end
end
