module Orcid
  # Because in trouble shooting what all goes into this remote call,
  # you may very well want all of this.
  class RemoteServiceError < RuntimeError
    def initialize(options)
      text = []
      text << "-- Client --"
      if client = options[:client]
        text << "id:\n\t#{client.id.inspect}"
        text << "site:\n\t#{client.site.inspect}"
        text << "options:\n\t#{client.options.inspect}"
        text << "scopes:\n\t#{Orcid.provider.authentication_scope}"
      end
      text << "\n-- Token --"
      if token = options[:token]
        text << "access_token:\n\t#{token.token.inspect}"
        text << "refresh_token:\n\t#{token.refresh_token.inspect}"
      end
      text << "\n-- Request --"
      text << "path:\n\t#{options[:request_path].inspect}" if options[:request_path]
      text << "headers:\n\t#{options[:request_headers].inspect}" if options[:request_headers]
      text << "body:\n\t#{options[:request_body]}" if options[:request_body]
      text << "\n-- Response --"
      text << "status:\n\t#{options[:response_status].inspect}" if options[:response_status]
      text << "body:\n\t#{options[:response_body]}" if options[:response_body]
      super(text.join("\n"))
    end
  end
end