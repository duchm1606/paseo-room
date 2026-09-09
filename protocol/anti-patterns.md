# Anti-patterns — shared vocabulary

Each name is a one-line command the Lead/Supervisor can use directly
("check this plan for balloon pattern").

| Name | Description | Handling |
|---|---|---|
| **Balloon pattern** | Foundation is wrong but balloons (locks/cache/retry/heuristics) keep the feature afloat | Stop the feature, assess the foundation, plan the fix underneath |
| **Brake pattern** | Car has no brakes (boundaries/validation/rollback/evidence) yet keeps getting upgraded | Install the brakes before accelerating |
| **Pre-solve** | Lead concludes first, then asks; agents are reduced to confirmation | Assign open questions before the Lead locks a mental model |
| **Weak-scout conclusion** | A weak model concludes a hard problem instead of just mapping the terrain | Scouts produce guiding artifacts + confidence levels only |
| **Polling waste** | Asking "done yet?" with no signal | Event-driven, backoff, monitor polling frequency |
| **Dual ownership** | Two agents hold edit rights over one scope | One owner per scope; handovers are recorded |
| **Priority-by-label** | Ordering work purely by P0/P1/P2, ignoring dependency/leverage | Reconcile by dependency, foundation, absorption |
| **Dissent-theater** | A peer manufactures disagreement / finding counts to look valuable | "Endorse the incumbent when it remains strongest" |
| **Frozen-wait mismatch** | Lead waits for `idle`, worker reports `done` | Unified state contract; done = collect results |
| **Protocol leak** | Peers learn orchestration mechanics and start self-coordinating | Coordination instructions live only in Supervisor/Lead profiles; MCP injected into lead/supervisor only |
| **Ceremony capture** | Every task gets a council, votes, reports; process outweighs evidence | Smallest useful topology; council only for decision-changing, genuinely independent propositions |
| **Forked independence** | A "reviewer" forked from the Lead inherits its framing and bias | Fresh session, neutral brief, exact candidate — never a fork |
| **Over-compression** | Core instructions compressed into lossy images/summaries | Exact rules and facts always stay as text |
| **Scout theater** | Dispatching a scout agent for something a search answers — burns tokens and returns false signals | Semantic search first, then ripgrep; spawn a Scout only when the terrain genuinely needs mapping |
| **Stale-listener debt** | After an infra/config update, old agents/schedules/heartbeats keep running and silently break the notification chain (Lead never gets woken) | On any update: restart all, archive old agents, delete task-local schedules and heartbeats |
| **Plan-file litter** | Completed plan files left in the repo; later agents grep into them and act on stale intent | Keep only active plans; delete completed plans after commit+push |
