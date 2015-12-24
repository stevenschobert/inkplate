module Api
  include Json

  get "/api/posts/:id" do |id|
    if post = Post.where(id: id).first
      {
        id: id,
        title: post.title,
        created_at: post.created_at,
        updated_at: post.updated_at,
        body: post.body,
        slug: post.slug
      }
    end
  end

  get "/api/posts" do
    posts = Post.select(:id).map do |p|
      { id: p.id }
    end

    { posts: posts }
  end

end
