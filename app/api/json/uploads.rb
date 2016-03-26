module Api
  include Json

  get "/api/uploads/:id" do |id|
    if upload = Upload.where(id: id).first
      {
        id: upload.id,
        name: upload.name,
        mime_type: upload.mime_type,
        size: upload.size,
        url: upload.dropbox_url
      }
    end
  end

  get "/api/uploads" do
    uploads = Upload.select(:id).map do |i|
      { id: i.id }
    end

    { uploads: uploads }
  end

end
