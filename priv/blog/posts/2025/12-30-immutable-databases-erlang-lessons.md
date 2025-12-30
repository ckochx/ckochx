%{
  title: "Immutability as Architecture: From Erlang Processes to Database Rows",
  author: "Christian Koch",
  excerpt: "There's a pattern across reliable systems: they treat state as a sequence of facts rather than a mutable object. Erlang's process model, event sourcing, Git's object store—they all share this insight. Here's how to apply it to your database.",
  tags: ["elixir", "erlang", "databases", "immutability", "architecture", "immu_table"]
}
---

# Immutability as Architecture: From Erlang Processes to Database Rows

There's a pattern I keep encountering across different layers of system design: the most robust architectures treat state as a sequence of facts rather than a mutable object.

Erlang's process model. Event sourcing. Append-only logs. Git's object store. Double-entry bookkeeping. They're all variations on the same insight: mutable state is a convenient abstraction that creates inconvenient problems.

After a decade of building Elixir systems, I've concluded that this insight should extend to the persistence layer. ImmuTable is my attempt to do that properly.

## The Erlang Model, Revisited

Erlang's claim to reliability isn't just supervision trees and "let it crash." It's that processes can't corrupt each other because they can't *reach* each other's memory. Data passed between processes is copied. Data within a process is rebound, not mutated.

This means an Erlang system is, conceptually, a collection of independent state machines communicating through message passing. Each state machine's history is a sequence of transformations: `state_0 → state_1 → state_2 → ...`

The current state is just the latest in the sequence. Previous states aren't "destroyed"—they become unreachable and get garbage collected. But the *model* is append-only. New facts accumulate; old facts don't change.

This is why Erlang systems are debuggable. When something goes wrong, you can reason about what sequence of messages led to a given state. The state didn't spontaneously corrupt; something put it there.

## Where the Model Breaks Down

Here's the irony: we build Elixir applications on these principles, then persist to databases that violate them completely.

```sql
UPDATE users SET status = 'suspended' WHERE id = 42;
```

This statement destroys information. The previous status is gone. We've converted a sequence of facts ("user was active, then suspended") into a single mutable value ("user is suspended").

Traditional RDBMS design treats rows as objects with properties. You update the property, the old value vanishes. This model works—until you need to answer questions like:

- When did this value change?
- What was it before?
- Who changed it?
- Was this version ever different?

At that point, you start bolting on audit tables, change data capture, event logs. You're reconstructing the append-only model that your database discarded.

## Facts vs. State

The distinction I find useful: **state** is computed from **facts**.

A fact is immutable. "On March 15, 2024, user 42's email was recorded as alice@example.com." That fact is permanently true. It happened.

State is derived. "User 42's current email is alice@example.com." This is true *now*, computed from the most recent fact.

Traditional databases conflate these. The `email` column holds current state, and the facts that produced it are lost. Append-only databases preserve the facts and derive state through queries.

This isn't a new idea. It's how accounting works (journal entries are facts, balances are derived state). It's how event sourcing works (events are facts, aggregates are derived state). It's how Git works (commits are facts, working tree is derived state).

## The Guarantees You Get

When your database stores facts instead of state, certain properties emerge:

**Temporal queries become trivial.** "What did this entity look like on January 1st?" is a simple filter, not an archaeological expedition through backup tapes.

**Audit trails are automatic.** Every change is a new record. The history *is* the table.

**Concurrent modifications don't conflict.** Two updates create two versions. No lost updates, no optimistic locking failures—just two facts recorded at the same time.

**Deletes are recoverable.** "Delete" becomes "record that this entity was deleted." Restoration is "record that this entity was undeleted."

**Debugging is tractable.** When state is wrong, you can trace the sequence of facts that produced it. Nothing was overwritten; everything is visible.

## What This Costs

Storage scales with history length. Every change adds a row. For high-churn data, this matters.

But let's be precise about when it matters. Most business entities don't change frequently. A customer record might have 10-20 versions over its lifetime. An order has a handful. Even entities that seem high-frequency—like shopping carts—probably change dozens of times, not millions.

The cases where append-only storage genuinely hurts are: high-frequency counters, ephemeral session state, metrics aggregations. These shouldn't be versioned. They're not "facts about business entities"—they're operational data.

## The ImmuTable Design

ImmuTable implements this model for Ecto schemas. The core ideas:

**Entity identity is stable.** The `entity_id` field identifies the logical entity across all versions. This is what you put in URLs and foreign keys.

**Row identity tracks versions.** The `id` field is unique per version. Each update creates a new row with a new `id` but the same `entity_id`.

**Version numbers are explicit.** Monotonically incrementing, so "current" means "highest version number."

**Timestamps enable temporal queries.** `valid_from` records when each version became active.

**Deletion is a state, not an action.** A tombstone row has `deleted_at` set. The entity and its history remain.

```elixir
ImmuTable.delete(Repo, user)
ImmuTable.undelete(Repo, user)
```

## Event Sourcing Lite

You might recognize this as similar to event sourcing. It is—but simpler.

Full event sourcing stores *events* ("EmailChanged") and reconstructs state by replaying them. Powerful, but adds complexity: event schemas, replay logic, snapshotting for performance.

ImmuTable stores *snapshots*. Each version is the complete entity state at that point. No replay needed; query the version you want directly.

This trades some expressiveness (you lose the "what kind of change" information) for simplicity (any version is immediately usable). For many applications, it's the right trade.

If you need full event sourcing, you probably know it. If you're unsure, append-only snapshots are sufficient.

## Integration with Elixir's Model

There's an elegance to having the same model at every layer:

- Elixir variables: rebound, not mutated
- GenServer state: new state returned, old state replaced
- Database rows: new version inserted, old version preserved

The patterns you use in application code extend to persistence. The debugging techniques you use for process state work for entity history. The mental model is consistent throughout.

This isn't just aesthetic. Consistent models reduce cognitive load. When state behaves the same way everywhere, you stop having to context-switch between "how does memory work" and "how does the database work."

## Practical Considerations

**Querying current state** uses a subquery pattern: join on MAX(version) per entity_id. With proper indexes, this is efficient.

**Concurrency** uses PostgreSQL advisory locks during updates. Two concurrent updates to the same entity serialize; both succeed with consecutive versions.

**Blocking accidental mutations** matters. ImmuTable intercepts Repo.update and Repo.delete calls, raising if you try to mutate directly. The append-only model only works if it's enforced.

## When to Use This

Business domain entities with compliance, audit, or debugging requirements. Customer data, financial records, anything you might need to explain in six months.

**Not** for: metrics, caches, ephemeral operational data, extremely high-frequency updates where history genuinely doesn't matter.

## Conclusion

Erlang's process model and immutable data structures aren't just language features—they're an architectural pattern that promotes reliability through explicit state management.

That pattern shouldn't stop at the database boundary. Append-only tables extend the same guarantees to persistence: tractable history, safe concurrency, recoverable deletes.

ImmuTable is an implementation of this pattern for Ecto. The next post covers the mechanics: schema design, version resolution, concurrency handling, and the query patterns that make it work.

---

*ImmuTable is available on [GitHub](https://github.com/ckochx/immu_table). Part 2 of this series covers the implementation details.*
