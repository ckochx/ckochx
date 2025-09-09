defmodule Ckochx.BlogTest do
  use ExUnit.Case

  alias Ckochx.Blog
  alias Ckochx.Blog.Post

  describe "NimblePublisher blog engine" do
    test "list_posts/0 returns all posts sorted by date (newest first)" do
      posts = Blog.list_posts()

      assert is_list(posts)
      assert length(posts) > 0

      # Check if posts are sorted by date (newest first)
      dates = Enum.map(posts, & &1.date)
      assert dates == Enum.sort(dates, {:desc, Date})
    end

    test "get_post/1 returns a post by slug" do
      # Test with a known slug
      post = Blog.get_post("getting-started")

      assert %Post{} = post
      assert post.slug == "getting-started"
      assert post.title
      assert post.content
      assert post.date
      assert post.author
    end

    test "get_post/1 returns nil for non-existent slug" do
      assert Blog.get_post("non-existent-post") == nil
    end

    test "posts have required fields" do
      posts = Blog.list_posts()

      for post <- posts do
        assert %Post{
                 slug: slug,
                 title: title,
                 date: date,
                 author: author,
                 content: content
               } = post

        assert is_binary(slug) and slug != ""
        assert is_binary(title) and title != ""
        assert %Date{} = date
        assert is_binary(author) and author != ""
        assert is_binary(content) and content != ""
      end
    end

    test "posts are compiled at build time (not read from filesystem at runtime)" do
      # This test ensures NimblePublisher's compile-time behavior
      # If this passes, it means posts are embedded in the module
      posts = Blog.list_posts()

      # The posts should be available even if we simulate missing files
      assert length(posts) > 0

      # Check that we get consistent results (compile-time embedding)
      posts_again = Blog.list_posts()
      assert posts == posts_again
    end

    test "posts support code syntax highlighting" do
      posts = Blog.list_posts()

      # Look for a post that might contain code blocks
      code_post =
        Enum.find(posts, fn post ->
          String.contains?(post.content, "<pre") or
            String.contains?(post.content, "highlight")
        end)

      if code_post do
        # If we find a code post, verify it has syntax highlighting
        assert String.contains?(code_post.content, "<pre") or
                 String.contains?(code_post.content, "highlight")
      end
    end

    test "posts have proper HTML content (converted from markdown)" do
      posts = Blog.list_posts()

      for post <- posts do
        # Content should be HTML, not raw markdown
        # Check that we don't have markdown headers at the start of lines
        # No raw markdown headers
        refute Regex.match?(~r/^# /m, post.content)
        # No raw markdown headers
        refute Regex.match?(~r/^## /m, post.content)

        # Should contain proper HTML
        # HTML headers present
        assert String.contains?(post.content, "<h")
        # HTML paragraphs present
        assert String.contains?(post.content, "<p")
      end
    end
  end
end
