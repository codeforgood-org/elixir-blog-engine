defmodule BlogEngine.Post do
  @moduledoc """
  Represents a blog post with all its metadata.

  A post contains an ID, title, body content, optional tags,
  creation timestamp, and last updated timestamp.
  """

  @enforce_keys [:id, :title, :body, :created_at]
  defstruct [:id, :title, :body, :tags, :created_at, :updated_at]

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          title: String.t(),
          body: String.t(),
          tags: list(String.t()) | nil,
          created_at: DateTime.t(),
          updated_at: DateTime.t() | nil
        }

  @doc """
  Creates a new post with the given attributes.

  ## Examples

      iex> BlogEngine.Post.new(1, "Hello", "World", ["elixir"])
      %BlogEngine.Post{
        id: 1,
        title: "Hello",
        body: "World",
        tags: ["elixir"],
        created_at: ~U[2025-01-01 00:00:00Z]
      }
  """
  @spec new(non_neg_integer(), String.t(), String.t(), list(String.t()) | nil) :: t()
  def new(id, title, body, tags \\ nil) do
    %__MODULE__{
      id: id,
      title: title,
      body: body,
      tags: tags,
      created_at: DateTime.utc_now(),
      updated_at: nil
    }
  end

  @doc """
  Updates a post with new title and/or body and/or tags.
  Sets the updated_at timestamp to now.

  ## Examples

      iex> post = BlogEngine.Post.new(1, "Old", "Content", [])
      iex> BlogEngine.Post.update(post, title: "New")
      %BlogEngine.Post{title: "New", updated_at: ~U[2025-01-01 00:00:01Z]}
  """
  @spec update(t(), keyword()) :: t()
  def update(post, attrs) do
    post
    |> struct(attrs)
    |> Map.put(:updated_at, DateTime.utc_now())
  end

  @doc """
  Formats a post's created_at or updated_at timestamp for display.
  """
  @spec format_date(DateTime.t()) :: String.t()
  def format_date(datetime) do
    datetime
    |> DateTime.to_string()
    |> String.slice(0..18)
  end

  @doc """
  Returns a short preview of the post (title and first 100 chars of body).
  """
  @spec preview(t()) :: String.t()
  def preview(%__MODULE__{title: title, body: body}) do
    body_preview =
      body
      |> String.slice(0..99)
      |> then(fn preview ->
        if String.length(body) > 100, do: preview <> "...", else: preview
      end)

    "#{title}\n#{body_preview}"
  end

  @doc """
  Checks if a post matches a search query.
  Searches in title, body, and tags (case-insensitive).
  """
  @spec matches_query?(t(), String.t()) :: boolean()
  def matches_query?(%__MODULE__{title: title, body: body, tags: tags}, query) do
    query_lower = String.downcase(query)

    String.contains?(String.downcase(title), query_lower) or
      String.contains?(String.downcase(body), query_lower) or
      (tags && Enum.any?(tags, fn tag -> String.contains?(String.downcase(tag), query_lower) end))
  end

  @doc """
  Checks if a post has a specific tag (case-insensitive).
  """
  @spec has_tag?(t(), String.t()) :: boolean()
  def has_tag?(%__MODULE__{tags: nil}, _tag), do: false

  def has_tag?(%__MODULE__{tags: tags}, tag) do
    tag_lower = String.downcase(tag)
    Enum.any?(tags, fn t -> String.downcase(t) == tag_lower end)
  end
end
