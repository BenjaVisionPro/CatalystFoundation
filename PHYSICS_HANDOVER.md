# Catalyst Foundation Physics — Production Handover

**Checkpoint:** 21 July 2026, after Foundation commit `5dac328` (`fixes`).  
**Scope:** Catalyst Foundation Physics and its Bloc integration. Catalyst Runtime is not part of the implementation under investigation.

This document is intentionally a diagnostic handover, not a fix plan disguised as a conclusion. It records what is known from source and executable GT examples, what remains a hypothesis, and the smallest investigation that can turn each hypothesis into evidence.

## 1. Purpose and product direction

Catalyst Foundation Physics is a physics engine for Bloc and GT user interfaces. It is not a general-purpose, Box2D-compatible 2D game engine.

The target user experience is expressive, inspectable UI behaviour: controls and elements can have mass, velocity, collision, constraints, joints, containment, pointer interaction, and motion presentation while staying ordinary Bloc elements. Game-shaped features are only worthwhile when they help that UI goal. Features that primarily support gameplay should be treated as lower priority and discussed before implementation.

The current production-readiness track is therefore:

1. Make the simulation correct, deterministic, and inspectable.
2. Exercise it through real Bloc examples rather than only isolated mechanics tests.
3. Turn the strongest interactions into user-facing showcase examples.
4. Put the framework in front of users for feedback once the showcase set is robust.

The first showcase is **Click Me**: real `BrButton`s begin in random positions with initial motion, use light gravity, collide with one another and their world bounds, bounce when clicked, and can be dragged. Releasing a dragged button should retain the pointer-derived release velocity. The standard presentation is `740@400` (1.85:1), with a minimum height of 250.

This example is deliberately more than a demo. It is a system test of real visual geometry, presentation transforms, ordinary button actions, drag events, containment, contact persistence, restitution, and recovery from overlap.

## 2. Architectural commitments

These are working constraints, not optional style preferences.

| Area | Commitment |
| --- | --- |
| Authority | Physics owns authoritative body state, collision, constraints, stepping, and deterministic ordering. |
| Motion | Motion owns playback, transform composition, render updates, and presentation. It does not feed back into simulation. |
| Presentation | Physics does not present implicitly. Presentation is explicit (including `present` and `presentAtAlpha:`). |
| Stepping | Simulation operates on step-local body states and commits only at the appropriate boundary. |
| Determinism | Ordering, contact publication, and observable results take precedence over performance tuning. |
| Inspectability | Major intermediate values are first-class objects available through GT examples and inspectors. |
| Integration | Bloc descendants that only decorate a physics element may be excluded from the world; the parent remains the physics body. |
| Scope discipline | Do not turn the framework into a generic game engine merely because a familiar game-engine feature exists. |

The earlier motion handover remains relevant: physics never compensates for motion, and motion never changes the physical result. Physics rotations are radians; Bloc/Motion presentation rotation requires degrees. This conversion was corrected during the Click Me investigation.

## 3. Current system map

Physics is organised into these Foundation packages:

| Package | Responsibility |
| --- | --- |
| `BVC-Foundation-Physics-Core` | worlds, bodies, materials, world membership, containment, forces, joints, pointer constraints, stepping configuration |
| `BVC-Foundation-Physics-Collision` | shapes, transforms, broadphase candidates, GJK/EPA, manifolds, sweep/TOI and continuous-impact primitives |
| `BVC-Foundation-Physics-Pipeline` | the explicit staged simulation pipeline, contact lifecycle, constraint preparation, islands, solving, sleeping, events |
| `BVC-Foundation-Physics-Bloc` | Bloc geometry and manifold adaptation |
| `BVC-Foundation-Physics-Motion` | explicit physics-to-Motion presentation bridge |
| `BVC-Foundation-Physics-Examples` | showcase examples, currently including `CFPhysicsShowcaseExamples>>clickMe` |
| `BVC-Foundation-Physics-Tests` | GT executable examples and regression coverage (`CFPhysicsCleanSlateTests`) |
| `BVC-Foundation-Physics-Tools` | inspection and visual tooling |

