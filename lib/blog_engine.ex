defmodule BlogEngine do
  @moduledoc """
  BlogEngine - A powerful CLI blog engine built with Elixir.

  This module provides core functionality for managing blog posts including
  creating, reading, updating, deleting, searching, and organizing posts with tags.
  """

  alias BlogEngine.{Post, Storage}

  @type post_id :: non_neg_integer()
  @type posts :: list(Post.t())
  @type state :: %{posts: posts(), next_id: post_id()}

  @doc """
  Initializes the blog engine by loading existing posts from storage.
  Returns the initial state with posts and next available ID.
  """
  @spec init() :: state()
  def init do
    posts = Storage.load_posts()

    next_id =
      case posts do
        [] -> 1
        _ -> (posts |> Enum.map(& &1.id) |> Enum.max()) + 1
      end

    %{posts: posts, next_id: next_id}
  end

  @doc """
  Creates a new post with the given title, body, and optional tags.
  Returns the updated state and the created post.
  """
  @spec create_post(state(), String.t(), String.t(), list(String.t()) | nil) ::
          {state(), Post.t()}
  def create_post(%{posts: posts, next_id: id} = _state, title, body, tags \\ nil) do
    post = Post.new(id, title, body, tags)
    new_posts = [post | posts]
    Storage.save_posts(new_posts)

    {%{posts: new_posts, next_id: id + 1}, post}
  end

  @doc """
  Lists all posts, optionally filtered by tag.
  Returns posts sorted by creation date (newest first).
  """
  @spec list_posts(state(), String.t() | nil) :: posts()
  def list_posts(%{posts: posts}, tag \\ nil) do
    posts
    |> maybe_filter_by_tag(tag)
    |> Enum.sort_by(& &1.created_at, {:desc, DateTime})
  end

  @doc """
  Finds a post by its ID.
  Returns {:ok, post} or {:error, :not_found}.
  """
  @spec find_post(state(), post_id()) :: {:ok, Post.t()} | {:error, :not_found}
  def find_post(%{posts: posts}, id) do
    case Enum.find(posts, fn p -> p.id == id end) do
      nil -> {:error, :not_found}
      post -> {:ok, post}
    end
  end

  @doc """
  Updates a post with new attributes.
  Returns {:ok, updated_state, updated_post} or {:error, :not_found}.
  """
  @spec update_post(state(), post_id(), keyword()) ::
          {:ok, state(), Post.t()} | {:error, :not_found}
  def update_post(%{posts: posts} = state, id, attrs) do
    case Enum.find_index(posts, fn p -> p.id == id end) do
      nil ->
        {:error, :not_found}

      index ->
        old_post = Enum.at(posts, index)
        updated_post = Post.update(old_post, attrs)
        new_posts = List.replace_at(posts, index, updated_post)
        Storage.save_posts(new_posts)

        new_state = %{state | posts: new_posts}
        {:ok, new_state, updated_post}
    end
  end

  @doc """
  Deletes a post by its ID.
  Returns {:ok, updated_state} or {:error, :not_found}.
  """
  @spec delete_post(state(), post_id()) :: {:ok, state()} | {:error, :not_found}
  def delete_post(%{posts: posts} = state, id) do
    case Enum.find(posts, fn p -> p.id == id end) do
      nil ->
        {:error, :not_found}

      _post ->
        new_posts = Enum.reject(posts, fn p -> p.id == id end)
        Storage.save_posts(new_posts)
        {:ok, %{state | posts: new_posts}}
    end
  end

  @doc """
  Searches posts by query string (searches title, body, and tags).
  Returns matching posts sorted by relevance (newest first).
  """
  @spec search_posts(state(), String.t()) :: posts()
  def search_posts(%{posts: posts}, query) do
    posts
    |> Enum.filter(&Post.matches_query?(&1, query))
    |> Enum.sort_by(& &1.created_at, {:desc, DateTime})
  end

  @doc """
  Gets all unique tags from all posts.
  Returns a sorted list of tags with their post counts.
  """
  @spec get_all_tags(state()) :: list({String.t(), non_neg_integer()})
  def get_all_tags(%{posts: posts}) do
    posts
    |> Enum.flat_map(fn post -> post.tags || [] end)
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_tag, count} -> count end, :desc)
  end

  @doc """
  Exports all posts to a file.
  """
  @spec export_posts(state(), String.t()) :: :ok | {:error, term()}
  def export_posts(%{posts: posts}, path) do
    Storage.export_posts(posts, path)
  end

  @doc """
  Imports posts from a file and merges with existing posts.
  Assigns new IDs to imported posts to avoid conflicts.
  """
  @spec import_posts(state(), String.t()) :: {:ok, state()} | {:error, term()}
  def import_posts(%{posts: existing_posts, next_id: next_id} = state, path) do
    case Storage.import_posts(path) do
      {:ok, imported_posts} ->
        # Reassign IDs to avoid conflicts
        {new_posts, new_next_id} =
          Enum.reduce(imported_posts, {existing_posts, next_id}, fn post, {acc_posts, acc_id} ->
            new_post = %{post | id: acc_id}
            {[new_post | acc_posts], acc_id + 1}
          end)

        Storage.save_posts(new_posts)
        {:ok, %{state | posts: new_posts, next_id: new_next_id}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Private helper functions

  defp maybe_filter_by_tag(posts, nil), do: posts

  defp maybe_filter_by_tag(posts, tag) do
    Enum.filter(posts, &Post.has_tag?(&1, tag))
  end
end
