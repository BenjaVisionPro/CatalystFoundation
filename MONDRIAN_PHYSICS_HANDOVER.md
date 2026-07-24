Catalyst Foundation — Mondrian Physics Handover

Read this first

This is the current handover for the Mondrian Physics sprint. It supersedes earlier plans where physics behaviours were treated as Mondrian-specific, where physics work leaked into graph construction, or where the current problem was treated primarily as force-directed tuning.

The product goal is simple to state and strict in implication:

Any existing Mondrian graph can opt into beautiful, configurable Physics.
Its author continues to build only their domain graph.

Graph authors must not create special nodes, edges, anchors, graph sources, or physics-aware builders. Physics is enabled at the boundary and owns all of its own coordination while active.

Current direction

The immediate target is no longer a generic force-directed graph equilibrium.

The target is a physically plausible hierarchical layout where the domain graph’s topology determines the structure:

* roots remain near the centre of the world;
* children extend outward from their parents;
* multiple independent trees form a forest;
* ordinary collisions prevent bodies from occupying the same space;
* the layout remains responsive to dragging and returns naturally afterwards.

Physics remains generic Bloc physics. Mondrian contributes the graph topology and presentation integration, but it does not become a special physics engine.

Box2D is the behavioural reference implementation.

Whenever Catalyst Physics behaviour differs from Box2D, treat the Catalyst implementation as incorrect until source or runtime evidence proves otherwise. Do not compensate for an unverified physics defect by adding layout forces, graph relationships, arbitrary tolerances, or Mondrian-specific heuristics.

Non-negotiable design invariants

1. Physics is generic Bloc physics. Bodies, worlds, constraints, joints, contacts and behaviours must work independently of Mondrian.
2. CFPhysicsMondrian is a façade, not a special physics engine. It coordinates a normal CFPhysicsWorld for a GtMondrian graph.
3. Behaviours are generic. Generic behaviours accept ordinary Physics elements and ordinary relationship data. They must not know about Mondrian, graph builders, anchors, or presentation effects.
4. Mondrian remains the graph. Do not add a generic graph framework, GraphSource, graph provider, graph adapter, duplicate topology, or duplicate world.
5. Graph topology remains truthful. Physics must not invent logical root-to-root graph edges or rewrite the domain hierarchy merely to improve the layout.
6. Edges and anchors remain standard Mondrian/Bloc objects. While Physics is active, they are adapted internally so all ordinary anchor types follow the displayed node geometry. Graph authors never select a “physics edge”.
7. Coordination details are not public graph API. Membership synchronisation, edge preparation, body adoption, constraint installation and playback lifecycle are façade internals.
8. Presentation uses Motion transform channels. Do not continuously replace ordinary graph node positions or introduce a second presentation framework.
9. Enabling Physics is reversible. ceaseBeingWorld is the complete inverse of beWorld, not a pause. After teardown the graph must be structurally indistinguishable from the original graph.
10. There is one Physics overlay. It renders all useful Physics diagnostic information. Internal rendering layers or passes remain implementation details.
11. Examples are examples, not tests. GT examples use assert: only. Proper test selectors live in the test package.
12. No Traits. Use normal classes and behaviours.

Intended public experience

The public experience remains deliberately small.

The established generic force-directed path is:

mondrian physics beWorld.
mondrian physics forceDirected.

The current hierarchical showcase may use an internal Mondrian coordination behaviour while its design is being proven, but graph authors must still enable Physics only at the façade boundary. They must not manually build centre anchors, root constraints, hierarchy joints, overlay layers, or playback infrastructure.

The complete inverse remains:

mondrian physics ceaseBeingWorld.

There is intentionally no public synchroniseNodes, synchroniseEdges, prepareEdges, installHierarchyConstraints, or startStepping requirement in application code.

Current architecture

Generic Physics

CFPhysicsWorld owns simulation state, including:

* members and body states;
* joints and constraints;
* contacts and contact persistence;
* collision detection;
* containment;
* world behaviours;
* step execution.

Its membership can be supplied by a collection or a provider block. The default remains recursive ownership of the world element.

Generic collision and solver behaviour must be consistent regardless of whether the bodies originated from a standalone Bloc example or a Mondrian graph.

