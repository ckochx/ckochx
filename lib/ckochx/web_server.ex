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
    posts = Ckochx.Blog.list_posts()
    html = render_blog_index(posts)
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

  defp render_about_page do
    render_page("About - Christian Koch's Website: ckochx.com", "about", [], """
    <main class="max-w-4xl mx-auto px-6 py-12">
        <div class="text-center mb-12">
            <h1 class="text-4xl md:text-5xl font-bold bg-gradient-to-r from-purple-600 via-blue-600 to-teal-600 bg-clip-text text-transparent mb-8">
                About me.
            </h1>
        </div>

        <!-- Content Sections -->
        <div class="space-y-8 mb-12">
            <section class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-2xl p-8 border border-gray-200/50 dark:border-gray-700/50">
                <h2 class="text-2xl font-bold text-gray-800 dark:text-gray-100 mb-4">Who is <em>ck</em>?</h2>
                <p class="text-gray-600 dark:text-gray-300 leading-relaxed">
                    My name is Christian Koch. I'm a principal engineer; conference speaker; (software) engineering leader; (occasionally) a writer; and a sourdough bread baker.
                </p>
            </section>

            <!-- Which Christian Koch section -->
            <section class="bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm rounded-2xl p-8 border border-gray-200/50 dark:border-gray-700/50">
                <div class="text-center mb-6">
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-gray-100 mb-4">Which Christian Koch is this?</h2>
                    <p class="text-gray-600 dark:text-gray-300">There are many Christian Kochs out there. (Honestly more than I was expecting.) Here's how to identify the right one:</p>
                </div>
                <ul class="space-y-3 max-w-2xl mx-auto">
                    <li class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                        <span class="text-gray-700 dark:text-gray-300">The right one: 🐱‍💻</span>
                        <a href="https://www.linkedin.com/in/ckochx/" target="_blank" class="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 underline underline-offset-2 transition-colors font-medium">👈 This one</a>
                    </li>
                    <li class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                        <span class="text-gray-700 dark:text-gray-300">❌ Not the right one:</span>
                        <a href="https://www.linkedin.com/in/christianjkoch/" target="_blank" class="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 underline underline-offset-2 transition-colors">No</a>
                    </li>
                    <li class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                        <span class="text-gray-700 dark:text-gray-300">❌ Also not:</span>
                        <a href="http://christianko.ch/" target="_blank" class="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 underline underline-offset-2 transition-colors">아니요</a>
                    </li>
                    <li class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                        <span class="text-gray-700 dark:text-gray-300">❌ Nope:</span>
                        <a href="https://www.researchgate.net/profile/Christian-Koch-14" target="_blank" class="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 underline underline-offset-2 transition-colors">Nein</a>
                    </li>
                    <li class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                        <span class="text-gray-700 dark:text-gray-300">❌ Not this either:</span>
                        <a href="https://scholar.google.com/citations?user=ncGPvvAAAAAJ&hl=de" target="_blank" class="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 underline underline-offset-2 transition-colors">Nyet</a>
                    </li>
                </ul>
            </section>
        </div>

        <!-- Additional Content Sections -->
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

    render_page("Blog - Christian Koch's Website", "blog", [], """
    <main class="max-w-4xl mx-auto px-6 py-12">
        <div class="text-center mb-12">
            <h1 class="text-4xl md:text-5xl font-bold bg-gradient-to-r from-purple-600 via-blue-600 to-teal-600 bg-clip-text text-transparent mb-6">
                Blog
            </h1>
            <p class="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
                Thoughts on software engineering and working with Elixir
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

        // Light mode elements (sun primary, moon secondary)
        const sunIcon = document.getElementById('sun-icon');
        const moonIcon = document.getElementById('moon-icon');

        // Dark mode elements (moon primary, sun secondary)
        const moonIconPrimary = document.getElementById('moon-icon-primary');
        const sunIconSecondary = document.getElementById('sun-icon-secondary');

        // Detect user's system preference, fallback to light
        const systemPrefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
        const currentTheme = localStorage.getItem('theme') || (systemPrefersDark ? 'dark' : 'light');

        function updateThemeIcons(isDark, animate = false) {
            if (animate) {
                // Add swapping animation
                const exitingIcons = isDark ? [sunIcon, moonIcon] : [moonIconPrimary, sunIconSecondary];
                const enteringIcons = isDark ? [moonIconPrimary, sunIconSecondary] : [sunIcon, moonIcon];

                // Step 1: Scale down and rotate exiting icons
                exitingIcons.forEach(icon => {
                    icon.style.transform = 'scale(0.8) rotate(180deg)';
                    icon.style.opacity = '0';
                });

                // Step 2: After half the animation, swap visibility and scale up entering icons
                setTimeout(() => {
                    exitingIcons.forEach(icon => {
                        icon.classList.add('hidden');
                        icon.style.transform = '';
                        icon.style.opacity = '';
                    });

                    enteringIcons.forEach(icon => {
                        icon.classList.remove('hidden');
                        icon.style.transform = 'scale(0.8) rotate(-180deg)';
                        icon.style.opacity = '0';
                    });

                    // Step 3: Animate entering icons to normal state
                    setTimeout(() => {
                        enteringIcons.forEach(icon => {
                            icon.style.transform = 'scale(1) rotate(0deg)';
                            icon.style.opacity = '';
                        });
                    }, 50);
                }, 250);

            } else {
                // No animation - instant swap
                if (isDark) {
                    sunIcon.classList.add('hidden');
                    moonIcon.classList.add('hidden');
                    moonIconPrimary.classList.remove('hidden');
                    sunIconSecondary.classList.remove('hidden');
                } else {
                    sunIcon.classList.remove('hidden');
                    moonIcon.classList.remove('hidden');
                    moonIconPrimary.classList.add('hidden');
                    sunIconSecondary.classList.add('hidden');
                }
            }

            // Update theme
            if (isDark) {
                document.documentElement.classList.add('dark');
            } else {
                document.documentElement.classList.remove('dark');
            }
        }

        // Set initial theme
        updateThemeIcons(currentTheme === 'dark');

        themeToggle.addEventListener('click', function() {
            const isDark = document.documentElement.classList.contains('dark');
            const newTheme = isDark ? 'light' : 'dark';

            localStorage.setItem('theme', newTheme);
            updateThemeIcons(newTheme === 'dark', true); // Enable animation on click
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
