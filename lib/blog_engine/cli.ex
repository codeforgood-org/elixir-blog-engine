defmodule BlogEngine.CLI do
  @moduledoc """
  Command-line interface for the BlogEngine application.

  Provides an interactive REPL for managing blog posts with commands
  for creating, listing, viewing, editing, deleting, and searching posts.
  """

  alias BlogEngine.Post

  @commands [
    {"new", "Create a new post"},
    {"list", "List all posts"},
    {"view <id>", "View a post by ID"},
    {"edit <id>", "Edit a post by ID"},
    {"delete <id>", "Delete a post by ID"},
    {"search <query>", "Search posts by keyword"},
    {"tag <tag>", "List posts with a specific tag"},
    {"tags", "Show all tags and their counts"},
    {"export <path>", "Export all posts to a file"},
    {"import <path>", "Import posts from a file"},
    {"stats", "Show blog statistics"},
    {"help", "Show this help message"},
    {"quit", "Exit the application"}
  ]

  @doc """
  Main entry point for the escript.
  """
  def main(_args) do
    start()
  end

  @doc """
  Starts the interactive blog engine CLI.
  """
  def start do
    print_welcome()
    state = BlogEngine.init()
    loop(state)
  end

  # Main REPL loop
  defp loop(state) do
    command = get_input("\n> ")

    case parse_command(command) do
      {:new, []} ->
        {new_state, _post} = handle_new(state)
        loop(new_state)

      {:list, []} ->
        handle_list(state, nil)
        loop(state)

      {:view, [id]} ->
        handle_view(state, id)
        loop(state)

      {:edit, [id]} ->
        new_state = handle_edit(state, id)
        loop(new_state)

      {:delete, [id]} ->
        new_state = handle_delete(state, id)
        loop(new_state)

      {:search, query_parts} ->
        query = Enum.join(query_parts, " ")
        handle_search(state, query)
        loop(state)

      {:tag, [tag]} ->
        handle_list_by_tag(state, tag)
        loop(state)

      {:tags, []} ->
        handle_tags(state)
        loop(state)

      {:export, [path]} ->
        handle_export(state, path)
        loop(state)

      {:import, [path]} ->
        new_state = handle_import(state, path)
        loop(new_state)

      {:stats, []} ->
        handle_stats(state)
        loop(state)

      {:help, []} ->
        print_help()
        loop(state)

      {:quit, []} ->
        print_goodbye()
        :ok

      {:error, :invalid_command} ->
        IO.puts("❌ Invalid command. Type 'help' for available commands.")
        loop(state)

      {:error, :missing_args} ->
        IO.puts("❌ Missing required arguments. Type 'help' for usage.")
        loop(state)
    end
  end

  # Command handlers

  defp handle_new(state) do
    IO.puts("\n=== Create New Post ===")
    title = get_input("Title: ")
    body = get_multiline_input("Body (empty line to finish):\n")
    tags = get_tags_input()

    {new_state, post} = BlogEngine.create_post(state, title, body, tags)
    IO.puts("\n✓ Post created successfully with ID #{post.id}")

    new_state
  end

  defp handle_list(state, tag) do
    posts = BlogEngine.list_posts(state, tag)

    if Enum.empty?(posts) do
      IO.puts("\nNo posts found.")
    else
      header = if tag, do: "\n=== Posts tagged with '#{tag}' ===", else: "\n=== All Posts ==="
      IO.puts(header)
      IO.puts(String.duplicate("-", 80))

      Enum.each(posts, fn post ->
        display_post_summary(post)
      end)

      IO.puts(String.duplicate("-", 80))
      IO.puts("Total: #{length(posts)} post(s)")
    end
  end

  defp handle_view(state, id_str) do
    case parse_id(id_str) do
      {:ok, id} ->
        case BlogEngine.find_post(state, id) do
          {:ok, post} ->
            display_post_full(post)

          {:error, :not_found} ->
            IO.puts("❌ Post not found.")
        end

      :error ->
        IO.puts("❌ Invalid post ID.")
    end
  end

  defp handle_edit(state, id_str) do
    case parse_id(id_str) do
      {:ok, id} ->
        case BlogEngine.find_post(state, id) do
          {:ok, post} ->
            IO.puts("\n=== Edit Post ##{id} ===")
            IO.puts("(Leave blank to keep current value)\n")

            title = get_optional_input("Title [#{post.title}]: ", post.title)
            body = get_optional_multiline_input("Body (empty line to finish, 'keep' to keep current):\n", post.body)
            tags = get_optional_tags_input(post.tags)

            case BlogEngine.update_post(state, id, title: title, body: body, tags: tags) do
              {:ok, new_state, _updated_post} ->
                IO.puts("\n✓ Post updated successfully")
                new_state

              {:error, :not_found} ->
                IO.puts("❌ Post not found.")
                state
            end

          {:error, :not_found} ->
            IO.puts("❌ Post not found.")
            state
        end

      :error ->
        IO.puts("❌ Invalid post ID.")
        state
    end
  end

  defp handle_delete(state, id_str) do
    case parse_id(id_str) do
      {:ok, id} ->
        case BlogEngine.find_post(state, id) do
          {:ok, post} ->
            IO.puts("\nAre you sure you want to delete '#{post.title}'? (yes/no)")
            confirmation = get_input("> ")

            if String.downcase(confirmation) == "yes" do
              case BlogEngine.delete_post(state, id) do
                {:ok, new_state} ->
                  IO.puts("✓ Post deleted successfully")
                  new_state

                {:error, :not_found} ->
                  IO.puts("❌ Post not found.")
                  state
              end
            else
              IO.puts("Deletion cancelled.")
              state
            end

          {:error, :not_found} ->
            IO.puts("❌ Post not found.")
            state
        end

      :error ->
        IO.puts("❌ Invalid post ID.")
        state
    end
  end

  defp handle_search(state, query) do
    posts = BlogEngine.search_posts(state, query)

    if Enum.empty?(posts) do
      IO.puts("\nNo posts found matching '#{query}'")
    else
      IO.puts("\n=== Search Results for '#{query}' ===")
      IO.puts(String.duplicate("-", 80))

      Enum.each(posts, fn post ->
        display_post_summary(post)
      end)

      IO.puts(String.duplicate("-", 80))
      IO.puts("Found: #{length(posts)} post(s)")
    end
  end

  defp handle_list_by_tag(state, tag) do
    handle_list(state, tag)
  end

  defp handle_tags(state) do
    tags = BlogEngine.get_all_tags(state)

    if Enum.empty?(tags) do
      IO.puts("\nNo tags found.")
    else
      IO.puts("\n=== All Tags ===")
      IO.puts(String.duplicate("-", 40))

      Enum.each(tags, fn {tag, count} ->
        IO.puts("  #{tag} (#{count})")
      end)

      IO.puts(String.duplicate("-", 40))
      IO.puts("Total: #{length(tags)} tag(s)")
    end
  end

  defp handle_export(state, path) do
    case BlogEngine.export_posts(state, path) do
      :ok ->
        IO.puts("✓ Posts exported successfully to #{path}")

      {:error, reason} ->
        IO.puts("❌ Failed to export posts: #{inspect(reason)}")
    end
  end

  defp handle_import(state, path) do
    case BlogEngine.import_posts(state, path) do
      {:ok, new_state} ->
        IO.puts("✓ Posts imported successfully from #{path}")
        new_state

      {:error, reason} ->
        IO.puts("❌ Failed to import posts: #{inspect(reason)}")
        state
    end
  end

  defp handle_stats(state) do
    posts = state.posts
    total_posts = length(posts)

    if total_posts == 0 do
      IO.puts("\nNo posts yet. Create your first post with 'new'!")
    else
      total_words = Enum.reduce(posts, 0, fn post, acc ->
        acc + length(String.split(post.body))
      end)

      avg_words = div(total_words, total_posts)
      tags_count = BlogEngine.get_all_tags(state) |> length()

      oldest_post = Enum.min_by(posts, & &1.created_at, DateTime)
      newest_post = Enum.max_by(posts, & &1.created_at, DateTime)

      IO.puts("\n=== Blog Statistics ===")
      IO.puts("Total posts: #{total_posts}")
      IO.puts("Total words: #{total_words}")
      IO.puts("Average words per post: #{avg_words}")
      IO.puts("Total unique tags: #{tags_count}")
      IO.puts("Oldest post: #{oldest_post.title} (#{Post.format_date(oldest_post.created_at)})")
      IO.puts("Newest post: #{newest_post.title} (#{Post.format_date(newest_post.created_at)})")
    end
  end

  # Display helpers

  defp display_post_summary(post) do
    tags_str = format_tags(post.tags)
    date_str = Post.format_date(post.created_at)
    updated_str = if post.updated_at, do: " [edited]", else: ""

    IO.puts("\n[#{post.id}] #{post.title}#{updated_str}")
    IO.puts("    #{date_str}#{tags_str}")
  end

  defp display_post_full(post) do
    IO.puts("\n" <> String.duplicate("=", 80))
    IO.puts("Post ##{post.id}")
    IO.puts(String.duplicate("=", 80))
    IO.puts("Title: #{post.title}")
    IO.puts("Created: #{Post.format_date(post.created_at)}")

    if post.updated_at do
      IO.puts("Updated: #{Post.format_date(post.updated_at)}")
    end

    if post.tags && !Enum.empty?(post.tags) do
      IO.puts("Tags: #{Enum.join(post.tags, ", ")}")
    end

    IO.puts("\n#{post.body}")
    IO.puts(String.duplicate("=", 80))
  end

  defp format_tags(nil), do: ""
  defp format_tags([]), do: ""
  defp format_tags(tags), do: " | Tags: #{Enum.join(tags, ", ")}"

  # Input helpers

  defp get_input(prompt) do
    IO.gets(prompt) |> String.trim()
  end

  defp get_multiline_input(prompt) do
    IO.puts(prompt)
    read_multiline([])
  end

  defp read_multiline(lines) do
    case IO.gets("") |> String.trim_trailing("\n") do
      "" ->
        lines |> Enum.reverse() |> Enum.join("\n")

      line ->
        read_multiline([line | lines])
    end
  end

  defp get_optional_input(prompt, default) do
    case get_input(prompt) do
      "" -> default
      value -> value
    end
  end

  defp get_optional_multiline_input(prompt, default) do
    IO.puts(prompt)

    case IO.gets("") |> String.trim() do
      "" -> default
      "keep" -> default
      first_line -> read_multiline([first_line])
    end
  end

  defp get_tags_input do
    tags_str = get_input("Tags (comma-separated, optional): ")

    case String.trim(tags_str) do
      "" ->
        nil

      tags ->
        tags
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))
    end
  end

  defp get_optional_tags_input(current_tags) do
    current_str = if current_tags, do: Enum.join(current_tags, ", "), else: "none"
    tags_str = get_input("Tags [#{current_str}] (comma-separated): ")

    case String.trim(tags_str) do
      "" ->
        current_tags

      tags ->
        tags
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))
        |> case do
          [] -> nil
          list -> list
        end
    end
  end

  # Command parsing

  defp parse_command(input) do
    parts = String.split(input, " ", trim: true)

    case parts do
      [] -> {:error, :invalid_command}
      ["new"] -> {:new, []}
      ["list"] -> {:list, []}
      ["view", id] -> {:view, [id]}
      ["edit", id] -> {:edit, [id]}
      ["delete", id] -> {:delete, [id]}
      ["search" | query] when length(query) > 0 -> {:search, query}
      ["tag", tag] -> {:tag, [tag]}
      ["tags"] -> {:tags, []}
      ["export", path] -> {:export, [path]}
      ["import", path] -> {:import, [path]}
      ["stats"] -> {:stats, []}
      ["help"] -> {:help, []}
      ["quit"] -> {:quit, []}
      ["exit"] -> {:quit, []}
      _ -> {:error, :invalid_command}
    end
  end

  defp parse_id(id_str) do
    case Integer.parse(id_str) do
      {id, ""} -> {:ok, id}
      _ -> :error
    end
  end

  # UI helpers

  defp print_welcome do
    IO.puts("\n" <> String.duplicate("=", 80))
    IO.puts("  Welcome to BlogEngine - A Powerful CLI Blog Manager")
    IO.puts(String.duplicate("=", 80))
    IO.puts("\nType 'help' to see available commands or 'new' to create your first post.")
  end

  defp print_help do
    IO.puts("\n=== Available Commands ===\n")

    Enum.each(@commands, fn {cmd, desc} ->
      IO.puts("  #{String.pad_trailing(cmd, 20)} - #{desc}")
    end)

    IO.puts("")
  end

  defp print_goodbye do
    IO.puts("\nThank you for using BlogEngine. Goodbye!")
  end
end
