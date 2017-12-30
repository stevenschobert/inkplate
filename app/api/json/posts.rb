module Api
  include Json

  get "/api/posts/:id" do |id|
    if post = Post.post.where(id: id).first
      {
        id: post.id,
        title: post.title,
        created_at: post.created_at,
        updated_at: post.updated_at,
        status: post.status,
        body: post.body,
        excerpt: post.excerpt,
        slug: post.slug,
        categories: Category.for_post(post).map(&:name),
        custom_fields: post.custom_fields
      }
    end
  end

  get "/api/posts" do
    posts = Post.post.select(:id).map do |p|
      { id: p.id }
    end

    { posts: posts }
  end

end
