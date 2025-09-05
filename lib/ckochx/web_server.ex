defmodule Ckochx.WebServer do
  use Plug.Router

  plug(Plug.Logger)

  plug(Plug.Static,
    at: "/",
    from: "priv/static",
    only: ~w(css js images fonts favicon.ico robots.txt),
    gzip: false
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_file(conn, 200, "priv/static/index.html")
  end

  get "/about" do
    send_file(conn, 200, "priv/static/about.html")
  end

  get "/blog" do
    posts = Ckochx.Blog.list_posts()
    html = render_blog_index(posts)
    send_resp(conn, 200, html)
  end

  get "/blog/:slug" do
    case Ckochx.Blog.get_post(slug) do
      nil ->
        send_resp(conn, 404, "Blog post not found")

      post ->
        html = render_blog_post(post)
        send_resp(conn, 200, html)
    end
  end

  match _ do
    send_resp(conn, 404, "Page not found")
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts \\ []) do
    port = opts[:port] || 4000

    Bandit.start_link(
      plug: __MODULE__,
      port: port,
      scheme: :http
    )
  end

  # Private template rendering functions

  defp render_blog_index(posts) do
    posts_html = Enum.map_join(posts, "\n", &render_post_card/1)

    """
    <!DOCTYPE html>
    <html lang="en" class="scroll-smooth">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Blog - Ckochx Web Server</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {
                darkMode: 'class'
            }
        </script>
    </head>
    <body class="bg-gradient-to-br from-slate-50 to-blue-50 dark:from-gray-900 dark:to-blue-900 min-h-screen transition-colors duration-300">
        #{render_nav("blog")}
        
        <main class="max-w-4xl mx-auto px-6 py-12">
            <div class="text-center mb-12">
                <h1 class="text-4xl md:text-5xl font-bold bg-gradient-to-r from-purple-600 via-blue-600 to-teal-600 bg-clip-text text-transparent mb-6">
                    Blog
                </h1>
                <p class="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
                    Insights, tutorials, and thoughts on web development with Elixir
                </p>
            </div>
            
            <div class="space-y-8">
                #{posts_html}
            </div>
        </main>
        
        #{render_footer()}
        #{render_theme_script()}
    </body>
    </html>
    """
  end

  defp render_blog_post(post) do
    """
    <!DOCTYPE html>
    <html lang="en" class="scroll-smooth">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{post.title} - Ckochx Blog</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {
                darkMode: 'class'
            }
        </script>
        <style>
            .prose h1 { 
                font-size: 1.875rem; 
                font-weight: 700; 
                color: #111827; 
                margin-bottom: 1rem; 
            }
            .prose h2 { 
                font-size: 1.5rem; 
                font-weight: 600; 
                color: #1f2937; 
                margin-top: 2rem; 
                margin-bottom: 1rem; 
            }
            .prose h3 { 
                font-size: 1.25rem; 
                font-weight: 600; 
                color: #1f2937; 
                margin-top: 1.5rem; 
                margin-bottom: 0.75rem; 
            }
            .prose p { 
                color: #374151; 
                margin-bottom: 1rem; 
                line-height: 1.625; 
            }
            .prose ul, .prose ol { 
                color: #374151; 
                padding-left: 1.5rem; 
                margin-bottom: 1rem; 
            }
            .prose ul { list-style-type: disc; }
            .prose ol { list-style-type: decimal; }
            .prose li { 
                color: #374151; 
                margin-bottom: 0.25rem; 
            }
            .prose strong { 
                color: #111827; 
                font-weight: 600; 
            }
            .prose pre { 
                background-color: #1f2937; 
                color: #f9fafb; 
                padding: 1rem; 
                border-radius: 0.5rem; 
                overflow-x: auto; 
                margin-bottom: 1rem; 
            }
            .prose code { 
                background-color: #e5e7eb; 
                color: #1f2937; 
                padding: 0.25rem 0.5rem; 
                border-radius: 0.25rem; 
                font-size: 0.875rem; 
            }
            .prose pre code { 
                background-color: transparent; 
                color: #f9fafb; 
                padding: 0; 
            }
            .prose blockquote { 
                border-left: 4px solid #3b82f6; 
                padding-left: 1rem; 
                font-style: italic; 
                color: #4b5563; 
                margin-bottom: 1rem; 
            }
            .prose table { 
                width: 100%; 
                border-collapse: collapse; 
                margin-bottom: 1rem; 
            }
            .prose th, .prose td { 
                border: 1px solid #d1d5db; 
                padding: 1rem; 
                text-align: left; 
                color: #374151; 
            }
            .prose th { 
                background-color: #f3f4f6; 
                font-weight: 600; 
                color: #111827; 
            }

            /* Dark mode styles */
            .dark .prose h1 { color: #f9fafb; }
            .dark .prose h2 { color: #e5e7eb; }
            .dark .prose h3 { color: #e5e7eb; }
            .dark .prose p { color: #e5e7eb; }
            .dark .prose ul, .dark .prose ol { color: #e5e7eb; }
            .dark .prose li { color: #e5e7eb; }
            .dark .prose strong { color: #f9fafb; }
            .dark .prose pre { background-color: #111827; }
            .dark .prose code { background-color: #374151; color: #f9fafb; }
            .dark .prose blockquote { color: #d1d5db; }
            .dark .prose th, .dark .prose td { 
                border-color: #4b5563; 
                color: #e5e7eb; 
            }
            .dark .prose th { 
                background-color: #374151; 
                color: #f9fafb; 
            }
        </style>
    </head>
    <body class="bg-gradient-to-br from-slate-50 to-blue-50 dark:from-gray-900 dark:to-blue-900 min-h-screen transition-colors duration-300">
        #{render_nav("blog")}
        
        <main class="max-w-4xl mx-auto px-6 py-12">
            <article>
                <header class="mb-8">
                    <h1 class="text-4xl md:text-5xl font-bold text-gray-900 dark:text-gray-100 mb-4">#{post.title}</h1>
                    <div class="flex items-center space-x-4 text-gray-600 dark:text-gray-400 mb-4">
                        <time datetime="#{post.date}">#{Calendar.strftime(post.date, "%B %d, %Y")}</time>
                        <span>•</span>
                        <span>By #{post.author}</span>
                    </div>
                    #{if post.excerpt != "", do: "<p class=\"text-xl text-gray-600 dark:text-gray-300 leading-relaxed\">#{post.excerpt}</p>", else: ""}
                </header>
                
                <div class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-2xl p-8 border border-gray-200/50 dark:border-gray-700/50">
                    <div class="prose max-w-none">
                        #{post.content}
                    </div>
                </div>
                
                <div class="mt-8 text-center">
                    <a href="/blog" class="inline-flex items-center px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors">
                        ← Back to Blog
                    </a>
                </div>
            </article>
        </main>
        
        #{render_footer()}
        #{render_theme_script()}
    </body>
    </html>
    """
  end

  defp render_post_card(post) do
    """
    <article class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-2xl p-6 border border-gray-200/50 dark:border-gray-700/50 hover:shadow-lg transition-all duration-300">
        <h2 class="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">
            <a href="/blog/#{post.slug}" class="hover:text-blue-600 dark:hover:text-blue-400 transition-colors">#{post.title}</a>
        </h2>
        <div class="flex items-center space-x-4 text-gray-600 dark:text-gray-400 mb-3">
            <time datetime="#{post.date}">#{Calendar.strftime(post.date, "%B %d, %Y")}</time>
            <span>•</span>
            <span>By #{post.author}</span>
        </div>
        #{if post.excerpt != "", do: "<p class=\"text-gray-700 dark:text-gray-300 mb-4\">#{post.excerpt}</p>", else: ""}
        <a href="/blog/#{post.slug}" class="inline-flex items-center text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 font-medium transition-colors">
            Read more →
        </a>
    </article>
    """
  end

  defp render_nav(active_page) do
    """
    <nav class="bg-white/80 dark:bg-gray-800/80 backdrop-blur-md border-b border-gray-200/50 dark:border-gray-700/50 sticky top-0 z-50">
        <div class="max-w-6xl mx-auto px-6 py-4">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-2">
                    <div class="w-8 h-8 bg-gradient-to-r from-purple-600 to-blue-600 rounded-lg flex items-center justify-center">
                        <span class="text-white font-bold text-sm">C</span>
                    </div>
                    <span class="text-xl font-semibold text-gray-800 dark:text-gray-100">Ckochx</span>
                </div>
                <div class="flex items-center space-x-6">
                    <a href="/" class="#{if active_page == "home", do: "text-blue-600 font-medium", else: "text-gray-600 dark:text-gray-300 hover:text-gray-800 dark:hover:text-gray-100 transition-colors"}">Home</a>
                    <a href="/about" class="#{if active_page == "about", do: "text-blue-600 font-medium", else: "text-gray-600 dark:text-gray-300 hover:text-gray-800 dark:hover:text-gray-100 transition-colors"}">About</a>
                    <a href="/blog" class="#{if active_page == "blog", do: "text-blue-600 font-medium", else: "text-gray-600 dark:text-gray-300 hover:text-gray-800 dark:hover:text-gray-100 transition-colors"}">Blog</a>
                    <button id="theme-toggle" class="p-2 rounded-lg bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 transition-colors">
                        <svg id="theme-toggle-dark-icon" class="hidden w-5 h-5 text-gray-600 dark:text-gray-300" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"></path>
                        </svg>
                        <svg id="theme-toggle-light-icon" class="hidden w-5 h-5 text-gray-600 dark:text-gray-300" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" clip-rule="evenodd"></path>
                        </svg>
                    </button>
                    <div class="flex items-center space-x-1 text-sm text-gray-600 dark:text-gray-300">
                        <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                        <span>Online</span>
                    </div>
                </div>
            </div>
        </div>
    </nav>
    """
  end

  defp render_footer do
    """
    <footer class="text-center py-8 text-gray-600 dark:text-gray-400 border-t border-gray-200/50 dark:border-gray-700/50 mt-16">
        <p class="text-sm">Built with ❤️ using Elixir and Tailwind CSS</p>
    </footer>
    """
  end

  defp render_theme_script do
    """
    <script>
        const themeToggle = document.getElementById('theme-toggle');
        const darkIcon = document.getElementById('theme-toggle-dark-icon');
        const lightIcon = document.getElementById('theme-toggle-light-icon');
        
        const currentTheme = localStorage.getItem('theme') || 'light';
        
        if (currentTheme === 'dark') {
            document.documentElement.classList.add('dark');
            darkIcon.classList.remove('hidden');
            lightIcon.classList.add('hidden');
        } else {
            document.documentElement.classList.remove('dark');
            lightIcon.classList.remove('hidden');
            darkIcon.classList.add('hidden');
        }
        
        themeToggle.addEventListener('click', function() {
            if (document.documentElement.classList.contains('dark')) {
                document.documentElement.classList.remove('dark');
                localStorage.setItem('theme', 'light');
                lightIcon.classList.remove('hidden');
                darkIcon.classList.add('hidden');
            } else {
                document.documentElement.classList.add('dark');
                localStorage.setItem('theme', 'dark');
                darkIcon.classList.remove('hidden');
                lightIcon.classList.add('hidden');
            }
        });
    </script>
    """
  end
end
