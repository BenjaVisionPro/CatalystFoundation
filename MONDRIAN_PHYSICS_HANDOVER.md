# Catalyst Foundation — Mondrian Physics Handover

## Read this first

This is the current handover for the Mondrian Physics sprint. It supersedes
earlier plans where physics behaviours were treated as Mondrian-specific or
where physics work leaked into graph construction.

The product goal is simple to state and strict in implication:

> Any existing Mondrian graph can opt into beautiful, configurable Physics.
> Its author continues to build only their domain graph.

Graph authors must not create special nodes, edges, anchors, graph sources, or
physics-aware builders. Physics is enabled at the boundary and owns all of its
own coordination while active.

## Non-negotiable design invariants

1. **Physics is generic Bloc physics.** Bodies, worlds, constraints and
   behaviours must work independently of Mondrian.
2. **`CFPhysicsMondrian` is a façade, not a special physics engine.** It
   coordinates a normal `CFPhysicsWorld` for a `GtMondrian` graph.
3. **Behaviours are generic.** `CFPhysicsForceDirectedBehaviour` accepts
   ordinary Physics elements and `Association` connections. It must not know
   about Mondrian, graph builders, anchors, or presentation effects.
4. **Mondrian remains the graph.** Do not add a generic graph framework,
   `GraphSource`, graph provider, graph adapter, or a duplicate world.
5. **Edges and anchors remain standard Mondrian/Bloc objects.** While Physics
   is active they are adapted internally so _all_ ordinary anchor types follow
   the displayed node geometry. Graph authors never select a “physics edge”.
6. **Coordination details are not public graph API.** Membership
   synchronisation, edge preparation, body adoption, and playback lifecycle
   are façade internals.
7. **Enabling Physics is reversible.** `ceaseBeingWorld` is the complete
   inverse of `beWorld`, not a pause. After teardown the graph must be
   structurally indistinguishable from the original graph.
8. **Examples are examples, not tests.** GT examples use `assert:` only.
   Proper test selectors live in the test package.

## Intended public experience

The normal path is deliberately small:

```smalltalk
mondrian physics beWorld.
mondrian physics forceDirected.
```

`forceDirected` establishes the world if necessary. A caller may configure the
ordinary world or the returned generic behaviour when they genuinely need to:

```smalltalk
world := mondrian physics beWorld.
world gravity: 0 @ 0.

behaviour := mondrian physics forceDirected.
behaviour
    restLength: 80;
    repulsionSofteningDistance: 50.
```

The complete inverse is:

```smalltalk
mondrian physics ceaseBeingWorld.
```

There is intentionally no public `synchroniseNodes`, `synchroniseEdges`,
`prepareEdges`, or `startStepping` requirement in application code.

## Current architecture

### Generic Physics

`CFPhysicsWorld` owns simulation state: members, body states, constraints,
contacts, joints, containment, and behaviours. Its membership can be supplied
by a collection or a provider block; the default remains recursive ownership
of the world element.

`CFPhysicsForceDirectedBehaviour` is a generic world behaviour. It maintains:

- a spring for every declared connection;
- a repulsion constraint for every unordered pair of selected nodes;
- live shared scalar configuration, so changing a configured value updates the
  installed primitives rather than rebuilding the behaviour.

It uses a softened inverse-square response only for force-directed repulsion.
Ordinary `CFPhysicsRepulsionConstraint` retains its generic constant-force
default. This is important: force-directed tuning must not silently alter other
physics users.

The world is contained by default. Its boundary acts as floor, walls, and
ceiling, while remaining configurable through normal Physics APIs.

### Mondrian façade

`GtMondrian >> #physics` supplies a `CFPhysicsMondrian` façade stored on the
Mondrian root. When active, it:

1. uses the normal root-owned Physics world;
2. supplies `mondrian nodeElements` as the default body membership;
3. excludes edge elements from body membership;
4. adopts existing node positions as initial body positions;
5. fixes the canvas presentation coordinates while Physics is active;
6. wraps edge anchors with `CFPhysicsMondrianPresentationAnchor` so they use
   the displayed geometry of their ordinary reference elements;
7. starts stepping automatically once the root enters a scene graph.

The façade can be configured with `bodyElements:` when the graph has a
deliberate subset of nodes that should become bodies. This is a physics policy,
not a requirement for graph construction.

### Display coordinates and standard anchors

Physics presentation is delivered through Motion transform channels, rather
than changing the underlying graph node positions every frame.
`CFPhysicsMondrianDisplayedGeometry` converts local geometry into sibling
coordinates including the active transform. The presentation anchor delegates
to this geometry, which is why lines, nearest-circle anchors, custom anchors,
and other normal anchor forms remain connected while nodes move.

This coordinate boundary was previously the cause of edges appearing to the
right of their nodes. Do not reintroduce global-coordinate conversion here:
Mondrian nodes and edges share a parent, and anchors must resolve in that
parent’s children coordinates.

## Reversible lifecycle

`beWorld` is now paired with `ceaseBeingWorld`.

While enabled, the façade records the original root layout, autoscale flag,
children scale and translation factors, and which elements already had a
Physics façade. It also retains the exact scene-graph handler installed for
automatic playback.

`ceaseBeingWorld` currently:

1. removes the playback handler and stops Motion playback;
2. restores ordinary edge anchors and root presentation configuration;
3. releases the owned world, its behaviours, bodies, constraints, joints and
   contacts;
4. removes world and session-created Physics facades from all elements touched
   by the session, including nodes retired by a live membership provider;