The production step pipeline is constructed in `CFPhysicsStepPipeline class>>manifoldBuilder:`:

```text
body-state capture
  → velocity integration
  → swept candidate-pair finding
  → continuous-impact stage
  → contact update/lifecycle publication
  → contact and joint constraint preparation
  → island construction
  → waking
  → island solve
  → post-solve publication
  → sleeping
  → contact events
```

`CFPhysicsWorld>>step` is the world-level cutover. It sends its prior `activeContacts` into that pipeline and replaces them with `lastStepResult activeContacts` afterwards. This is the contract exercised by the two persistence failures described below.

## 4. What has been completed

The following is present in current Foundation source and has been exercised during the project:

- Core dynamic/static body state, force/velocity integration, material properties, and world membership.
- Deterministic pair ordering and contact lifecycle objects (`began`, `continued`, `ended`, `active`).
- Broadphase candidate discovery over predicted swept states.
- Convex collision using transform-explicit GJK/EPA and Bloc geometry adaptation.
- Constraint preparation and soft contact solving, including friction/restitution paths.
- Sensors and contact events without solid constraints.
- CCD based on explicit sweeps, conservative advancement, earliest-impact selection, an iterative impact loop, remaining-time handling, and deterministic publication.
- Distance, revolute, fixed, and rail joints, with limits/motors where implemented.
- Islands, sleeping/waking, and deterministic ordering.
- World containment, now using a body AABB rather than unrotated element extent.
- Physics/Motion presentation, including radians-to-degrees conversion for visual rotation.
- Pointer constraints driven by Bloc drag events.
- The initial Click Me showcase and visual collision overlay tooling.

The work has repeatedly found meaningful defects only once real UI geometry and interaction were involved. That is expected and supports continuing the showcase-led validation approach.

## 5. Recent Click Me findings and changes

### 5.1 Visual rotation versus physical rotation — corrected

The blue collision overlay and rendered buttons initially disagreed when buttons rotated. Investigation showed physics rotation (radians) being given directly to Motion/Bloc presentation, which expects degrees. The presentation bridge now converts radians to degrees. This made the visible button orientation and physics overlay agree.

### 5.2 Containment against unrotated extent — corrected

Containment initially used the element's original/unrotated bounds. A rotated button could visibly pass through an edge while its unrotated extent was still inside. Containment now uses the body's AABB.

### 5.3 CCD suppressing unrelated discrete recovery — corrected, then exposed later seam issues

A frame containing one positive continuous impact previously took an impact-only path: ordinary contacts were not prepared or solved. This explained the observation that some buttons appeared to stop colliding while another impact occurred.

The current pipeline instead:

1. commits the result of a continuous-impact loop,
2. recaptures post-impact body states and zero-time candidate pairs,
3. merges those ordinary pairs with impact contacts,
4. prepares constraints from the unified active contact set, and
5. runs an ordinary zero-time recovery solve after CCD.

This is directionally aligned with Box2D's principle that a continuous collision elsewhere must not make unrelated persistent contacts disappear. It is also directly covered by `continuousImpactDoesNotSuppressSeparateOverlapRecovery`.

That correction does **not** mean all overlap/persistence behaviour is now settled. The current failures below are the next evidence.

### 5.4 Manifold penetration information — corrected in current checkpoint

The GJK/EPA and rectangle collision paths were producing contact points without a negative separation. A solver then saw zero penetration even when EPA/rectangle collision had calculated one, preventing meaningful positional recovery. Current source assigns each contact point `separation: penetration negated`.

This is a concrete source-level correction. It needs continued regression coverage across all manifold producers; only the relevant EPA and rectangle paths were changed in the latest checkpoint.

## 6. Current failures reported by GT examples

The screenshots at 10:20–10:21 show three failures. None should be “fixed” by weakening an assertion until its contract and geometry are established.

