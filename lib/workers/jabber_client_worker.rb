class JabberClientWorker < BackgrounDRb::MetaWorker
  set_worker_name :jabber_client_worker

  def create(args=nil)
    logger.info args.inspect
    #handle_messaging
  end

  def handle_messaging(args={})
    logger.info "start handling messaging"
    ju = JabberUpdater.new( args[:login], args[:password] )
    ju.handle_async_messaging
    logger.info "done handling messaging"
  end

  def print_args(args=nil)
    logger.info args.inspect
  end
end

