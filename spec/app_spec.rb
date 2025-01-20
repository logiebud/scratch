require 'spec_helper'

RSpec.describe WordleApp do
  include Rack::Test::Methods

  def app
    WordleApp
  end

  describe "GET /" do
    it "loads the homepage" do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Sinatra Wordle')
    end
  end
end