| Failing example | Observed result | Contract being asserted |
| --- | --- | --- |
| `pointerDraggingStartsForAGlamorousButton` | `world pointerConstraints size` is `0`, expected `1`, immediately after simulated drag-start/move. | A primary pointer drag installs a world pointer constraint, lets a later step move the body, and removes the constraint at drag end. |
| `stepPipelineCarriesActiveContactsIntoTheNextStep` | `secondResult continuedContacts size` is `0`, expected `1`. | Contact active at the end of one explicit pipeline step remains active and is published as continued on the next step. |
| `worldCarriesActiveContactsExplicitlyBetweenSteps` | `secondResult continuedContacts size` is `0`, expected `1`. | The world forwards its active contacts to the next step and replaces its active collection with the second result. |

The two contact failures share geometry and lifecycle behaviour. They should be investigated together, but they do not prove that the world handoff is broken: both may originate before the handoff, when the second step's narrowphase produces no manifold at the recovered seam.

## 7. Detailed issue notes and investigation plans

### A. Pointer drag starts but no pointer constraint is visible

**Status:** reproducible; cause not confirmed.

**Evidence from the failing example**

`pointerDraggingStartsForAGlamorousButton` now builds a `BlDragStartEvent` and a `BlDragEvent` from mouse events and gives both `startButtons: BlMouseButton primary`. The screenshot shows those non-nil event objects but `world pointerConstraints size` remains zero after dispatch.

`CFPhysicsPointerDragHandler` installs filters for exactly:

- `BlDragStartEvent` → `beginFrom:`
- `BlDragEvent` → `continueFrom:`
- `BlDragEndEvent` → `endFrom:`

All three reject events unless `isPrimaryButtonDrag` is true. On begin, the handler finds the element's world, synchronises membership, requires a dynamic body, converts the event position from global to world-local, creates a `CFPhysicsPointerConstraint`, and calls `world addPointerConstraint:`.

**Most likely causes**

1. **Event dispatch semantics differ from the synthetic test.** `BlSpace simulateEvents:on:` may deliver the event differently from the mouse processor's normal pipeline: filter phase, target, current target, gesture source, or propagation may not match. The event's `target` and `gestureSource` are not set by the current test, whereas `BlMouseProcessor` sets them before firing real drag events.
2. **The drag handler is not installed on this button.** `enablePointerDragging` may have an installation/lifecycle issue, or a handler may be replaced/uninstalled as the element joins the scene graph.
3. **`beginFrom:` exits early.** The world can be nil, the body can be nil, or it can be non-dynamic. The test calls `world synchroniseMembership`, so this is less likely but must be observed rather than assumed.
4. **A later event removes the newly created constraint.** The current test only sends start/move before the first assertion, so this is less likely; it would require an unexpected handler or event conversion path.

**What the current screenshot rules out**

It does not rule out any of the first three causes. Seeing `dragStart` and `dragMove` objects in the inspector proves construction, not that the handler received them in the same way a live `BlMouseProcessor` delivers them.

**Minimal confirmation sequence**

1. Add a temporary focused GT example/probe that inspects the button's installed event filters and the `CFPhysicsPointerDragHandler` instance after `enablePointerDragging`.
2. Dispatch a fully populated synthetic start event, matching `BlMouseProcessor>>fireAsDragStartEvent:`: set `startButtons`, `target`, and `gestureSource` to the button.
3. Assert the handler's `constraint` immediately after dispatch, before inspecting `world pointerConstraints`. This distinguishes “handler did not run” from “world collection did not retain it.”
4. Compare that result with a true mouse-down/move sequence processed by a live `BlMouseProcessor`, not only `simulateEvents:`.
5. Remove the temporary instrumentation after the causal path is proven.

**Potential fixes only after confirmation**

- If synthetic events are incomplete, make the test reproduce Bloc's production event construction; do not change physics production code.
- If filters are skipped by `simulateEvents:`, use the proper Bloc test harness or adjust the example's test strategy.
- If the handler is absent or exits because membership/body state is unavailable, fix the installation or membership lifecycle and add an explicit regression.

### B. Contact is not continued on the immediately following step

**Status:** reproducible; likely tied to the zero-penetration seam, but not confirmed.

**Evidence from source and examples**

Both failing examples start with a static ground at `0@0`, a dynamic box at `20@15`, and dimensions `100@20` and `60@20`. The first step reports one active contact. The second step receives that active contact as `previousContacts`, but publishes no continued contact.

