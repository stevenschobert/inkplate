class DropboxInterface

  API_VERSION = "2".freeze

  def create_link(path: "")
    url = "/#{ API_VERSION }/sharing/create_shared_link"
    post_json!(url, { path: path })
  end

  def list_folder(path: "")
    url = "/#{ API_VERSION }/files/list_folder"
    post_json!(url, { path: path })
  end

  def list_folder_with_cursor(cursor)
    path = "/#{ API_VERSION }/files/list_folder/continue"
    post_json!(path, { cursor: cursor })
  end

  def upload(fd, path: "", write_mode: :add, autorename: false)
    url = "/#{ API_VERSION }/files/upload"

    request = Net::HTTP::Post.new(url)
    request.content_type = "application/octet-stream"

    request["Dropbox-API-Arg"] = {
      path: path,
      mode: write_mode,
      autorename: autorename
    }.to_json

    if IO === fd
      request.body_stream = fd
      request.content_length = fd.size
    else
      request.body = fd
    end

    response_json(run_request!(request, target: :content))
  end

  private

  def api_key
    @api_key ||= ENV["DROPBOX_TOKEN"]
  end

  def authorize_request(request)
    unless api_key.to_s.empty?
      request["Authorization"] = "Bearer #{ api_key }"
    end
  end

  def base_uri
    @base_uri ||= URI("https://api.dropboxapi.com")
  end

  def content_uri
    @content_uri ||= URI("https://content.dropboxapi.com")
  end

  def content_http
    @content_http ||= begin
      content_http = Net::HTTP.new(content_uri.host, content_uri.port)
      if content_uri.scheme == "https"
        content_http.use_ssl = true
      end
      content_http
    end
  end

  def get_json!(path)
    request = Net::HTTP::Get.new(path)
    response_json(run_request!(request))
  end

  def http
    @http ||= begin
      http = Net::HTTP.new(base_uri.host, base_uri.port)
      if base_uri.scheme == "https"
        http.use_ssl = true
      end
      http
    end
  end

  def json_headers
    @json_headers ||= { "Content-Type" => "application/json" }
  end

  def post_json!(path, body = {}, headers = {})
    request = Net::HTTP::Post.new(path)

    json_headers.merge(headers).each{ |k,v| request[k] = v }
    request.body = body.to_json

    response_json(run_request!(request))
  end

  def response_json(response)
    JSON.parse(response.body)
  rescue
    nil
  end

  def run_request(request, target: :core)
    authorize_request(request)

    case target
    when :content
      content_http.request(request)
    else
      http.request(request)
    end
  end

  def run_request!(request, target: :core)
    response = run_request(request, target: target)
    unless response.kind_of?(Net::HTTPSuccess)
      raise "Got #{ response.code } for request: #{ request.path }: #{ response.body }"
    end
    response
  end

end
