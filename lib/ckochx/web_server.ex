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
    html = render_home_page()
    send_resp(conn, 200, html)
  end

  get "/about" do
    html = render_about_page()
    send_resp(conn, 200, html)
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

  defp render_home_page do
    animation_styles = """
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    @keyframes slideUp {
        from { transform: translateY(20px); opacity: 0; }
        to { transform: translateY(0); opacity: 1; }
    }
    .animate-fade-in { animation: fadeIn 0.8s ease-in-out; }
    .animate-slide-up { animation: slideUp 0.6s ease-out; }
    """

    render_page("Christian Koch Website", "home", [animation_styles], """
    <main class="max-w-6xl mx-auto px-6 py-12">
        <div class="text-center mb-16 animate-fade-in">
            <h1 class="text-5xl md:text-6xl font-bold bg-gradient-to-r from-purple-600 via-blue-600 to-teal-600 bg-clip-text text-transparent mb-6">
                Welcome to ckochx.com; the personal server for Christian Koch.
            </h1>
            <p class="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto leading-relaxed">
                A modern Elixir web server built with Bandit, designed for serving static files with style and performance.
            </p>
        </div>

        <!-- Status Card -->
        <div class="mb-12 animate-slide-up">
            <div class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-200/50 dark:border-gray-700/50 p-8">
                <div class="flex items-start space-x-4">
                    <div class="flex-shrink-0">
                        <div class="w-12 h-12 bg-gradient-to-r from-green-500 to-emerald-500 rounded-xl flex items-center justify-center">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                            </svg>
                        </div>
                    </div>
                    <div class="flex-1">
                        <h3 class="text-xl font-semibold text-gray-800 dark:text-gray-100 mb-2">Server Status: Running</h3>
                        <p class="text-gray-600 dark:text-gray-300 mb-4">Your Elixir web server with Bandit is running successfully on port 4000!</p>
                        <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
                            <p class="text-sm text-gray-700 dark:text-gray-300">
                                <span class="font-medium">Directory:</span> 
                                <code class="bg-gray-200 dark:bg-gray-600 px-2 py-1 rounded text-xs">priv/static</code>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Features Grid -->
        <div class="mb-12">
            <h2 class="text-3xl font-bold text-center text-gray-800 dark:text-gray-100 mb-8">Features</h2>
            <div class="grid md:grid-cols-3 gap-6">
                <div class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-xl p-6 border border-gray-200/50 dark:border-gray-700/50 hover:shadow-lg transition-all duration-300 hover:scale-105">
                    <div class="w-12 h-12 bg-gradient-to-r from-blue-500 to-indigo-500 rounded-lg flex items-center justify-center mb-4">
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                        </svg>
                    </div>
                    <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-100 mb-2">Static File Serving</h3>
                    <p class="text-gray-600 dark:text-gray-300 text-sm">Efficiently serve CSS, JS, images, and other static assets with built-in caching.</p>
                </div>

                <div class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-xl p-6 border border-gray-200/50 dark:border-gray-700/50 hover:shadow-lg transition-all duration-300 hover:scale-105">
                    <div class="w-12 h-12 bg-gradient-to-r from-purple-500 to-pink-500 rounded-lg flex items-center justify-center mb-4">
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                        </svg>
                    </div>
                    <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-100 mb-2">Powered by Elixir</h3>
                    <p class="text-gray-600 dark:text-gray-300 text-sm">Built with Elixir, Plug, and Bandit for maximum performance and reliability.</p>
                </div>

                <div class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-xl p-6 border border-gray-200/50 dark:border-gray-700/50 hover:shadow-lg transition-all duration-300 hover:scale-105">
                    <div class="w-12 h-12 bg-gradient-to-r from-teal-500 to-green-500 rounded-lg flex items-center justify-center mb-4">
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                        </svg>
                    </div>
                    <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-100 mb-2">Hot Reloading</h3>
                    <p class="text-gray-600 dark:text-gray-300 text-sm">Development-friendly with hot code reloading for rapid iteration.</p>
                </div>
            </div>
        </div>

        <!-- Tech Stack -->
        <div class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-2xl p-8 border border-gray-200/50 dark:border-gray-700/50">
            <h2 class="text-2xl font-bold text-center text-gray-800 dark:text-gray-100 mb-8">Tech Stack</h2>
            <div class="flex flex-wrap justify-center items-center gap-6">
                <div class="flex items-center space-x-2 bg-purple-100 px-4 py-2 rounded-full">
                    <div class="w-3 h-3 bg-purple-600 rounded-full"></div>
                    <span class="text-purple-800 font-medium">Elixir</span>
                </div>
                <div class="flex items-center space-x-2 bg-blue-100 px-4 py-2 rounded-full">
                    <div class="w-3 h-3 bg-blue-600 rounded-full"></div>
                    <span class="text-blue-800 font-medium">Plug</span>
                </div>
                <div class="flex items-center space-x-2 bg-green-100 px-4 py-2 rounded-full">
                    <div class="w-3 h-3 bg-green-600 rounded-full"></div>
                    <span class="text-green-800 font-medium">Bandit</span>
                </div>
                <div class="flex items-center space-x-2 bg-teal-100 px-4 py-2 rounded-full">
                    <div class="w-3 h-3 bg-teal-600 rounded-full"></div>
                    <span class="text-teal-800 font-medium">Tailwind CSS</span>
                </div>
            </div>
        </div>
    </main>
    """)
  end

  defp render_about_page do
    render_page("About - Ckochx Web Server", "about", [], """
    <main class="max-w-4xl mx-auto px-6 py-12">
        <div class="text-center mb-12">
            <h1 class="text-4xl md:text-5xl font-bold bg-gradient-to-r from-purple-600 via-blue-600 to-teal-600 bg-clip-text text-transparent mb-6">
                About Ckochx
            </h1>
            <p class="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
                Learn more about this modern Elixir web server framework
            </p>
        </div>

        <!-- Content Sections -->
        <div class="space-y-8">
            <section class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-2xl p-8 border border-gray-200/50 dark:border-gray-700/50">
                <h2 class="text-2xl font-bold text-gray-800 dark:text-gray-100 mb-4">What is Ckochx?</h2>
                <p class="text-gray-600 dark:text-gray-300 leading-relaxed mb-4">
                    Ckochx is a lightweight, modern web server framework built with Elixir that focuses on serving static files efficiently. 
                    It combines the power of Elixir's fault-tolerant architecture with the performance of the Bandit HTTP server.
                </p>
                <p class="text-gray-600 dark:text-gray-300 leading-relaxed">
                    Designed for simplicity and performance, Ckochx is perfect for serving documentation, SPAs, 
                    or any static content with modern web standards and best practices.
                </p>
            </section>

            <section class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-2xl p-8 border border-gray-200/50 dark:border-gray-700/50">
                <h2 class="text-2xl font-bold text-gray-800 dark:text-gray-100 mb-6">Architecture</h2>
                <div class="grid md:grid-cols-2 gap-6">
                    <div class="space-y-4">
                        <div class="flex items-start space-x-3">
                            <div class="w-6 h-6 bg-purple-100 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                                <div class="w-2 h-2 bg-purple-600 rounded-full"></div>
                            </div>
                            <div>
                                <h3 class="font-semibold text-gray-800 dark:text-gray-100">Elixir Foundation</h3>
                                <p class="text-sm text-gray-600 dark:text-gray-300">Built on Elixir's Actor model for massive concurrency</p>
                            </div>
                        </div>
                        <div class="flex items-start space-x-3">
                            <div class="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                                <div class="w-2 h-2 bg-blue-600 rounded-full"></div>
                            </div>
                            <div>
                                <h3 class="font-semibold text-gray-800 dark:text-gray-100">Plug Middleware</h3>
                                <p class="text-sm text-gray-600 dark:text-gray-300">Composable request/response transformations</p>
                            </div>
                        </div>
                    </div>
                    <div class="space-y-4">
                        <div class="flex items-start space-x-3">
                            <div class="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                                <div class="w-2 h-2 bg-green-600 rounded-full"></div>
                            </div>
                            <div>
                                <h3 class="font-semibold text-gray-800 dark:text-gray-100">Bandit Server</h3>
                                <p class="text-sm text-gray-600 dark:text-gray-300">Fast HTTP/2 and WebSocket support</p>
                            </div>
                        </div>
                        <div class="flex items-start space-x-3">
                            <div class="w-6 h-6 bg-teal-100 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                                <div class="w-2 h-2 bg-teal-600 rounded-full"></div>
                            </div>
                            <div>
                                <h3 class="font-semibold text-gray-800 dark:text-gray-100">OTP Supervision</h3>
                                <p class="text-sm text-gray-600 dark:text-gray-300">Self-healing processes and fault tolerance</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-2xl p-8 border border-gray-200/50 dark:border-gray-700/50">
                <h2 class="text-2xl font-bold text-gray-800 dark:text-gray-100 mb-6">Features</h2>
                <div class="grid md:grid-cols-2 gap-6">
                    <ul class="space-y-3">
                        <li class="flex items-center space-x-2">
                            <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                            </svg>
                            <span class="text-gray-700 dark:text-gray-300">Static file serving</span>
                        </li>
                        <li class="flex items-center space-x-2">
                            <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                            </svg>
                            <span class="text-gray-700 dark:text-gray-300">Automatic MIME type detection</span>
                        </li>
                        <li class="flex items-center space-x-2">
                            <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                            </svg>
                            <span class="text-gray-700 dark:text-gray-300">Hot code reloading</span>
                        </li>
                        <li class="flex items-center space-x-2">
                            <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                            </svg>
                            <span class="text-gray-700 dark:text-gray-300">Request logging</span>
                        </li>
                    </ul>
                    <ul class="space-y-3">
                        <li class="flex items-center space-x-2">
                            <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                            </svg>
                            <span class="text-gray-700 dark:text-gray-300">Fault tolerance</span>
                        </li>
                        <li class="flex items-center space-x-2">
                            <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                            </svg>
                            <span class="text-gray-700 dark:text-gray-300">Configurable routing</span>
                        </li>
                        <li class="flex items-center space-x-2">
                            <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                            </svg>
                            <span class="text-gray-700 dark:text-gray-300">Modern web standards</span>
                        </li>
                        <li class="flex items-center space-x-2">
                            <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                            </svg>
                            <span class="text-gray-700 dark:text-gray-300">Lightweight footprint</span>
                        </li>
                    </ul>
                </div>
            </section>

            <section class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-2xl p-8 border border-gray-200/50 dark:border-gray-700/50">
                <h2 class="text-2xl font-bold text-gray-800 dark:text-gray-100 mb-4">Getting Started</h2>
                <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 mb-4">
                    <code class="text-sm text-gray-800 dark:text-gray-100">
                        # Install dependencies<br>
                        mix deps.get<br><br>
                        # Start the server<br>
                        mix run --no-halt
                    </code>
                </div>
                <p class="text-gray-600 dark:text-gray-300">
                    The server will start on <code class="bg-gray-200 dark:bg-gray-600 px-2 py-1 rounded text-sm">localhost:4000</code> 
                    and serve files from the <code class="bg-gray-200 dark:bg-gray-600 px-2 py-1 rounded text-sm">priv/static</code> directory.
                </p>
            </section>
        </div>
    </main>
    """)
  end

  defp render_blog_index(posts) do
    posts_html = Enum.map_join(posts, "\n", &render_post_card/1)

    render_page("Blog - Ckochx Web Server", "blog", [], """
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
    """)
  end

  defp render_blog_post(post) do
    prose_styles = """
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
    """

    render_page("#{post.title} - Ckochx Blog", "blog", [prose_styles], """
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
    """)
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
    nav_html = File.read!("priv/templates/_nav.html")

    # Apply active page styling using JavaScript with better contrast
    nav_html <>
      """
      <style>
          .nav-link {
              color: #374151;
              transition: color 0.2s;
          }
          .nav-link:hover {
              color: #111827;
          }
          .nav-link.active {
              color: #2563eb;
              font-weight: 500;
          }
          
          .dark .nav-link {
              color: #d1d5db;
          }
          .dark .nav-link:hover {
              color: #f9fafb;
          }
          .dark .nav-link.active {
              color: #3b82f6;
          }
      </style>
      <script>
          // Set active nav link
          document.addEventListener('DOMContentLoaded', function() {
              const activeNavLink = document.querySelector('.nav-link[data-page="#{active_page}"]');
              if (activeNavLink) {
                  activeNavLink.classList.add('active');
              }
          });
      </script>
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

  defp render_page(title, active_page, extra_styles, content) do
    extra_css =
      if extra_styles != [] do
        "<style>#{Enum.join(extra_styles, "\n")}</style>"
      else
        ""
      end

    """
    <!DOCTYPE html>
    <html lang="en" class="scroll-smooth">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{title}</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {
                darkMode: 'class'
            }
        </script>
        #{extra_css}
    </head>
    <body class="bg-gradient-to-br from-slate-50 to-blue-50 dark:from-gray-900 dark:to-blue-900 min-h-screen transition-colors duration-300">
        #{render_nav(active_page)}
        #{content}
        #{render_footer()}
        #{render_theme_script()}
    </body>
    </html>
    """
  end
end