5. preserves Physics facades that existed before the Mondrian session;
6. removes the Mondrian Physics façade from the root.

The operation is idempotent. It is a teardown, not a “stop and leave the graph
physical” operation.

**Current validation status:** the lifecycle implementation and focused tests
are present in the current source and need GT execution before being regarded
as complete. Do not fold transition work into it until those checks are green.

## Force-directed status

The current defaults are an experiment, not a finished visual design:

| Setting | Current value |
| --- | ---: |
| Rest length | 80 |
| Spring stiffness | 600 |
| Spring damping | 400 |
| Maximum spring force | 250000 |
| Repulsion | 100000 |
| Repulsion softening distance | 50 |
| Maximum repulsion distance | 200 |
| Extra velocity damping | 8 |

The softened response corrected the worst high-degree-node collapse, but the
showcase is **not yet visually good enough**. Do not claim force-directed is
finished merely because its constraints work. The actual acceptance bar is a
quickly settled, compact, readable graph with no overlapping hubs and natural
edge lengths.

No unrelated visual “effects” should be added while this is unresolved.
Breathing, wind, sparks, and similar future behaviours are generic effects;
they are not part of force-directed implementation and must not know about it.

## Showcase and graph builder

`CFPhysicsMondrianExampleGraphBuilder` is deliberately physics-agnostic. It
builds a guided, deterministic random-ish graph for examples:

- 1–7 root nodes;
- level 1: selected roots have 0–20 children;
- level 2: a few level-1 nodes have 5–10 children; most have none.

Depth, root range, parent count by level, and child count by level are
configurable. Its deterministic seed/state is internal; callers do not need to
know about it.

`CFPhysicsMondrianShowcaseExamples >> #forceDirectedGraph` is the visual
acceptance example. It uses the builder, disables gravity for the force layout,
and simply enables `forceDirected`. It must never manually install playback or
call internal synchronisation.

## Verification map

The main source locations are:

- `src/BVC-Foundation-Physics-Core/CFPhysicsWorld.class.st` — generic world
  ownership, membership and release.
- `src/BVC-Foundation-Physics-Core/CFPhysicsForceDirectedBehaviour.class.st`
  — generic force-directed behaviour and defaults.
- `src/BVC-Foundation-Physics-Mondrian/CFPhysicsMondrian.class.st` — façade,
  presentation setup and reversible lifecycle.
- `src/BVC-Foundation-Physics-Mondrian/CFPhysicsMondrianPresentationAnchor.class.st`
  and `CFPhysicsMondrianDisplayedGeometry.class.st` — standard-edge support.
- `src/BVC-Foundation-Physics-Motion/` — Motion playback and transform
  presentation.
- `src/BVC-Foundation-Physics-Tests/CFPhysicsMondrianTests.class.st` —
  Mondrian integration examples.
- `src/BVC-Foundation-Physics-Tests/CFPhysicsCleanSlateTests.class.st` —
  isolated Physics behaviour/world tests.

Before advancing, run the `CeaseBeingWorld` examples in
`CFPhysicsMondrianTests` and
`CFPhysicsCleanSlateTests >> #testCeaseBeingWorldReleasesItsBodiesAndConstraints`.

## Next sprint: ideal layout, then reversible transition

The next work is deliberately ordered.

### 1. Prove teardown first

Get every lifecycle example green and visually inspect enable → cease → enable
again. Confirm no Physics facade, world, edge wrapper, Motion presentation, or
event handler remains after teardown.

### 2. Solve the ideal force-directed target

Tune and, if necessary, improve the generic force-directed model until the
pre-settled graph itself is attractive. This means measuring overlap, edge
length, component spacing, and settling time—not merely adjusting one numeric
constant after another.

The target is a good Physics layout before any visual transition exists. A
transition must not hide a bad equilibrium.

### 3. Add a reversible presentation transition

Once the target is good, the façade should:

1. capture the ordinary Mondrian presentation;
2. settle the Physics state without visibly presenting intermediate chaos;
3. smoothly move the displayed graph to the settled state;
4. begin normal live Physics playback.

On `ceaseBeingWorld`, it should do the opposite: stop live simulation, restore
the ordinary Mondrian layout as the target, smoothly animate back, then perform
the full teardown described above. The graph must never snap through `0@0` or
briefly show mismatched node/edge coordinate systems.

Use the existing Motion transform-channel infrastructure; do not add a second
animation framework or force graph authors to animate their nodes themselves.

### 4. Re-test ordinary graphs

The acceptance examples must include normal Mondrian graphs using ordinary
lines and several anchor styles, existing layouts, nested node presentation,
dynamic nodes/edges, and enable/cease/re-enable cycles. The physics-aware
example builder is useful for stress testing but cannot be the only proof.

## Guardrails for future work

- Never make a behaviour Mondrian-specific merely because its first showcase
  is a graph.
- Never require a graph author to know about bodies, Motion, anchor wrappers,
  coordinates, or world membership.
- Never mutate standard graph structure without recording how to restore it.
- Never expose an implementation selector just to make examples work.
- Prefer a small, proven abstraction over speculative generalisation.
- When a visual bug appears, inspect the coordinate/presentation boundary
  before changing Physics forces.
- Keep tests isolated and use examples for human visual acceptance.

The question that should guide every change is:

> Does this make Physics feel native to any existing Mondrian graph while
> keeping generic Physics independent of Mondrian?

If not, reconsider the seam before adding code.
