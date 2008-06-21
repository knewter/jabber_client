class JabberUpdater
  attr_accessor :client

  def initialize
    @client = Jabber::Simple.new(JABBER_CLIENT_TEST_LOGIN, JABBER_CLIENT_TEST_PASS)
  end

  def handle_async_messaging
    while(true) do
      sleep(1)
      handle_presence_updates
      handle_received_messages
    end
  end

  def handle_presence_updates
    if @client.presence_updates?
      # TODO: This needs to restrict to the particular user it's supposed to be updating.
      the_presence_updates = @client.presence_updates.map do |update|
        update.map do |el|
          case el
          when String
            el.gsub(/'/, "") # Can't have any stray single ticks coming through.  I'm removing them altogether, meh.  FIXME.
          else
            el
          end
        end
      end
      Juggernaut.send_to_all("new BuddyListUpdate('#{the_presence_updates.to_json}');")
    end
  end

  def handle_received_messages
    if @client.received_messages?
      # TODO: This needs to restrict to the particular user it's supposed to be updating.
      the_messages = @client.received_messages.map do |message|
        { :from => message.from.to_s, :body => message.body }
      end
      puts the_messages.inspect
      Juggernaut.send_to_all("new MessagesUpdate('#{the_messages.to_json}');")
    end
  end
end