The contact updater's algorithm is straightforward:

1. index prior contacts by pair key,
2. enumerate candidate pairs in deterministic order,
3. ask the manifold builder whether each pair has a manifold,
4. if it does, update the prior contact and mark it continued,
5. if it does not, mark the prior contact ended.

Therefore, a continued count of zero means one of two things:

- the pair was absent from the second step's candidate pairs, or
- the pair existed but its new manifold was nil.

It does **not** by itself mean `CFPhysicsWorld` failed to pass `activeContacts` through. The explicit pipeline version fails too, which strongly points below the world boundary.

**Leading hypothesis: exact-seam loss after positional recovery**

The latest solver change leaves a `0.01` world-unit positional slop:

```smalltalk
penetration := separation negated - self contactPositionSlop.
...
CFPhysicsSoftStepSolver >> contactPositionSlop [ ^ 0.01 ]
```

This is a real solver policy, not a `closeTo:` assertion tolerance. The current `0.01` is hard-coded in the solver and has **not** yet been promoted to explicit world/step configuration.

The slop itself is a normal numerical-stability concept: recovering exactly to mathematical contact can leave floating-point geometry on the separating side, causing the next narrowphase query to return nil. However, this particular implementation leaves an open gap rather than preserving a contact through a contact-cache/speculative-contact policy. That makes it a plausible explanation for the screenshot, not a confirmed cause.

**Other plausible causes**

1. Pair discovery uses swept AABBs and may exclude a perfectly resting pair if the AABBs no longer intersect under its edge semantics.
2. The Bloc manifold builder may treat touching edges as non-overlap, while the solver's position correction leaves the bodies exactly touching or slightly separated.
3. The recovery solve may alter a step-local body state but not leave authoritative state/contact anchors in a form the next capture reproduces.
4. Contact identity/key ordering could differ, although the expected same pair and deterministic ordering make this less likely.

**Minimal confirmation sequence**

Run the explicit-pipeline example and inspect, in this order:

1. `firstResult activeContacts first pair key` and the second step's `previousContacts` key.
2. second step output from `CFPhysicsPairFinderStage`: does it contain the same pair?
3. second step `CFPhysicsContactUpdateStage` input pair and `CFPhysicsBlocManifoldBuilder` result: nil or a manifold?
4. the captured transforms/AABBs immediately before second-step pair finding.
5. the prior manifold's normal, local anchors, and separation, then the fresh manifold's equivalent data if it exists.
6. body positions after first step, with a comparison against visual/physical extents.

One focused probe should report this chain in the `CFPhysicsStepPipelineResult` stage outputs. It should not add broad logging to the production step loop.

**Decision criteria**

- Pair absent → investigate broadphase/AABB inclusivity and post-solve state capture.
- Pair present, manifold nil → investigate touching-vs-overlap contract in Bloc collision/manifold generation and whether contact persistence/speculation is required.
- Pair/manifold present, still no continuation → inspect contact updater key/update logic; this would be a lifecycle bug.

**Potential fixes only after confirmation**

- Define a contact persistence policy explicitly (e.g. retained manifold/cache tolerance or speculative contact), with deterministic ordering and a clear release threshold.
- Make pair/manifold boundary semantics inclusive if that is the agreed physical contract.
- Move position slop into a named world/step configuration and test values in world units. Do not leave a hidden `0.01` literal in `CFPhysicsSoftStepSolver`.

Avoid solving this by changing `continuedContacts` expectations to empty. Persistent resting contact is part of the declared lifecycle contract and is needed for stable UI stacking and warm-start behaviour.

### C. Hard-coded recovery slop is an unfinished design decision

**Status:** known design debt, intentionally not fixed in this handover.

The source currently contains:

```smalltalk
CFPhysicsSoftStepSolver >> contactPositionSlop [ ^ 0.01 ]
```

This is not a test-only approximation. It changes physical position recovery. `closeTo:` is appropriate for comparing floating-point values in tests; it cannot substitute for a solver tolerance.

