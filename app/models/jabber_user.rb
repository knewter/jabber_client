class JabberUser < ActiveRecord::Base
  belongs_to :user
  before_save :set_active

  def jabber_connection
    Jabber::Simple.new(login, password)
  end

  def set_active
    self.active = valid_jabber_user?
  end

  def valid_jabber_user?
    !(self.login.blank? || self.password.blank?)
  end
end
