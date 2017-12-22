module Api
  include Json

  get "/api/status" do
    latest = Post.order(updated_at: :desc).select(:updated_at).limit(1).first

    { last_updated_at: latest.updated_at }
  end

end
