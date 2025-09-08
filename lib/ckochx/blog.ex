defmodule Ckochx.Blog do
  @moduledoc """
  Blog module powered by NimblePublisher.
  All posts are compiled at build time for maximum performance.
  """

  alias __MODULE__.Post

  defmodule Post do
    @moduledoc "Struct representing a blog post"

    @enforce_keys [:slug, :title, :date, :author, :content]
    defstruct [
      :slug,
      :title, 
      :date,
      :author,
      :excerpt,
      :content,
      :tags
    ]

    def build(filename, attrs, body) do
      [year, month_day_id] = filename |> Path.rootname() |> Path.split() |> Enum.take(-2)
      [month, day, id] = String.split(month_day_id, "-", parts: 3)
      date = Date.from_iso8601!("#{year}-#{month}-#{day}")
      slug = id

      struct!(__MODULE__, [
        slug: slug,
        title: Map.fetch!(attrs, :title),
        author: Map.get(attrs, :author, "Christian Koch"),
        date: date,
        excerpt: Map.get(attrs, :excerpt, ""),
        content: body,
        tags: Map.get(attrs, :tags, [])
      ])
    end
  end

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:ckochx, "priv/blog/posts/**/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_erlang]

  @doc "Get all blog posts, sorted by date (newest first)"
  def list_posts do
    @posts
    |> Enum.sort_by(& &1.date, {:desc, Date})
  end

  @doc "Get a single blog post by slug"
  def get_post(slug) do
    Enum.find(@posts, &(&1.slug == slug))
  end

  @doc "Get recent posts (limit to n posts)"
  def recent_posts(limit \\ 5) do
    @posts
    |> Enum.sort_by(& &1.date, {:desc, Date})
    |> Enum.take(limit)
  end

  @doc "Get all unique tags from all posts"
  def all_tags do
    @posts
    |> Enum.flat_map(& &1.tags)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc "Get posts by tag"
  def get_posts_by_tag(tag) do
    @posts
    |> Enum.filter(&(tag in &1.tags))
    |> Enum.sort_by(& &1.date, {:desc, Date})
  end

end
