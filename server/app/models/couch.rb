module Couch
  class Server
    def initialize(uri, options = nil)
      @uri = uri
      @options = options
    end

    def delete(uri)
      request(Net::HTTP::Delete.new(uri))
    end

    def get(uri)
      request(Net::HTTP::Get.new(uri))
    end

    def put(path, json)
      req = Net::HTTP::Put.new(path)
      req["Accept"] = "application/json"
      req["Content-Type"] = "application/json"
      req.body = json
      request(req)
    end

    def post(path, json)
      req = Net::HTTP::Post.new(path)
      req["Accept"] = "application/json"
      req["Content-Type"] = "application/json"
      req.body = json
      request(req)
    end

    def request(req)
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      req.basic_auth @uri.user, @uri.password
      res = http.request req
      unless res.kind_of?(Net::HTTPSuccess)
        handle_error(req, res)
      end
      res
    end

    private

    def handle_error(req, res)
      e = RuntimeError.new(res.to_yaml)
      puts e.inspect
    end
  end
end
