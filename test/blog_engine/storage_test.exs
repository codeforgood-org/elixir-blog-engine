defmodule BlogEngine.StorageTest do
  use ExUnit.Case

  alias BlogEngine.{Post, Storage}

  setup do
    # Clean up storage before and after each test
    File.rm_rf("priv/data")
    on_exit(fn -> File.rm_rf("priv/data") end)
    :ok
  end

  describe "load_posts/0" do
    test "returns empty list when no storage file exists" do
      posts = Storage.load_posts()
      assert posts == []
    end

    test "loads posts from storage file" do
      post1 = Post.new(1, "Title 1", "Body 1", ["tag1"])
      post2 = Post.new(2, "Title 2", "Body 2", nil)

      Storage.save_posts([post1, post2])
      loaded_posts = Storage.load_posts()

      assert length(loaded_posts) == 2
      assert Enum.any?(loaded_posts, fn p -> p.title == "Title 1" end)
      assert Enum.any?(loaded_posts, fn p -> p.title == "Title 2" end)
    end

    test "preserves all post fields" do
      original_post = Post.new(1, "Title", "Body", ["tag1", "tag2"])
      updated_post = Post.update(original_post, title: "Updated")

      Storage.save_posts([updated_post])
      [loaded_post] = Storage.load_posts()

      assert loaded_post.id == updated_post.id
      assert loaded_post.title == updated_post.title
      assert loaded_post.body == updated_post.body
      assert loaded_post.tags == updated_post.tags
      assert DateTime.compare(loaded_post.created_at, updated_post.created_at) == :eq
      assert DateTime.compare(loaded_post.updated_at, updated_post.updated_at) == :eq
    end

    test "handles posts without tags" do
      post = Post.new(1, "Title", "Body", nil)

      Storage.save_posts([post])
      [loaded_post] = Storage.load_posts()

      assert loaded_post.tags == nil
    end

    test "handles posts without updated_at" do
      post = Post.new(1, "Title", "Body", nil)

      Storage.save_posts([post])
      [loaded_post] = Storage.load_posts()

      assert loaded_post.updated_at == nil
    end
  end

  describe "save_posts/1" do
    test "creates storage directory if it doesn't exist" do
      refute File.exists?("priv/data")

      post = Post.new(1, "Title", "Body", nil)
      Storage.save_posts([post])

      assert File.exists?("priv/data")
      assert File.exists?("priv/data/posts.json")
    end

    test "saves posts to JSON file" do
      post = Post.new(1, "Title", "Body", ["tag"])
      Storage.save_posts([post])

      assert File.exists?("priv/data/posts.json")
      {:ok, content} = File.read("priv/data/posts.json")
      data = Jason.decode!(content)

      assert is_list(data)
      assert length(data) == 1
    end

    test "overwrites existing file" do
      post1 = Post.new(1, "Title 1", "Body 1", nil)
      post2 = Post.new(2, "Title 2", "Body 2", nil)

      Storage.save_posts([post1])
      Storage.save_posts([post2])

      loaded_posts = Storage.load_posts()
      assert length(loaded_posts) == 1
      assert Enum.at(loaded_posts, 0).title == "Title 2"
    end

    test "saves empty list" do
      Storage.save_posts([])

      loaded_posts = Storage.load_posts()
      assert loaded_posts == []
    end
  end

  describe "export_posts/2" do
    test "exports posts to specified file" do
      post1 = Post.new(1, "Title 1", "Body 1", ["tag1"])
      post2 = Post.new(2, "Title 2", "Body 2", nil)

      export_path = "test_export.json"
      assert :ok = Storage.export_posts([post1, post2], export_path)

      assert File.exists?(export_path)
      {:ok, content} = File.read(export_path)
      data = Jason.decode!(content)

      assert length(data) == 2

      # Clean up
      File.rm(export_path)
    end

    test "creates pretty-printed JSON" do
      post = Post.new(1, "Title", "Body", nil)
      export_path = "test_export.json"

      Storage.export_posts([post], export_path)

      {:ok, content} = File.read(export_path)
      # Pretty-printed JSON should have newlines
      assert String.contains?(content, "\n")

      # Clean up
      File.rm(export_path)
    end
  end

  describe "import_posts/1" do
    test "imports posts from specified file" do
      post1 = Post.new(1, "Title 1", "Body 1", ["tag1"])
      post2 = Post.new(2, "Title 2", "Body 2", nil)

      export_path = "test_import.json"
      Storage.export_posts([post1, post2], export_path)

      assert {:ok, imported_posts} = Storage.import_posts(export_path)

      assert length(imported_posts) == 2
      assert Enum.any?(imported_posts, fn p -> p.title == "Title 1" end)
      assert Enum.any?(imported_posts, fn p -> p.title == "Title 2" end)

      # Clean up
      File.rm(export_path)
    end

    test "returns error for non-existent file" do
      assert {:error, :enoent} = Storage.import_posts("nonexistent.json")
    end

    test "preserves all post fields during import" do
      original_post = Post.new(1, "Title", "Body", ["tag1", "tag2"])
      updated_post = Post.update(original_post, title: "Updated")

      export_path = "test_import.json"
      Storage.export_posts([updated_post], export_path)

      {:ok, [imported_post]} = Storage.import_posts(export_path)

      assert imported_post.id == updated_post.id
      assert imported_post.title == updated_post.title
      assert imported_post.body == updated_post.body
      assert imported_post.tags == updated_post.tags
      # Timestamps should be preserved
      assert DateTime.compare(imported_post.created_at, updated_post.created_at) == :eq
      assert DateTime.compare(imported_post.updated_at, updated_post.updated_at) == :eq

      # Clean up
      File.rm(export_path)
    end
  end

  describe "round-trip save and load" do
    test "data integrity is maintained through save/load cycle" do
      original_posts = [
        Post.new(1, "Post 1", "Body 1", ["tag1", "tag2"]),
        Post.new(2, "Post 2", "Body 2", nil),
        Post.new(3, "Post 3", "Body 3", ["tag3"])
      ]

      # Update one post to test updated_at preservation
      original_posts = List.update_at(original_posts, 1, fn post ->
        Post.update(post, title: "Updated Post 2")
      end)

      Storage.save_posts(original_posts)
      loaded_posts = Storage.load_posts()

      assert length(loaded_posts) == length(original_posts)

      # Check each post
      Enum.each(original_posts, fn original ->
        loaded = Enum.find(loaded_posts, fn p -> p.id == original.id end)

        assert loaded != nil
        assert loaded.title == original.title
        assert loaded.body == original.body
        assert loaded.tags == original.tags
        assert DateTime.compare(loaded.created_at, original.created_at) == :eq

        if original.updated_at do
          assert DateTime.compare(loaded.updated_at, original.updated_at) == :eq
        else
          assert loaded.updated_at == nil
        end
      end)
    end
  end
end
