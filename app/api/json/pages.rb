module Api
  include Json

  get "/api/pages/:id" do |id|
    if page = Post.page.where(id: id).first
      {
        id: page.id,
        title: page.title,
        created_at: page.created_at,
        updated_at: page.updated_at,
        body: page.body,
        slug: page.slug,
        custom_fields: page.custom_fields
      }
    end
  end

  get "/api/pages" do
    pages = Post.page.select(:id).map do |p|
      { id: p.id }
    end

    { pages: pages }
  end

end