This is important for the current investigation: Mondrian is allowed to configure bodies and presentation, but it must not create a separate collision model.

Generic force-directed behaviour

CFPhysicsForceDirectedBehaviour remains a generic world behaviour. It maintains:

* a spring for every declared connection;
* a repulsion constraint for every unordered pair of selected nodes;
* live shared scalar configuration, so changing a configured value updates the installed primitives rather than rebuilding the behaviour.

It uses a softened inverse-square response only for force-directed repulsion. Ordinary CFPhysicsRepulsionConstraint retains its generic constant-force default.

This behaviour remains valid generic Physics functionality, but it is not the current explanation for the hierarchical Mondrian defect. Do not resume tuning its constants as a substitute for verifying collision and contact behaviour.

Mondrian façade

GtMondrian >> #physics supplies a CFPhysicsMondrian façade stored on the Mondrian root.

When active, it:

1. uses the normal root-owned Physics world;
2. supplies mondrian nodeElements as the default body membership;
3. excludes edge elements from body membership;
4. adopts existing node positions as initial body positions;
5. fixes the canvas presentation coordinates while Physics is active;
6. wraps edge anchors with CFPhysicsMondrianPresentationAnchor so they use the displayed geometry of their ordinary reference elements;
7. starts stepping automatically once the root enters a scene graph.

The façade can be configured with bodyElements: when the graph has a deliberate subset of nodes that should become bodies. This is a Physics policy, not a graph-construction requirement.

Display coordinates and standard anchors

Physics presentation is delivered through Motion transform channels rather than changing underlying graph node positions every frame.

CFPhysicsMondrianDisplayedGeometry converts local geometry into sibling coordinates including the active transform. The presentation anchor delegates to this geometry, which is why lines, nearest-circle anchors, custom anchors and other normal anchor forms remain connected while nodes move.

This coordinate boundary was previously the cause of edges appearing to the right of their nodes.

Do not reintroduce global-coordinate conversion here. Mondrian nodes and edges share a parent, and anchors must resolve in that parent’s children coordinates.

The Physics overlay must use the same displayed-coordinate boundary. Diagnostic geometry that bypasses this conversion may appear detached from the visible bodies even when the underlying Physics positions are correct.

Reversible lifecycle

beWorld is paired with ceaseBeingWorld.

While enabled, the façade records:

* the original root layout;
* the original autoscale flag;
* children scale and translation factors;
* which elements already had a Physics façade;
* the exact scene-graph handler installed for automatic playback.

ceaseBeingWorld currently:

1. removes the playback handler and stops Motion playback;
2. restores ordinary edge anchors and root presentation configuration;
3. releases the owned world, its behaviours, bodies, constraints, joints and contacts;
4. removes world and session-created Physics façades from all elements touched by the session, including nodes retired by a live membership provider;
5. preserves Physics façades that existed before the Mondrian session;
6. removes the Mondrian Physics façade from the root.

The operation is idempotent. It is a teardown, not a “stop and leave the graph physical” operation.

Validation status: lifecycle implementation and focused tests are present in the current source. They still need GT execution before lifecycle work can be regarded as complete. Do not combine transition work with lifecycle repairs until those checks are green.

Current hierarchy model

The current Mondrian hierarchy is a forest, not a force-directed graph.

One root

A graph with one root should place that root exactly at the centre anchor.

Dragging may temporarily displace it, but the Physics relationship should return it naturally to the centre.

Multiple roots

A graph with multiple roots should treat every root independently:

* each root relates to the common world-centre anchor;
* roots are not logically connected to one another;
* roots separate through ordinary collision and any justified generic body interaction;
* dragging one root must not turn the roots into a rigid ring;
* released roots should return to a stable cluster around the centre.

Children

Parent-to-child relationships derive from the actual Mondrian hierarchy.

Children should grow outward from their parent while ordinary collisions keep bodies from overlapping.

Physics must not add graph relationships that do not exist in the domain model.

Rejected root-ring structure

The previously inspected CFPhysicsMondrianHierarchyBehaviour created:

* centre-to-root distance joints;
* root-to-root ring distance joints.

The root-to-root ring is not part of the accepted model.

Roots are not connected to one another in the logical graph. Do not preserve or recreate a ring merely because it produces convenient spacing.

