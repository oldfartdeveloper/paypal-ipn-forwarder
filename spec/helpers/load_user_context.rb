require 'yaml'
require_relative '../../lib/paypal-ipn-forwarder/user_context'


module LoadUserContext

  def user_contexts(server)
    contexts = {}
    from_yaml.each_pair do | k, v |
      contexts[k] = ::PaypalIpnForwarder::UserContext.new(server, v, true)
    end
    contexts
  end

  private

  def from_yaml
    ::YAML::load_file(File.expand_path('../user_context.yml', __FILE__))
  end

end
