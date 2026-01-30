%{
  title: "Nobody Cares About Your Code",
  author: "Christian Koch",
  excerpt: "Craft still matters—but only to the people who see the code. Everyone else is looking at the scoreboard.",
  tags: ["elixir", "code", "craftsmanship"]
}
---

# Nobody Cares About Your Code

Not only do they not care—they have *never* cared.

This isn't cynicism. It's a structural truth about how software creates value, and understanding it will make you a better engineer.

## The Craftsmanship Era's Strategic Error

In the software craftsmanship days, much digital ink was spilled over the value of beautiful, well-thought-out, well-crafted code as an end in itself. We debated tabs versus spaces, argued about design patterns, wrote manifestos about clean code. The implicit promise was that if you wrote beautiful code, good things would follow.

This thesis wasn't wrong. But the audience was.

Craftsmanship in software matters. It matters a lot. But it only matters within the walls of the engineering organization. We made a strategic error by collectively trumpeting the value of craftsmanship *in and of itself*—as if the rest of the company, the customers, the market would somehow recognize and reward elegant abstractions and well-named variables.

They never did. They never will.

## What Actually Matters

Other engineers want to be able to read your code and understand it. That is still true and has not changed. Your teammates benefit from clear naming, logical structure, and thoughtful organization. Code review is easier. Onboarding is faster. Bugs are found sooner.

But the code itself never mattered outside the engineering org. The *outcome* mattered.

The website. The app. The feature. The user experience. The business metric that moved. These are the things that matter to everyone who isn't an engineer—which is to say, almost everyone.

When your CEO talks about the product, they're not describing your elegant state management solution. When customers leave reviews, they're not praising your test coverage. When the board evaluates the company, they're looking at growth curves, not git histories.

## Craftsmanship as Communication

Here's the reframe that makes this make sense: craftsmanship is really just a different framing on communication skill.

Good code communicates intention—to the computer (obviously), but more importantly, to your fellow engineers. It says: here's what I was trying to do, here's how I structured my thinking, here's where you should look if something breaks.

When we talk about "readable code" or "maintainable code," we're talking about code that communicates well. The craft *is* the communication. And like all communication, it only matters if there's someone on the receiving end who needs the message.

Your product manager doesn't need that message. Your customers don't need it. Your investors definitely don't need it. Only your engineering colleagues do.

This means the value of craftsmanship is bounded by the size and needs of your engineering organization. It's not zero—far from it—but it's also not infinite, and it's certainly not the primary way your work creates value in the world.

## The AI Era Makes This Undeniable

This discrepancy is laid even more bare in the AI/LLM era.

The code itself is now something it is nearly optional to interact with. You can generate it, explain it, refactor it, and debug it through conversation. An engineer can be productive in a codebase they've never read, using tools that read it for them.

I won't declare we're in a new era—that kind of proclamation ages poorly. But the trend is clear: determining intention from code is easier than ever. You have a close-at-hand interpreter to help you understand what software is trying to communicate.

This doesn't eliminate the need for clear code. Garbage in, garbage out still applies. But it does shift the emphasis. Software clarity and design still matter, but they're increasingly a *side effect* of clear intention about what you want to build. They are not the goal in and of itself.

If you know what you're trying to accomplish—really know it, with precision—the code tends to follow. The LLM can help you express it. Your colleagues can help you refine it. The craft emerges from the clarity of purpose, not the other way around.

## So What Do We Do Now?

Does this mean all we can do is push user-facing features? Ship buttons and dashboards and call it a day?

Not at all. There is still a need for refactoring, optimizations, and performance tuning. Infrastructure work matters. Paying down tech debt matters. The unsexy work of keeping systems running matters enormously.

But it's not enough to just make something better quietly.

That can be a strategy, but it's high-risk and low-reward. You don't want to be the engineer who disappears for days only to emerge with an imperceptible 50ms improvement. In the current macroeconomic environment, that's likely to paint a target on your back. Not because the work wasn't valuable, but because the value wasn't visible.

Impact can be measured in lots of ways:

- Latency improvements that affect user experience metrics
- Reliability gains that reduce on-call burden and customer complaints  
- Developer velocity improvements that let the team ship faster
- Cost reductions that show up in the infrastructure bill
- Security hardening that reduces risk exposure

The key word is *measured*. If you can't measure it, you can't communicate it. And if you can't communicate it, it might as well not exist to anyone outside your immediate team.

## The New Skill Set

This isn't a lament. It's a strategic insight.

The engineers who thrive—who have always thrived, honestly—are the ones who understand that their job is to create outcomes, not artifacts. The code is a means to an end. A necessary means, often a complex and demanding one, but a means nonetheless.

The skill set that matters now:

1. **Clarity of intention.** Know what you're trying to build and why. Be able to articulate it in terms that matter to non-engineers.

2. **Outcome orientation.** Connect your work to measurable results. If you're doing a refactor, know what it enables. If you're improving performance, know who benefits and how much.

3. **Communication across boundaries.** Translate technical work into business impact. Make the invisible visible.

4. **Efficient craftsmanship.** Write good code, but calibrate your investment to the actual communication needs of your team. A throwaway script doesn't need the same polish as a core system.

5. **Tool leverage.** Use AI and automation to handle the parts of coding that are now commodity skills, freeing your attention for the parts that aren't.

## The Craft Isn't Dead

I want to be clear: I'm not saying craft doesn't matter. I'm saying it was never the point.

The point was always the outcome—the thing the software does for people. The craft serves that outcome by making the software easier to build, maintain, and evolve. It serves the engineers who have to work with the code. It doesn't serve anyone else directly.

Understanding this frees you from a certain kind of misplaced idealism. You don't have to feel guilty about shipping code that's merely adequate when adequate is what the situation calls for. You don't have to treat every PR as a chance to demonstrate your mastery. You can be pragmatic without feeling like you've betrayed your principles.

And you can focus your actual craftsmanship—your care, your attention, your pride in doing good work—on the places where it genuinely matters. The core systems. The code your teammates will read a hundred times. The abstractions that will shape how people think about the problem.

That's still craft. It's just craft in service of something larger than itself.

Nobody cares about your code. They care about what your code makes possible. Once you really internalize that, you can stop proving your worth through elegance and start proving it through impact.

That's always been the game. Now it's just more obvious.
