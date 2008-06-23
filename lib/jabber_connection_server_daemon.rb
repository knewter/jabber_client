require 'drb'
require 'jabber_connection_server'

DRb.start_service("druby://:7777", JabberConnectionServer.new) 
DRb.thread.join
