module Api
  include Json

  get "/api/posts/:id" do |id|
    { id: id }
  end

end
