defmodule Ckochx.Blog do
  @moduledoc """
  Blog module for handling flat file blog posts.
  Supports both markdown (.md) and HTML (.html) files.
  """

  @posts_dir "priv/blog/posts"

  defmodule Post do
    @moduledoc "Struct representing a blog post"

    defstruct [
      :slug,
      :title,
      :date,
      :author,
      :excerpt,
      :content,
      :file_path
    ]
  end

  @doc "Get all blog posts, sorted by date (newest first)"
  def list_posts do
    @posts_dir
    |> File.ls!()
    |> Enum.filter(&valid_post_file?/1)
    |> Enum.map(&load_post/1)
    |> Enum.filter(& &1)
    |> Enum.sort_by(& &1.date, {:desc, Date})
  end

  @doc "Get a single blog post by slug"
  def get_post(slug) do
    @posts_dir
    |> File.ls!()
    |> Enum.filter(&valid_post_file?/1)
    |> Enum.find(&(Path.rootname(&1) == slug))
    |> case do
      nil -> nil
      filename -> load_post(filename)
    end
  end

  # Private functions

  defp valid_post_file?(filename) do
    Path.extname(filename) in [".md", ".html"]
  end

  defp load_post(filename) do
    file_path = Path.join(@posts_dir, filename)

    case File.read(file_path) do
      {:ok, content} ->
        parse_post(filename, content, file_path)

      {:error, _reason} ->
        nil
    end
  end

  defp parse_post(filename, content, file_path) do
    slug = Path.rootname(filename)
    extension = Path.extname(filename)

    case extension do
      ".md" -> parse_markdown_post(slug, content, file_path)
      ".html" -> parse_html_post(slug, content, file_path)
    end
  end

  defp parse_markdown_post(slug, content, file_path) do
    case parse_frontmatter(content) do
      {metadata, body} ->
        case Earmark.as_html(body) do
          {:ok, html_content, _warnings} ->
            create_post(slug, metadata, html_content, file_path)

          {:error, _html, _errors} ->
            nil
        end

      nil ->
        nil
    end
  end

  defp parse_html_post(slug, content, file_path) do
    case parse_html_metadata(content) do
      {metadata, body} ->
        create_post(slug, metadata, body, file_path)

      nil ->
        # If no metadata found, create basic post
        create_post(slug, %{}, content, file_path)
    end
  end

  defp parse_frontmatter(content) do
    case String.split(content, ~r/^---$/m, parts: 3) do
      ["", yaml_content, markdown_content] ->
        case parse_yaml_metadata(yaml_content) do
          {:ok, metadata} -> {metadata, String.trim(markdown_content)}
          {:error, _} -> nil
        end

      _ ->
        nil
    end
  end

  defp parse_html_metadata(content) do
    # Look for HTML comment with metadata at the start
    case Regex.run(~r/^<!--\s*(.*?)\s*-->\s*(.*)$/s, content) do
      [_, metadata_content, body] ->
        case parse_metadata_lines(metadata_content) do
          {:ok, metadata} -> {metadata, String.trim(body)}
          {:error, _} -> nil
        end

      _ ->
        nil
    end
  end

  defp parse_yaml_metadata(yaml_content) do
    try do
      # Simple YAML parsing for basic key: value pairs
      metadata =
        yaml_content
        |> String.split("\n")
        |> Enum.reduce(%{}, fn line, acc ->
          case String.split(line, ":", parts: 2) do
            [key, value] ->
              clean_key = String.trim(key)
              clean_value = value |> String.trim() |> String.trim("\"")
              Map.put(acc, clean_key, clean_value)

            _ ->
              acc
          end
        end)

      {:ok, metadata}
    rescue
      _ -> {:error, :invalid_yaml}
    end
  end

  defp parse_metadata_lines(metadata_content) do
    try do
      metadata =
        metadata_content
        |> String.split("\n")
        |> Enum.reduce(%{}, fn line, acc ->
          case String.split(line, ":", parts: 2) do
            [key, value] ->
              clean_key = String.trim(key)
              clean_value = value |> String.trim() |> String.trim("\"")
              Map.put(acc, clean_key, clean_value)

            _ ->
              acc
          end
        end)

      {:ok, metadata}
    rescue
      _ -> {:error, :invalid_metadata}
    end
  end

  defp create_post(slug, metadata, content, file_path) do
    %Post{
      slug: slug,
      title: Map.get(metadata, "title", slug |> String.replace("-", " ") |> String.capitalize()),
      date: parse_date(Map.get(metadata, "date")),
      author: Map.get(metadata, "author", "Anonymous"),
      excerpt: Map.get(metadata, "excerpt", ""),
      content: content,
      file_path: file_path
    }
  end

  defp parse_date(nil), do: Date.utc_today()

  defp parse_date(date_string) when is_binary(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> date
      {:error, _} -> Date.utc_today()
    end
  end

  defp parse_date(_), do: Date.utc_today()
end
