%{
  title: "Building ElixirNoDeps: A Terminal Presentation Tool with Zero Dependencies",
  author: "Christian Koch",
  excerpt: "The story behind ElixirNoDeps - how a simple idea for ElixirConf became a full-featured terminal presentation tool with remote control capabilities, all built with zero external Mix dependencies.",
  tags: ["elixir", "dependencies", "terminal", "presentation", "elixirconf"]
}
---

# Building ElixirNoDeps: A Terminal Presentation Tool with Zero Dependencies

When Jeremy Searls and I started preparing for our ElixirConf 2025 talk "Elixir is all you need: Rethinking dependencies," From the start, we wanted to have a repo to help demonstrate the capabilities of the Elixir standard library. We faced an interesting challenge: how do you give a presentation about not using dependencies without using a presentation tool that's built with dozens of them?

The answer was simple: build our own. With zero external dependencies.

What better way than to give the presentation from the repo itself?

## The Initial Commit: "ElixirConf Here We Come"

It all started with a single commit on July 29th: `5e8818e initial commit- ElixirConf here we come`. The goal was ambitious yet simple - create a terminal-based presentation tool using only Elixir's standard library and built-in capabilities.

## The Core Philosophy: Zero External Mix Dependencies

The entire project is built on one fundamental principle: **no external Mix dependencies**. This wasn't just a constraint - it was the whole point. The `mix.exs` file literally has an empty `deps` function:

```elixir
defp deps do
  # Zero external dependencies - that's the whole point!
  []
end
```

This forced us to rediscover what Elixir can do out of the box. Spoiler alert: it's a lot.

## Building the Foundation

The first few commits laid the groundwork:

- **Markdown parser**: Built from scratch using Elixir's pattern matching
- **Terminal rendering**: Raw ANSI escape sequences and IO manipulation
- **YAML frontmatter**: Custom parser for slide metadata
- **Keyboard navigation**: Raw terminal input processing

Each component was an exercise in creative problem-solving. How do you parse YAML without a YAML library? Pattern matching and string manipulation. How do you handle raw keyboard input? Direct terminal control with Elixir's IO system.

## The Evolution: From Simple to Sophisticated

What started as a basic slide viewer evolved into something much more powerful:

### Phase 1: Basic Presentation (July-August 2024)
- Markdown slide parsing
- Terminal rendering with ANSI formatting
- Basic keyboard navigation
- ASCII art generation for images

### Phase 2: Remote Control Revolution (August 2024)
The game-changer came with the realization that conferences often have unreliable WiFi, but you always have your phone. Why not create a local network solution?

- **HTTP server**: Built using Elixir's built-in `:inets` 
- **Mobile-optimized interface**: Clean presenter controls
- **Speaker notes**: Private notes visible only on the presenter's device

### Phase 3: Conference-Ready Features (August-September 2024)
- **Interactive polling**: Live audience participation
- **QR code generation**: For easy connection to the audience app
- **Timer warnings**: Real-time slide timing feedback
- **Multi-role support**: Presenter, audience, and viewer modes

## Technical Highlights

### No Dependencies, Big Features

The most impressive part? All of this was built without external dependencies:

- **HTTP server**: Using Erlang's `:inets` and `:httpd`
- **Image processing**: ASCII art generation with pure Elixir
- **Image processing**: For terminal image integration, we did have to stretch the definition of no dependencies and rely on `imagemagick` to support resizing erminal images for the presentation.
- **Terminal control**: Raw ANSI sequences and IO manipulation

### Architecture Decisions

**Single Binary Distribution**: The entire presentation tool compiles to a single escript binary. No installation, no dependency management - just download and run.

**Local-First**: Everything can run on your local network. No cloud services, no external APIs. Your presentation works whether you have internet or not. It also works from a deployed state.

**Progressive Enhancement**: Basic functionality works in any terminal. Advanced features (like sixel image rendering) are detected and enabled automatically.

## The Real-World Test: ElixirConf 2025

The ultimate validation came when we used ElixirNoDeps to deliver our ElixirConf presentation. Not only did it work flawlessly, but the meta-aspect of using a zero-dependency tool to talk about zero-dependency development resonated strongly with the audience.

Key moments from the conference:

- **Live polling**: The audience participated in real-time polls about dependency usage
- **Mobile control**: Seamlessly navigated slides from my phone while the audience saw clean terminal output  

## Lessons Learned

### 1. Elixir's Standard Library is Incredibly Powerful
You can build sophisticated applications without reaching for external libraries. Pattern matching, GenServers, ETS, the built-in HTTP stack - they're all there waiting to be used.

### 2. Constraints Drive Creativity
Having zero dependencies forced creative solutions that ended up being more elegant than traditional approaches.

### 3. Local-First is Liberating
Not depending on external services or internet connectivity gives you incredible reliability, especially in conference environments.

### 4. Terminal Applications Still Matter
In an age of web apps and GUIs, there's something powerful about a well-crafted terminal application. It's universal, lightweight, and distraction-free.

## The Numbers

After months of development, ElixirNoDeps supports:

- **250+ concurrent audience connections**
- **Real-time polling and interaction**
- **Multiple presentation formats** (Markdown, with extensible parsing)
- **Cross-platform compatibility** (macOS, Linux, Windows)
- **Zero installation** presentation delivery
- **Complete offline functionality**

All in a single binary with zero external Mix dependencies.

## Open Source Impact

The project is now open source at [github.com/ckochx/ElixirNoDeps](https://github.com/ckochx/ElixirNoDeps), serving as both a useful tool and a proof of concept for what's possible with Elixir's built-in capabilities.

The response from the Elixir community has been fantastic.

## Looking Forward

ElixirNoDeps proves that sometimes the best solution isn't adding more dependencies - it's rediscovering what you already have. As the Elixir ecosystem continues to grow, tools like this serve as a reminder that the language itself is incredibly capable.

The next time you're about to `mix deps.get` another library, ask yourself: do I really need this? You might be surprised by what you can build with just Elixir.

---

*Want to try ElixirNoDeps? Check out the [GitHub repository](https://github.com/ckochx/ElixirNoDeps) or watch the [ElixirConf 2025 presentation](https://elixirconf.com/talks/elixir-is-all-you-need-build-production-ready-apps-without-dependencies/) to see it in action.*