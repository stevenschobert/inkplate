module Api
  include Json

  get "/api/micro/:id" do |id|
    if micro = Post.micro.where(id: id).first
      {
        id: micro.id,
        title: micro.title,
        status: micro.status,
        body: micro.body,
        created_at: micro.created_at,
        updated_at: micro.updated_at,
        custom_fields: micro.custom_fields
      }
    end
  end

  get "/api/micro" do
    micro_posts = Post.micro.select(:id).map do |p|
      { id: p.id }
    end

    { micro_posts: micro_posts }
  end

end
