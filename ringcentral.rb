require 'rest-client'
require 'base64'
require 'json'

# The entry point class for this library
class RingCentral
  def initialize(app_key, app_secret, server)
    @app_key = app_key
    @app_secret = app_secret
    @server = server
    @token = nil
  end

  def authorize(username, extension, password)
    url = File.join(@server, '/restapi/oauth/token')
    payload = {
      username: username,
      extension: extension,
      password: password,
      grant_type: 'password'
    }
    header = {
      Authorization: autorization_header
    }
    response = RestClient.post(url, payload, header)
    @token = JSON.parse(response.body)
  end

  def get(endpoint, params = nil)
    execute(:get, endpoint, nil, params)
  end

  def post(endpoint, payload, params = nil)
    url = File.join(@server, endpoint)
    headers = {
      Authorization: autorization_header,
      'Content-Type' => 'application/json'
    }
    headers['params'] = params if params
    response = RestClient.post(url, payload.to_json, headers)
    response
  end

  def put(endpoint, payload, params = nil)
    url = File.join(@server, endpoint)
    headers = {
      Authorization: autorization_header,
      'Content-Type' => 'application/json'
    }
    headers['params'] = params if params
    response = RestClient.put(url, payload.to_json, headers)
    response
  end

  def delete(endpoint, params = nil)
    execute(:delete, endpoint, nil, params)
  end

  def execute(method, endpoint, payload = nil, params = nil)
    url = File.join(@server, endpoint)
    headers = {
      Authorization: autorization_header
    }
    if method == :post || method == :put
      headers['Content-Type'] = 'application/json'
    end
    headers['params'] = params if params
    RestClient::Request.execute(method: method, url: url, payload: payload, headers: headers)
  end

  private

  def basic_key
    Base64.encode64("#{@app_key}:#{@app_secret}").gsub(/\s/, '')
  end

  def autorization_header
    if @token
      "Bearer #{@token['access_token']}"
    else
      "Basic #{basic_key}"
    end
  end
end