The concern is valid: `0.01` means world units, not inherently pixels. It may be a reasonable default for the current UI coordinate scale, but it is not appropriately scoped or documented as an engine-wide default. It can also be implicated in the contact persistence failures above.

**Required design before implementation**

1. Decide whether the tolerance belongs to `CFPhysicsWorld` configuration, `CFPhysicsStep`, or a dedicated contact/solver configuration object.
2. Give it a descriptive name and documented unit/meaning (for example, maximum tolerated penetration or recovery slop in world units).
3. Provide an explicit default rather than a magic method-local literal.
4. Ensure a zero-time CCD recovery step receives the same policy as a normal step.
5. Add examples for zero, default, and larger values, including expected contact lifecycle behaviour.

Do not choose the final default merely to make the current tests pass.

### D. CCD integration is now structurally safer, but requires regression expansion

**Status:** recent correction; core causal defect verified, broader behaviour still needs coverage.

Before commit `45a029a`, any continuous impact could suppress ordinary discrete constraints and skip the ordinary island solver. That was a proven cause for unrelated overlaps not recovering during a CCD frame.

The correction merges impact and ordinary contacts after recapturing post-impact state, then runs a zero-time recovery solve. The new regression `continuousImpactDoesNotSuppressSeparateOverlapRecovery` verifies the intended result: one moving body hits a wall continuously while another starts overlapped with an obstacle; both contacts should remain active and the separate overlap should recover.

The current test allows recovery to just under `-10` (`< -9.9`) because of the `0.01` slop. That ties this regression to Issue C and means it should be revisited when the tolerance design is made explicit.

**Follow-up research needed**

- simultaneous/near-simultaneous impacts;
- an existing resting contact plus a separate CCD impact;
- sensor crossings in the same frame as solid impacts;
- contacts that begin overlapped at the final CCD state;
- determinism of contact ordering and warm-start data across repeated runs;
- whether the zero-time recovery solve has any unintended impact on restitution or joints.

Box2D is a useful behavioural reference for persistence, speculative contacts, substeps, and bounded position correction, but not an API/template to copy. The Bloc UI coordinate model and inspectability requirements remain the governing design constraints.

### E. Click Me overlap still needs end-to-end validation

**Status:** visual evidence drove fixes; not yet a proof of sustained correctness.

The earlier overlay screenshots showed buttons visibly overlapping while their physics outlines disagreed, then showed many bodies settling into overlaps. Two confirmed sources were presentation angle units and unrotated containment bounds. The global CCD suppression defect also plausibly amplified overlap periods.

The remaining question is whether genuine rotated-button contacts and recovery are stable under the show-case's density of bodies, light gravity, restitution, and UI event activity. The current tests are useful but too small to certify that.

**Recommended diagnostic example, before a production fix**

Create an inspectable, deterministic replay variant of Click Me with:

- a seeded random generator;
- a fixed number of buttons;
- fixed start transforms and velocities recorded as data;
- selectable collision overlay;
- per-step contact count, pair count, and maximum penetration display;
- a highlighted button/pair that lets GT inspect its step result, manifold, AABB, and constraint;
- no changes to production collision logic.

Use it to capture a concrete failed pair and compare its visual transform, body transform, AABB, broadphase pair membership, manifold, and solver result over consecutive frames. That converts “some buttons stop colliding” from a visual impression into one traceable pipeline path.

## 8. Test and research workflow

The project is validated primarily by GT executable examples. A green example is valuable only if it checks a stable contract; a failing example is valuable only if its setup matches production semantics.

For each unresolved issue:

1. Keep the existing failing example unchanged as the symptom record.
2. Add one narrowly scoped probe/example that distinguishes competing causes.
3. Inspect pipeline stage outputs in GT before writing a change.
4. State the expected contract in the regression name and assertions.
5. Make the smallest production change that addresses the confirmed cause.
6. Run the relevant focused examples, then the full suite.
7. Re-run Click Me with the collision overlay and inspect the specific original failure mode.
8. Remove temporary logging/instrumentation; retain the useful example/probe.

Tests involving Bloc input must use the same semantic path as real input where possible. Constructing `BlDragStartEvent`/`BlDragEvent` objects is insufficient if their target/gesture/dispatch context differs from `BlMouseProcessor` production dispatch.