Physics overlay

The Physics overlay is a core diagnostic surface, not a demonstration.

There is exactly one CFPhysicsOverlay.

It is responsible for rendering all useful information about the active Physics world. It may organise this internally into rendering passes or layers, but these must not become separate overlays, separate user-facing systems, or separately managed overlay lifecycles.

The overlay should progressively visualise:

* body geometry;
* body centres or centres of mass;
* body type and sleeping state;
* world bounds;
* joints;
* spring constraints;
* attraction and repulsion constraints;
* velocity and angular velocity;
* broad-phase candidate pairs;
* active contacts;
* contact manifolds;
* manifold contact points;
* manifold normals;
* point separation or penetration;
* normal and tangent impulses;
* warm-start state;
* solver diagnostics where they provide concrete evidence.

The long-term role of CFPhysicsOverlay is equivalent to the Box2D debug renderer: it should expose enough of the simulation to determine which stage is incorrect without guessing from the final visual result.

Contact manifold rendering

The next overlay addition is contact-manifold rendering.

It belongs inside the existing CFPhysicsOverlay, not in a second overlay and not in a parallel collection of contact overlay elements.

The internal rendering pass should display, for every relevant active contact:

* each manifold contact point;
* the manifold normal from each point;
* the relationship between two points when a manifold contains two points;
* separation or penetration;
* impulses when useful for solver diagnosis.

Every contact coordinate must pass through the overlay’s existing world-to-displayed-coordinate conversion.

This diagnostic allows us to distinguish:

* no broad-phase pair;
* pair without a manifold;
* incorrect manifold geometry;
* correct manifold with ineffective contact constraints;
* correct solve with incorrect presentation synchronisation.

Current collision investigation

The highest-priority defect is overlapping nodes in the Mondrian hierarchy.

Standalone Physics examples such as clickMe use the same broad collision architecture and appear to separate bodies correctly. Mondrian nodes still overlap.

Do not assume this is caused by insufficient hierarchy spacing or weak repulsion.

The current investigation should compare the Box2D-equivalent pipeline using the smallest reproducible case:

* three identical dynamic rectangles;
* the same initial centre;
* one world-centre anchor;
* one distance joint from each rectangle to that anchor;
* no root-to-root joints;
* ordinary Box2D collision semantics.

Compare, stage by stage:

1. body shape and transform mapping;
2. world membership;
3. broad-phase candidate pairs;
4. generated manifolds;
5. manifold normals;
6. manifold point count;
7. contact persistence and feature identifiers;
8. prepared contact constraints;
9. prepared distance-joint constraints;
10. warm-start impulses;
11. solver impulses;
12. final solved transforms;
13. displayed transforms.

Do not change hierarchy radius calculations, repulsion, spring values or presentation transitions until this comparison identifies where the implementations diverge.

Box2D reference alignment

Box2D is the behavioural reference, not merely inspiration.

When Catalyst behaviour differs:

1. identify the equivalent Box2D type or pipeline stage;
2. inspect the selected Box2D reference version;
3. map the relevant state and algorithm into Catalyst;
4. produce source or runtime evidence for the divergence;
5. fix the mapping;
6. verify it with isolated tests and the overlay.

Do not describe an implementation as “Box2D-style” when it is an independent approximation.

A confirmed mismatch already identified in prior inspection was the default for connected-body collision:

CFPhysicsDistanceJoint >> initialize
    collideConnected := true

Box2D distance joints default to connected-body collision being disabled unless explicitly enabled.

Treat differences like this as semantic mapping defects. Do not hide them with additional layout forces.

Previous improvised manifold or fallback branches must not be treated as reference implementations merely because they superficially resembled Box2D.

Showcase and graph builder

CFPhysicsMondrianExampleGraphBuilder remains deliberately Physics-agnostic.

It builds a guided, deterministic random-ish hierarchy for examples:

* 1–7 root nodes;
* level 1: selected roots have 0–20 children;
* level 2: a few level-1 nodes have 5–10 children, while most have none.

Depth, root range, parent count by level and child count by level are configurable. Its deterministic seed and state are internal; callers do not need to know about them.

The builder supplies domain topology only.

It must not:

