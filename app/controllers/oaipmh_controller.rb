
require 'thales/output/oaipmh/record_provider'

# Ruby on Rails controller.

class OaipmhController < ApplicationController

  # Responds to OAI-PMH requests.

  def index
    # Remove controller and action from the options.
    # (Rails adds them automatically.)
    options = params.delete_if { |k,v| %w{controller action}.include?(k) }
    options['url'] = "#{request.base_url}/oai"

    provider = Thales::Output::OAIPMH::RecordProvider.new
    response =  provider.process_request(options)

    render :text => response, :content_type => 'text/text' # for testing
    # render :text => response, :content_type => 'application/xml'
  end
end

