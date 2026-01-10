%{
  title: "Building a Flight Price Watch Agent with Claude Code and Elixir",
  author: "Christian Koch",
  excerpt: "Let an agent watch flight prices. You have better things to do.",
  tags: ["elixir", "flights", "launch agent"]
}
---

# Building a Flight Price Agent with Claude and Elixir

I fly infrequently, but just enough. I want to watch the prices and find the best time to buy when I know I will be travelling, but I am distractable and can't always be bothered to watch airfare ticket prices closely enough to find those great deals. This is the perfect use case for an agent. So I built one to do it for me.

_And by I built one, I mean prodded Claude until they built one_

## The Idea

The concept is simple: run a script every few hours that searches for flights, sends the results to Claude for analysis, and pops up a macOS notification if there's a deal worth grabbing. No browser tabs, no apps, no remembering to check. Just a quiet background process that taps me on the shoulder when it matters.

## Why Elixir?

_Clearly you haven't seen "Elixir is all you need", strawperson._

**AHEM**

* [ElixirNoDeps](https://github.com/ckochx/ElixirNoDeps){:target="_blank"}

* [ElixirConf 2025 presentation](https://elixirconf.com/talks/elixir-is-all-you-need-build-production-ready-apps-without-dependencies/){:target="_blank"}

I wanted something that compiles to a single executable and runs reliably without fuss. Elixir's escript feature does exactly that—`mix escript.build` produces one file I can run from launchd without worrying about virtual environments or runtime dependencies.

The code itself is straightforward. A few modules: one to load config, one to search flights (via SerpApi or mock data), one to shell out to the Claude CLI, and one to send notifications.

```elixir
defmodule FlightAgent.Claude do
  def analyze(search, flight_data, model) do
    prompt = build_prompt(search, flight_data)
    
    case System.cmd("claude", ["--print", "--model", model, "-p", prompt]) do
      {output, 0} -> {:ok, parse_response(output)}
      {error, _}  -> {:error, error}
    end
  end
end
```

## Using Claude via the CLI

Here's the trick that makes this work with your Claude subscription instead of paying per API call: the `claude` CLI (Claude Code) authenticates through your existing subscription. So instead of hitting the API directly, the agent just shells out to `claude --print -p "analyze these flights..."` and parses the response.

Claude's unsurprisingly good at this task. Given a blob of flight data, it identifies the best options, flags anything under my target price, and gives a simple BUY/WAIT/MONITOR recommendation. The prompt engineering is minimal—just tell it what you want and it figures out the formatting.

## The Schedule

I'm using launchd on macOS to run the agent at midnight, 6am, noon, and 6pm. To avoid hammering the flight API at exactly the same time every day (and to make the intervals feel less robotic), there's a wrapper script that adds a random 0-90 minute delay before each run.

```bash
DELAY=$((RANDOM % 5400))
sleep $DELAY
./flight_agent
```

When a search completes, I get a native macOS notification. If there's a deal, the notification says so. Full details go to a log file I can check later.

## What I Learned

1. **Claude CLI is not underrated.** If you're using it, then you know Claude Code is pretty capable. Claude Code + the Elixir Runtime go very well together. For personal tools that don't need to scale, it's effectively free (within your existing subscription limits).

2. **Elixir escripts are great for this.** No containers, no deploy process. Just a binary and a plist.

3. **Flight pricing is chaotic.** Even with mock data during development, I could see how much prices vary. The agent removes the emotional component—I don't see prices bouncing around all day, just the summary when it matters.

## Try It

The code is on GitHub: [Flight Agent](https://github.com/ckochx/flight_agent){:target="_blank"}

You'll need Elixir, the Claude CLI (logged into your Claude subscription), and optionally a SerpApi key for real flight data. The install script handles the rest.

---

*Now if you'll excuse me, I have a flight to book.*