* create Physics bodies;
* create anchors;
* create hierarchy joints;
* choose collision policy;
* install playback;
* know about the overlay.

The visual acceptance example must enable Physics through the façade and must not call internal synchronisation or installation selectors.

Standalone minimal examples must also exist so collision behaviour can be compared without Mondrian presentation complexity.

Completed work

The following work is considered completed in the current branch, subject to the explicit validation notes below.

Physics overlay foundation

* A single CFPhysicsOverlay exists.
* The inspector toggle controls only CFPhysicsOverlay.
* The overlay uses BlOverlayElement.
* Overlay layering issues were corrected.
* Displayed body geometry is rendered using the active presentation transform.
* Native Motion transform handling was corrected and covered by a focused test.
* Body rendering was made visually lighter so diagnostics remain readable.

Mondrian presentation

* Physics presentation uses Motion transform channels.
* Standard Mondrian anchors are adapted internally.
* Displayed geometry resolves in sibling coordinates.
* The earlier node/edge horizontal-offset bug was corrected.
* Graph authors remain unaware of presentation wrappers and coordinate conversion.

Lifecycle

* beWorld and ceaseBeingWorld are designed as inverses.
* Session-created façades and world resources are tracked for teardown.
* Pre-existing Physics façades are preserved.
* Playback handler identity is retained so the exact handler can be removed.
* Teardown is intended to be idempotent.

Lifecycle examples still require GT execution before this item is considered fully validated.

Hierarchy direction

* The layout target was clarified as a forest.
* One root belongs at the centre.
* Multiple roots cluster around the centre independently.
* Children grow outward from parents.
* Roots are not logically connected to each other.
* The previous root-ring model was rejected.

Investigation direction

* Layout tuning has been paused.
* Box2D was selected as the behavioural reference.
* Collision and contact parity are now investigated stage by stage.
* Contact manifold visualisation was selected as the next diagnostic implementation.

Verification map

The main source locations are expected to include:

* src/BVC-Foundation-Physics-Core/CFPhysicsWorld.class.st
    Generic world ownership, membership and release.
* src/BVC-Foundation-Physics-Core/CFPhysicsForceDirectedBehaviour.class.st
    Generic force-directed behaviour.
* src/BVC-Foundation-Physics-Mondrian/CFPhysicsMondrian.class.st
    Mondrian façade, presentation setup and reversible lifecycle.
* src/BVC-Foundation-Physics-Mondrian/CFPhysicsMondrianHierarchyBehaviour.class.st
    Current hierarchy coordination. Inspect this for the rejected root-ring joints.
* src/BVC-Foundation-Physics-Mondrian/CFPhysicsMondrianPresentationAnchor.class.st
* src/BVC-Foundation-Physics-Mondrian/CFPhysicsMondrianDisplayedGeometry.class.st
    Standard-edge support and displayed-coordinate conversion.
* src/BVC-Foundation-Physics-Motion/
    Motion playback and transform presentation.
* src/BVC-Foundation-Physics-Tools/CFPhysicsOverlay.class.st
    The single Physics diagnostic overlay.
* src/BVC-Foundation-Physics-Tests/CFPhysicsMondrianTests.class.st
    Mondrian integration examples.
* src/BVC-Foundation-Physics-Tests/CFPhysicsCleanSlateTests.class.st
    Isolated Physics world, collision, constraint and lifecycle tests.

Exact package locations and selectors must be confirmed against the supplied source before editing. Do not invent selectors from this handover.

Current tasks

The next work is deliberately ordered.

1. Extend the existing Physics overlay with contact manifolds

Inspect the current CFPhysicsOverlay implementation and its established drawing conventions.

Add contact-manifold rendering internally to that one overlay.

The initial useful rendering should include:

* contact points;
* manifold normals;
* two-point manifold connection;
* separation or penetration.

Add impulses only after the basic geometry is proven correct and readable.

Do not add a second overlay or a CFPhysicsContactOverlayElement system.

2. Build the smallest hierarchy collision comparison

Create or identify an isolated example containing:

* three identical dynamic rectangles;
* one common initial centre;
* one centre anchor;
* one distance joint per body;
* no body-to-body hierarchy joints.

