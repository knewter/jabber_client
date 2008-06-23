# Backgroundrb
# FIXME: check if data that we are writing to the socket should end with newline
require "pathname"
require "packet"
BACKGROUNDRB_ROOT = Pathname.new(RAILS_ROOT).realpath.to_s
require "backgroundrb/bdrb_conn_error"
require "backgroundrb/bdrb_config"
require "backgroundrb/rails_worker_proxy"

module BackgrounDRb
end
class BackgrounDRb::WorkerProxy
  #include Packet::NbioHelper
  def self.init
    @config = BackgrounDRb::Config.read_config("#{BACKGROUNDRB_ROOT}/config/backgroundrb.yml")
    @server_ip = @config[:backgroundrb][:ip]
    @server_port = @config[:backgroundrb][:port]
    new
  end

  def self.server_ip; @server_ip; end
  def self.server_port; @server_port; end

  def server_ip; self.class.server_ip; end
  def server_port; self.class.server_port; end

  def self.custom_connection(ip,port)
    @server_ip = ip
    @server_port = port
    new
  end

  def initialize
    @mutex = Mutex.new
    #establish_connection
  end

  def worker(worker_name,job_key = nil)
    BackgrounDRb::RailsWorkerProxy.worker(worker_name,job_key,self)
  end

  def establish_connection
    begin
      timeout(3) do
        @connection = TCPSocket.open(server_ip, server_port)
        @connection.setsockopt(Socket::IPPROTO_TCP,Socket::TCP_NODELAY,1)
      end
      @connection_status = true
    rescue Timeout::Error
      @connection_status = false
    rescue Exception => e
      @connection_status = false
    end
  end

  def write_data data
    begin
      flush_in_loop(data)
    rescue Errno::EAGAIN
      return
    rescue Errno::EPIPE
      establish_connection
      if @connection_status
        flush_in_loop(data)
      else
        @connection_status = false
        raise BackgrounDRb::BdrbConnError.new("Error while writing")
      end
    rescue
      establish_connection
      if @connection_status
        flush_in_loop(data)
      else
        @connection_status = false
        raise BackgrounDRb::BdrbConnError.new("Error while writing")
      end
    end
  end

  def flush_in_loop(data)
    t_length = data.length
    loop do
      break if t_length <= 0
      written_length = @connection.write(data)
      raise "Error writing to socket" if written_length <= 0
      result = @connection.flush
      data = data[written_length..-1]
      t_length = data.length
    end
  end

  def dump_object data
    establish_connection
    raise BackgrounDRb::BdrbConnError.new("Error while connecting to the backgroundrb server") unless @connection_status

    object_dump = Marshal.dump(data)
    dump_length = object_dump.length.to_s
    length_str = dump_length.rjust(9,'0')
    final_data = length_str + object_dump
    @mutex.synchronize { write_data(final_data) }
  end

  def close_connection
    @connection.close
    @connection = nil
  end

  def ask_work p_data
    p_data[:type] = :do_work
    dump_object(p_data)
    close_connection
  end

  def new_worker p_data
    p_data[:type] = :start_worker
    dump_object(p_data)
    close_connection
    p_data[:job_key]
  end

  def worker_info(p_data)
    p_data[:type] = :worker_info
    dump_object(p_data)
    bdrb_response = nil
    @mutex.synchronize { bdrb_response = read_from_bdrb() }
    close_connection
    bdrb_response
  end


  def all_worker_info
    p_data = { }
    p_data[:type] = :all_worker_info
    dump_object(p_data)
    bdrb_response = nil
    @mutex.synchronize { bdrb_response = read_from_bdrb() }
    close_connection
    bdrb_response
  end

  def delete_worker p_data
    p_data[:type] = :delete_worker
    dump_object(p_data)
    close_connection
  end

  def read_object
    begin
      message_length_str = @connection.read(9)
      message_length = message_length_str.to_i
      message_data = @connection.read(message_length)
      return message_data
    rescue
      raise BackgrounDRb::BdrbConnError.new("Not able to connect")
    end

   # begin
   #   while(t_data = @connection.read_nonblock((16*1024)-1))
   #     sock_data << t_data
   #   end
   #   return sock_data.join
   # rescue Errno::EAGAIN
   #   return sock_data.join
   # rescue Errno::EWOULDBLOCK
   #   return sock_data.join
   # rescue
   #   raise BackgrounDRb::BdrbConnError.new("Not able to connect",sock_data.join)
   # end
  end

  def query_all_workers
    p_data = { }
    p_data[:type] = :all_worker_status
    dump_object(p_data)
    bdrb_response = nil
    @mutex.synchronize { bdrb_response = read_from_bdrb() }
    close_connection
    bdrb_response
  end

  def ask_status(p_data)
    p_data[:type] = :get_status
    dump_object(p_data)
    bdrb_response = nil
    @mutex.synchronize { bdrb_response = read_from_bdrb() }
    close_connection
    bdrb_response
  end

  def read_from_bdrb(timeout = 3)
    #@tokenizer = Packet::BinParser.new
    begin
      ret_val = select([@connection],nil,nil,timeout)
      return nil unless ret_val
      raw_response = read_object()
      master_response = Marshal.load(raw_response)
      return master_response
    rescue
      return nil
    end
  end

  def send_request(p_data)
    p_data[:type] = :get_result
    dump_object(p_data)
    bdrb_response = nil
    @mutex.synchronize { bdrb_response = read_from_bdrb(nil) }
    close_connection
    bdrb_response
  end
end

MiddleMan = BackgrounDRb::WorkerProxy.init

