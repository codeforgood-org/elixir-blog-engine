defmodule BlogEngine.PostTest do
  use ExUnit.Case
  doctest BlogEngine.Post

  alias BlogEngine.Post

  describe "new/4" do
    test "creates a post with all required fields" do
      post = Post.new(1, "Title", "Body", ["tag1", "tag2"])

      assert post.id == 1
      assert post.title == "Title"
      assert post.body == "Body"
      assert post.tags == ["tag1", "tag2"]
      assert %DateTime{} = post.created_at
      assert post.updated_at == nil
    end

    test "creates a post without tags" do
      post = Post.new(1, "Title", "Body")

      assert post.tags == nil
    end

    test "sets created_at to current time" do
      before = DateTime.utc_now()
      post = Post.new(1, "Title", "Body")
      after_time = DateTime.utc_now()

      assert DateTime.compare(post.created_at, before) in [:gt, :eq]
      assert DateTime.compare(post.created_at, after_time) in [:lt, :eq]
    end
  end

  describe "update/2" do
    test "updates title" do
      post = Post.new(1, "Old Title", "Body")
      updated = Post.update(post, title: "New Title")

      assert updated.title == "New Title"
      assert updated.body == "Body"
      assert updated.updated_at != nil
    end

    test "updates body" do
      post = Post.new(1, "Title", "Old Body")
      updated = Post.update(post, body: "New Body")

      assert updated.body == "New Body"
      assert updated.title == "Title"
    end

    test "updates tags" do
      post = Post.new(1, "Title", "Body", ["old"])
      updated = Post.update(post, tags: ["new1", "new2"])

      assert updated.tags == ["new1", "new2"]
    end

    test "updates multiple fields at once" do
      post = Post.new(1, "Old", "Old", ["old"])
      updated = Post.update(post, title: "New", body: "New", tags: ["new"])

      assert updated.title == "New"
      assert updated.body == "New"
      assert updated.tags == ["new"]
    end

    test "sets updated_at timestamp" do
      post = Post.new(1, "Title", "Body")
      updated = Post.update(post, title: "New")

      assert %DateTime{} = updated.updated_at
      assert DateTime.compare(updated.updated_at, post.created_at) == :gt
    end
  end

  describe "format_date/1" do
    test "formats datetime to readable string" do
      {:ok, datetime, 0} = DateTime.from_iso8601("2025-11-13T17:32:15Z")
      formatted = Post.format_date(datetime)

      assert formatted == "2025-11-13 17:32:15"
    end
  end

  describe "preview/1" do
    test "returns title and first 100 chars of short body" do
      post = Post.new(1, "Title", "Short body")
      preview = Post.preview(post)

      assert preview == "Title\nShort body"
    end

    test "truncates long body with ellipsis" do
      long_body = String.duplicate("a", 150)
      post = Post.new(1, "Title", long_body)
      preview = Post.preview(post)

      assert String.contains?(preview, "Title")
      assert String.contains?(preview, "...")
      assert String.length(preview) < String.length(long_body) + 10
    end

    test "preview is exactly 100 chars + ellipsis for bodies over 100 chars" do
      long_body = String.duplicate("a", 150)
      post = Post.new(1, "Title", long_body)
      preview = Post.preview(post)

      body_part = preview |> String.split("\n") |> Enum.at(1)
      assert String.length(body_part) == 103  # 100 chars + "..."
    end
  end

  describe "matches_query?/2" do
    test "matches query in title (case-insensitive)" do
      post = Post.new(1, "Elixir Tutorial", "Content", nil)

      assert Post.matches_query?(post, "elixir")
      assert Post.matches_query?(post, "ELIXIR")
      assert Post.matches_query?(post, "Tutorial")
    end

    test "matches query in body (case-insensitive)" do
      post = Post.new(1, "Title", "Learn Phoenix Framework", nil)

      assert Post.matches_query?(post, "phoenix")
      assert Post.matches_query?(post, "FRAMEWORK")
      assert Post.matches_query?(post, "learn")
    end

    test "matches query in tags (case-insensitive)" do
      post = Post.new(1, "Title", "Body", ["elixir", "tutorial"])

      assert Post.matches_query?(post, "elixir")
      assert Post.matches_query?(post, "TUTORIAL")
    end

    test "returns false when no match" do
      post = Post.new(1, "Title", "Body", ["tag"])

      refute Post.matches_query?(post, "nonexistent")
      refute Post.matches_query?(post, "xyz")
    end

    test "handles posts without tags" do
      post = Post.new(1, "Title", "Body", nil)

      assert Post.matches_query?(post, "title")
      refute Post.matches_query?(post, "nonexistent")
    end
  end

  describe "has_tag?/2" do
    test "returns true when post has the tag (case-insensitive)" do
      post = Post.new(1, "Title", "Body", ["elixir", "tutorial"])

      assert Post.has_tag?(post, "elixir")
      assert Post.has_tag?(post, "ELIXIR")
      assert Post.has_tag?(post, "Tutorial")
    end

    test "returns false when post doesn't have the tag" do
      post = Post.new(1, "Title", "Body", ["elixir"])

      refute Post.has_tag?(post, "ruby")
      refute Post.has_tag?(post, "python")
    end

    test "returns false when post has no tags" do
      post = Post.new(1, "Title", "Body", nil)

      refute Post.has_tag?(post, "any")
    end

    test "returns false when post has empty tags list" do
      post = Post.new(1, "Title", "Body", [])

      refute Post.has_tag?(post, "any")
    end
  end
end
