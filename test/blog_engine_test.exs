defmodule BlogEngineTest do
  use ExUnit.Case
  doctest BlogEngine

  alias BlogEngine.Post

  setup do
    # Clean up storage before each test
    File.rm_rf("priv/data")
    state = BlogEngine.init()
    {:ok, state: state}
  end

  describe "init/0" do
    test "initializes with empty state when no posts exist" do
      state = BlogEngine.init()
      assert state.posts == []
      assert state.next_id == 1
    end

    test "loads existing posts and sets correct next_id", %{state: initial_state} do
      {state, _post} = BlogEngine.create_post(initial_state, "Test", "Body", nil)

      # Simulate restart by reinitializing
      new_state = BlogEngine.init()
      assert length(new_state.posts) == 1
      assert new_state.next_id == 2
    end
  end

  describe "create_post/4" do
    test "creates a post with all fields", %{state: state} do
      {new_state, post} = BlogEngine.create_post(state, "Title", "Body", ["tag1", "tag2"])

      assert post.id == 1
      assert post.title == "Title"
      assert post.body == "Body"
      assert post.tags == ["tag1", "tag2"]
      assert post.created_at != nil
      assert new_state.next_id == 2
      assert length(new_state.posts) == 1
    end

    test "creates a post without tags", %{state: state} do
      {_new_state, post} = BlogEngine.create_post(state, "Title", "Body", nil)
      assert post.tags == nil
    end

    test "increments next_id correctly", %{state: state} do
      {state, _} = BlogEngine.create_post(state, "Post 1", "Body 1", nil)
      {state, _} = BlogEngine.create_post(state, "Post 2", "Body 2", nil)
      {state, post3} = BlogEngine.create_post(state, "Post 3", "Body 3", nil)

      assert post3.id == 3
      assert state.next_id == 4
    end
  end

  describe "list_posts/2" do
    test "returns empty list when no posts exist", %{state: state} do
      posts = BlogEngine.list_posts(state)
      assert posts == []
    end

    test "returns all posts sorted by date (newest first)", %{state: state} do
      {state, post1} = BlogEngine.create_post(state, "First", "Body", nil)
      :timer.sleep(10)
      {state, post2} = BlogEngine.create_post(state, "Second", "Body", nil)
      :timer.sleep(10)
      {state, post3} = BlogEngine.create_post(state, "Third", "Body", nil)

      posts = BlogEngine.list_posts(state)

      assert length(posts) == 3
      assert Enum.at(posts, 0).id == post3.id
      assert Enum.at(posts, 1).id == post2.id
      assert Enum.at(posts, 2).id == post1.id
    end

    test "filters posts by tag", %{state: state} do
      {state, _} = BlogEngine.create_post(state, "Post 1", "Body", ["elixir"])
      {state, _} = BlogEngine.create_post(state, "Post 2", "Body", ["ruby"])
      {state, _} = BlogEngine.create_post(state, "Post 3", "Body", ["elixir", "phoenix"])

      elixir_posts = BlogEngine.list_posts(state, "elixir")
      ruby_posts = BlogEngine.list_posts(state, "ruby")

      assert length(elixir_posts) == 2
      assert length(ruby_posts) == 1
    end
  end

  describe "find_post/2" do
    test "finds an existing post", %{state: state} do
      {state, created_post} = BlogEngine.create_post(state, "Title", "Body", nil)

      assert {:ok, found_post} = BlogEngine.find_post(state, created_post.id)
      assert found_post.id == created_post.id
      assert found_post.title == created_post.title
    end

    test "returns error for non-existent post", %{state: state} do
      assert {:error, :not_found} = BlogEngine.find_post(state, 999)
    end
  end

  describe "update_post/3" do
    test "updates post title", %{state: state} do
      {state, post} = BlogEngine.create_post(state, "Original", "Body", nil)

      assert {:ok, new_state, updated_post} =
               BlogEngine.update_post(state, post.id, title: "Updated")

      assert updated_post.title == "Updated"
      assert updated_post.body == "Body"
      assert updated_post.updated_at != nil
    end

    test "updates post body", %{state: state} do
      {state, post} = BlogEngine.create_post(state, "Title", "Original", nil)

      assert {:ok, _new_state, updated_post} =
               BlogEngine.update_post(state, post.id, body: "Updated")

      assert updated_post.body == "Updated"
    end

    test "updates post tags", %{state: state} do
      {state, post} = BlogEngine.create_post(state, "Title", "Body", ["old"])

      assert {:ok, _new_state, updated_post} =
               BlogEngine.update_post(state, post.id, tags: ["new1", "new2"])

      assert updated_post.tags == ["new1", "new2"]
    end

    test "returns error for non-existent post", %{state: state} do
      assert {:error, :not_found} = BlogEngine.update_post(state, 999, title: "Test")
    end

    test "persists changes to storage", %{state: state} do
      {state, post} = BlogEngine.create_post(state, "Original", "Body", nil)
      {:ok, _state, _} = BlogEngine.update_post(state, post.id, title: "Updated")

      # Reload from storage
      reloaded_state = BlogEngine.init()
      {:ok, reloaded_post} = BlogEngine.find_post(reloaded_state, post.id)

      assert reloaded_post.title == "Updated"
    end
  end

  describe "delete_post/2" do
    test "deletes an existing post", %{state: state} do
      {state, post} = BlogEngine.create_post(state, "Title", "Body", nil)

      assert {:ok, new_state} = BlogEngine.delete_post(state, post.id)
      assert length(new_state.posts) == 0
      assert {:error, :not_found} = BlogEngine.find_post(new_state, post.id)
    end

    test "returns error for non-existent post", %{state: state} do
      assert {:error, :not_found} = BlogEngine.delete_post(state, 999)
    end

    test "persists deletion to storage", %{state: state} do
      {state, post} = BlogEngine.create_post(state, "Title", "Body", nil)
      {:ok, _state} = BlogEngine.delete_post(state, post.id)

      # Reload from storage
      reloaded_state = BlogEngine.init()
      assert reloaded_state.posts == []
    end
  end

  describe "search_posts/2" do
    setup %{state: state} do
      {state, _} = BlogEngine.create_post(state, "Elixir Tutorial", "Learn Elixir basics", ["elixir"])
      {state, _} = BlogEngine.create_post(state, "Ruby Guide", "Ruby programming guide", ["ruby"])
      {state, _} = BlogEngine.create_post(state, "Phoenix Framework", "Build apps with Phoenix", ["elixir", "phoenix"])

      {:ok, state: state}
    end

    test "finds posts by title", %{state: state} do
      results = BlogEngine.search_posts(state, "Elixir")
      assert length(results) == 1
      assert Enum.at(results, 0).title == "Elixir Tutorial"
    end

    test "finds posts by body content", %{state: state} do
      results = BlogEngine.search_posts(state, "programming")
      assert length(results) == 1
      assert Enum.at(results, 0).title == "Ruby Guide"
    end

    test "finds posts by tag", %{state: state} do
      results = BlogEngine.search_posts(state, "phoenix")
      assert length(results) == 1
      assert Enum.at(results, 0).title == "Phoenix Framework"
    end

    test "search is case-insensitive", %{state: state} do
      results = BlogEngine.search_posts(state, "ELIXIR")
      assert length(results) == 1
    end

    test "returns empty list when no matches", %{state: state} do
      results = BlogEngine.search_posts(state, "javascript")
      assert results == []
    end
  end

  describe "get_all_tags/1" do
    test "returns empty list when no posts have tags", %{state: state} do
      {state, _} = BlogEngine.create_post(state, "Post", "Body", nil)
      tags = BlogEngine.get_all_tags(state)
      assert tags == []
    end

    test "returns all unique tags with counts", %{state: state} do
      {state, _} = BlogEngine.create_post(state, "Post 1", "Body", ["elixir", "tutorial"])
      {state, _} = BlogEngine.create_post(state, "Post 2", "Body", ["elixir", "advanced"])
      {state, _} = BlogEngine.create_post(state, "Post 3", "Body", ["ruby"])

      tags = BlogEngine.get_all_tags(state)

      assert length(tags) == 3
      assert {"elixir", 2} in tags
      assert {"tutorial", 1} in tags
      assert {"advanced", 1} in tags
      assert {"ruby", 1} in tags
    end

    test "tags are sorted by count descending", %{state: state} do
      {state, _} = BlogEngine.create_post(state, "Post 1", "Body", ["popular"])
      {state, _} = BlogEngine.create_post(state, "Post 2", "Body", ["popular"])
      {state, _} = BlogEngine.create_post(state, "Post 3", "Body", ["rare"])

      tags = BlogEngine.get_all_tags(state)

      assert Enum.at(tags, 0) == {"popular", 2}
      assert Enum.at(tags, 1) == {"rare", 1}
    end
  end

  describe "export_posts/2 and import_posts/2" do
    test "exports and imports posts successfully", %{state: state} do
      {state, _} = BlogEngine.create_post(state, "Post 1", "Body 1", ["tag1"])
      {state, _} = BlogEngine.create_post(state, "Post 2", "Body 2", ["tag2"])

      export_path = "test_export.json"

      # Export
      assert :ok = BlogEngine.export_posts(state, export_path)
      assert File.exists?(export_path)

      # Import to new state
      new_state = BlogEngine.init()
      assert {:ok, imported_state} = BlogEngine.import_posts(new_state, export_path)

      # Verify imported posts (IDs will be reassigned)
      assert length(imported_state.posts) == 4  # 2 original + 2 imported

      # Clean up
      File.rm(export_path)
    end

    test "import returns error for non-existent file", %{state: state} do
      assert {:error, :enoent} = BlogEngine.import_posts(state, "nonexistent.json")
    end
  end
end
