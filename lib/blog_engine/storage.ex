defmodule BlogEngine.Storage do
  @moduledoc """
  Handles persistent storage of blog posts to JSON files.

  Posts are stored in the priv/data directory and automatically
  loaded on application start.
  """

  alias BlogEngine.Post

  @storage_dir "priv/data"
  @storage_file "#{@storage_dir}/posts.json"

  @doc """
  Loads all posts from the storage file.
  Returns an empty list if the file doesn't exist.
  """
  @spec load_posts() :: list(Post.t())
  def load_posts do
    case File.read(@storage_file) do
      {:ok, content} ->
        content
        |> Jason.decode!()
        |> Enum.map(&deserialize_post/1)

      {:error, :enoent} ->
        []

      {:error, reason} ->
        IO.puts("Warning: Failed to load posts: #{inspect(reason)}")
        []
    end
  end

  @doc """
  Saves all posts to the storage file.
  Creates the storage directory if it doesn't exist.
  """
  @spec save_posts(list(Post.t())) :: :ok | {:error, term()}
  def save_posts(posts) do
    File.mkdir_p(@storage_dir)

    posts_json =
      posts
      |> Enum.map(&serialize_post/1)
      |> Jason.encode!(pretty: true)

    File.write(@storage_file, posts_json)
  end

  @doc """
  Exports posts to a specified file path.
  """
  @spec export_posts(list(Post.t()), String.t()) :: :ok | {:error, term()}
  def export_posts(posts, path) do
    posts_json =
      posts
      |> Enum.map(&serialize_post/1)
      |> Jason.encode!(pretty: true)

    File.write(path, posts_json)
  end

  @doc """
  Imports posts from a specified file path.
  """
  @spec import_posts(String.t()) :: {:ok, list(Post.t())} | {:error, term()}
  def import_posts(path) do
    case File.read(path) do
      {:ok, content} ->
        posts =
          content
          |> Jason.decode!()
          |> Enum.map(&deserialize_post/1)

        {:ok, posts}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Private functions

  defp serialize_post(%Post{} = post) do
    %{
      "id" => post.id,
      "title" => post.title,
      "body" => post.body,
      "tags" => post.tags,
      "created_at" => DateTime.to_iso8601(post.created_at),
      "updated_at" => post.updated_at && DateTime.to_iso8601(post.updated_at)
    }
  end

  defp deserialize_post(data) do
    {:ok, created_at, 0} = DateTime.from_iso8601(data["created_at"])

    updated_at =
      case data["updated_at"] do
        nil -> nil
        timestamp -> DateTime.from_iso8601(timestamp) |> elem(1)
      end

    %Post{
      id: data["id"],
      title: data["title"],
      body: data["body"],
      tags: data["tags"],
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