## 9. Suggested order of next work

1. **Resolve the synthetic drag test causally.** It blocks a core UI interaction and has a narrow, inspectable path.
2. **Trace why the resting contact disappears on step two.** Use stage outputs to decide pair-finder versus manifold versus updater; do not alter expectations first.
3. **Design and implement explicit contact/recovery tolerance configuration.** Do this only once the seam trace establishes the desired persistence behaviour.
4. **Expand CCD/contact coexistence regressions.** Verify that normal contacts, sensors, overlap recovery, and CCD remain simultaneously active and deterministic.
5. **Build the deterministic Click Me diagnostic replay.** Validate real rotated UI geometry at density before declaring the first showcase production-ready.
6. **Finish the showcase track.** Discuss each subsequent example with the user first, ensuring it demonstrates a compelling UI feature combination rather than a generic game mechanic.

Potential future showcase concepts, pending discussion and prioritisation:

- Bounded Drawer — containment, drag, resting contacts, pointer release velocity.
- Hinged Inspector — revolute joint, limits, motor, UI panel affordance.
- Connected Canvas — distance/fixed/rail relationships in a real workspace metaphor.
- Collision Workspace — collision events, material response, debug/inspection overlays.
- Fast Sensor Gate — sensor lifecycle and CCD in a UI-relevant interaction.
- Motion Composition Lab — explicit simulation/presentation composition and interpolation.

## 10. Repository and workspace state

- Foundation head at this handover: `5dac32888d42aea33be83c37bed953e919bff488`.
- The workspace superproject currently sees Foundation and Runtime submodule pointers ahead of its recorded revisions. Do not update a submodule pointer merely as part of diagnosis; commit within the changed submodule first, then intentionally update the workspace pointer when the work is ready.
- Dependencies under `deps/` are inspect-only unless explicitly authorised for change.
- No Catalyst Runtime change is required for the issues in this document.

## 11. Source guide

| Topic | Primary source |
| --- | --- |
| Showcase | `src/BVC-Foundation-Physics-Examples/CFPhysicsShowcaseExamples.class.st` |
| Current regressions | `src/BVC-Foundation-Physics-Tests/CFPhysicsCleanSlateTests.class.st` |
| World handoff | `src/BVC-Foundation-Physics-Core/CFPhysicsWorld.class.st` |
| Pointer interaction | `src/BVC-Foundation-Physics-Core/CFPhysicsPointerDragHandler.class.st` |
| Contact lifecycle | `src/BVC-Foundation-Physics-Pipeline/CFPhysicsContactUpdater.class.st` |
| Pipeline orchestration | `src/BVC-Foundation-Physics-Pipeline/CFPhysicsStepPipeline.class.st` |
| CCD integration | `src/BVC-Foundation-Physics-Pipeline/CFPhysicsContinuousStepStage.class.st` |
| Unified contacts | `src/BVC-Foundation-Physics-Pipeline/CFPhysicsContactUpdateStage.class.st` |
| Contact recovery | `src/BVC-Foundation-Physics-Pipeline/CFPhysicsSoftStepSolver.class.st` |
| EPA/rectangle manifold separation | `src/BVC-Foundation-Physics-Collision/CFPhysicsEPA.class.st`, `CFPhysicsRectangleCollision.class.st` |
| Bloc drag dispatch reference | `deps/Bloc/src/Bloc/BlMouseProcessor.class.st` |

## 12. Guardrails for the next contributor

- Do not treat a visual symptom as a collision diagnosis. Trace the actual pair, manifold, constraint, and solver state.
- Do not replace production semantics with test tolerance (`closeTo:`) or weaken a lifecycle expectation to hide a regression.
- Do not leave numeric solver policy hidden in a private method once it becomes user-observable.
- Do not reintroduce a global CCD branch that prevents unrelated ordinary contacts from being updated or solved.
- Keep everything deterministic and inspectable.
- Prefer focused reversible probes over broad logs or speculative rewrites.
- Keep the engine oriented toward Bloc/GT UI behaviour; ask before prioritising game-specific mechanics.