The same logical case should be inspectable outside Mondrian and through Mondrian.

3. Compare the pipeline against Box2D

Capture or inspect:

* candidate pairs;
* manifolds;
* normals;
* points;
* feature IDs;
* prepared constraints;
* impulses;
* solved transforms.

Use the overlay where visual evidence is useful and focused tests where exact values are required.

4. Correct semantic mismatches

Fix proven divergences in generic Physics.

Do not place collision fixes in CFPhysicsMondrian.

In particular, review defaults such as collideConnected against the selected Box2D reference and ensure intentional differences are explicit rather than accidental.

5. Remove rejected root-ring behaviour

Once collision behaviour is understood, ensure the hierarchy model contains no root-to-root ring constraints.

Each root should relate independently to the centre anchor.

Do not add fake graph relationships.

6. Validate hierarchy behaviour

Verify:

* one root sits at the exact centre;
* one root returns after dragging;
* multiple roots form a stable cluster;
* dragging one root does not rigidly move all roots;
* children extend outward;
* bodies do not overlap;
* ordinary Mondrian edges remain attached;
* the overlay remains aligned with displayed bodies.

7. Complete lifecycle validation

Run the CeaseBeingWorld examples in CFPhysicsMondrianTests and:

CFPhysicsCleanSlateTests
    >> #testCeaseBeingWorldReleasesItsBodiesAndConstraints

Also visually inspect:

enable → cease → enable

Confirm that no session-owned façade, world, edge wrapper, Motion presentation, event handler, body, constraint, joint or contact survives teardown.

8. Resume reversible transitions only afterwards

Do not resume transition work until the settled hierarchy is physically and visually correct.

The eventual façade transition should:

1. capture the ordinary Mondrian presentation;
2. settle Physics without visibly presenting intermediate chaos;
3. smoothly move displayed nodes to the settled state;
4. begin live Physics playback.

On ceaseBeingWorld, it should:

1. stop live simulation;
2. restore the ordinary Mondrian layout as the presentation target;
3. animate back smoothly;
4. perform full teardown.

Use the existing Motion transform-channel infrastructure.

The graph must never snap through 0 @ 0 or briefly show mismatched node and edge coordinate systems.

Acceptance criteria

The current slice is complete when:

* the single Physics overlay renders contact manifolds correctly;
* manifold visuals stay aligned with transformed Mondrian nodes;
* the minimal three-body case can be traced through the collision pipeline;
* Catalyst behaviour is compared directly with Box2D;
* proven semantic mismatches are corrected in generic Physics;
* no root-to-root ring constraints remain;
* one-root and multi-root hierarchy behaviour is stable;
* overlapping Mondrian nodes are resolved by correct Physics rather than visual heuristics;
* lifecycle tests and enable/cease/re-enable checks are green;
* no rejected diagnostic or fallback implementation remains in the final branch.

Guardrails for future work

* Never make a generic behaviour Mondrian-specific merely because its first showcase is a graph.
* Never require a graph author to know about bodies, Motion, anchor wrappers, coordinates, world membership or solver details.
* Never mutate standard graph structure without recording exactly how to restore it.
* Never invent graph relationships to make the layout more convenient.
* Never expose an implementation selector merely to make an example work.
* Prefer a small proven abstraction over speculative generalisation.
* When a visual bug appears, inspect the coordinate and presentation boundary before changing Physics forces.
* When bodies overlap, inspect broad phase, manifolds, contacts and solver constraints before adding repulsion.
* When Catalyst behaviour differs from Box2D, prove and correct the mapping before introducing a workaround.
* Keep generic Physics changes outside Mondrian packages.
* Keep the Physics overlay singular; internal layers do not justify separate overlays.
* Keep tests isolated and use examples for human visual acceptance.
* Do not claim a change has been implemented unless the supplied source was inspected and the resulting code or archive was actually produced.
* Do not treat plausible-looking output as proof of correct Physics.

The questions that should guide every change are:

Does this make Physics feel native to any existing Mondrian graph while keeping generic Physics independent of Mondrian?

and:

Is the observed behaviour explained by the actual Physics pipeline and aligned with the Box2D reference, or are we compensating for an unproven defect?

If either answer is unsatisfactory, reconsider the seam before adding code.