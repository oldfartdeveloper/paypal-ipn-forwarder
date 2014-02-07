require_relative 'server'
require_relative 'server_poll_checker'
require_relative 'server_ipn_reception_checker'

module PaypalIpnForwarder

  # An object to hold a developer's information
  class UserContext

    attr_accessor :paypal_id, :email, :testing, :queue, :last_poll_time, :poll_checker, :ipn_reception_checker

    # @param [Server] server where this object 'lives'
    # @param [Hash] params
    # @param [Boolean] test_mode true if running regression tests; false if "in production"
    def initialize(server, params, test_mode=false)
      @server = server
      params.each_pair do |k, v|
        #puts "k: '#{k}'; v: '#{v.inspect}'"
        self.send((k.to_s + '=').to_sym, v)
      end
      self.queue = []
      self.poll_checker = ServerPollChecker.new(server, self, test_mode)
      self.ipn_reception_checker = ServerIpnReceptionChecker.new(@server, self.paypal_id, test_mode)
    end

    def record_poll_time(time=Time.now)
      self.last_poll_time = time
    end

  end
end
