require 'rest-client'

module PaypalIpnForwarder
  class ServerClient

    def initialize(server)
      @server = server
    end

    def computer_testing(params_parsed)
      sandbox_id = params_parsed['sandbox_id']
      case params_parsed['test_mode']
      when 'on'
        unless @server.computer_online?(sandbox_id)
          @server.begin_test_mode(sandbox_id, params_parsed)
        else
          email = params_parsed['email']
          if @server.two_users_hitting_same_sandbox?(sandbox_id, email)
            @server.send_conflict_email(sandbox_id, email)
            @server.cancel_test_mode(sandbox_id)
          end
        end
      when 'off'
        @server.cancel_test_mode(sandbox_id)
      else
        # TODO: what to do when test_mode is neither 'on' nor 'off'
      end
    end

    def respond_to_computer_poll(paypal_id, now=Time.now)
      @server.record_computer_poll(paypal_id)
      if (@server.computer_online?(paypal_id))
        @server.send_ipn_if_present(paypal_id)
      else
        @server.unexpected_poll(paypal_id)
      end
    end

    def ipn_response(ipn_str)
      'cmd=_notify-validate&' + ipn_str
    end

    # @param [Ipn] ipn the PayPal IPN as an object
    def receive_ipn(ipn)
      @server.receive_ipn(ipn)
    end

    def send_response_to_paypal(url, message)
      RestClient.post url, message
    end

  end
end
