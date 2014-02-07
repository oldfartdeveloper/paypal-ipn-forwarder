require_relative 'load_config'
require_relative 'mail_sender'

module PaypalIpnForwarder
  class ServerPollChecker

    attr_accessor :last_unexpected_poll
    attr_accessor :loop_boolean

    def initialize(server, user_context, is_test_mode=false)
      @content = LoadConfig.new(is_test_mode)
      #places variables to 2 day before creation of class instance
      @last_unexpected_poll = Time.now - 2*24*60*60
      @last_incomplete_poll = Time.now - 2*24*60*60
      @last_poll_time = @content.last_poll_time.clone unless @content.last_poll_time.nil?
      @server = server
      @user_context = user_context

    end

    def record_poll_time(time=Time.now)
      @last_poll_time = time
    end

    def last_poll_time
      @last_poll_time
    end

    def unexpected_poll_time(time=Time.now)
      if(@last_unexpected_poll + 24*60*60 <= time)
        send_email(MailSender::POLL_BEFORE_TEST_MODE_ON_ERROR)
        @last_unexpected_poll = time
      end
    end

    def send_email(body)
      email      = @user_context.email
      to         = email
      subject    = MailSender.build_subject_line(paypal_id)
      body       = body + HAPPENING_ONLY_TO_YOU
      mailsender = MailSender.new
      mailsender.send_mail(to, subject, body)
    end

    def check_testing_polls_occurring(time=@content.no_polling_time_before_email)
      sleep_time = @content.poll_checking_interval_seconds.to_i
      @loop_boolean = true
      @last_email_time = @last_poll_time
      loop do
        sleep sleep_time
        break unless @loop_boolean
        last_interval_ago = Time.now - time
        email_recently_sent = !@last_email_time.nil? && @last_email_time >= last_interval_ago
        need_email_sent = @last_poll_time.nil? || @last_poll_time <= last_interval_ago
        unless email_recently_sent || need_email_sent
          body = <<EOS
Test mode has been turned on for sandbox with id: #{paypal_id}
but no polling has occurred for it since #{last_interval_ago}.
Please address this issue.

A simple way is to turn testing off by running 'ruby stop_paypal'
in the paypal ipn forwarder gem
EOS
          send_email(body)
          @last_email_time = Time.now
          three_times_last_interval_ago = Time.now - 3*time
          @user_context.cancel_test_mode if @last_poll_time <= three_times_last_interval_ago
          break if @last_poll_time <= three_times_last_interval_ago
        end
      end
    end

    def email_developer_incomplete_request(email, test_mode, id, time=Time.now)
      to = email
      subject = 'Your computer is polling the Superbox IPN forwarder but is missing information. No IPN will be retrieved'
      body = "Your development computer is polling the Superbox IPN forwarder.
    Here is the information it is providing:\nemail:#{email}\ntest_mode:#{test_mode}\nid:#{id}\n
    One of those fields is blank. Please fix this problem and start polling again."

      if (@last_incomplete_poll + 60*60 <=> time) == -1
        @last_incomplete_poll = Time.now
        mailsender = MailSender.new
        mailsender.send_mail(to, subject, body)
      end
    end
  end
end
