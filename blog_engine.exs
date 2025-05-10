defmodule BlogEngine do
  defmodule Post do
    defstruct [:id, :title, :body, :created_at]
  end

  def start do
    IO.puts("Welcome to the Elixir Blog Engine CLI")
    loop([], 1)
  end

  defp loop(posts, next_id) do
    IO.puts("\nAvailable commands:")
    IO.puts("  new         - Create a new post")
    IO.puts("  list        - List all posts")
    IO.puts("  view [id]   - View a post by ID")
    IO.puts("  delete [id] - Delete a post by ID")
    IO.puts("  quit        - Exit the app")

    case IO.gets("\nCommand> ") |> String.trim() do
      "new" ->
        {post, new_id} = create_post(next_id)
        loop([post | posts], new_id)

      "list" ->
        list_posts(posts)
        loop(posts, next_id)

      "quit" ->
        IO.puts("Goodbye!")

      cmd when String.starts_with?(cmd, "view ") ->
        [_ | [id_str]] = String.split(cmd)
        view_post(posts, String.to_integer(id_str))
        loop(posts, next_id)

      cmd when String.starts_with?(cmd, "delete ") ->
        [_ | [id_str]] = String.split(cmd)
        updated_posts = delete_post(posts, String.to_integer(id_str))
        loop(updated_posts, next_id)

      _ ->
        IO.puts("Invalid command.")
        loop(posts, next_id)
    end
  end

  defp create_post(id) do
    title = IO.gets("Title: ") |> String.trim()
    body = IO.gets("Body: ") |> String.trim()
    created_at = DateTime.utc_now() |> DateTime.to_string()

    post = %Post{
      id: id,
      title: title,
      body: body,
      created_at: created_at
    }

    IO.puts("Post created with ID #{id}.")
    {post, id + 1}
  end

  defp list_posts([]) do
    IO.puts("No posts available.")
  end

  defp list_posts(posts) do
    IO.puts("\nPosts:")
    Enum.each(Enum.reverse(posts), fn post ->
      IO.puts("  [#{post.id}] #{post.title} (#{post.created_at})")
    end)
  end

  defp view_post(posts, id) do
    case Enum.find(posts, fn p -> p.id == id end) do
      nil ->
        IO.puts("Post not found.")
      post ->
        IO.puts("\n--- Post ##{post.id} ---")
        IO.puts("Title: #{post.title}")
        IO.puts("Created: #{post.created_at}")
        IO.puts("Body:\n#{post.body}")
    end
  end

  defp delete_post(posts, id) do
    case Enum.find(posts, fn p -> p.id == id end) do
      nil ->
        IO.puts("Post not found.")
        posts
      _ ->
        IO.puts("Post #{id} deleted.")
        Enum.reject(posts, fn p -> p.id == id end)
    end
  end
end

BlogEngine.start()
