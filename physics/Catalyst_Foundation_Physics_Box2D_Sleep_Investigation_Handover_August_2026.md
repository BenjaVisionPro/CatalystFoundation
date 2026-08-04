# Catalyst Foundation Physics — Box2D Sleep Investigation Handover (August 2026)

## Purpose

This is the continuation handover for the Box2D 3.1.1 Soft Step alignment work in Catalyst Foundation.

The governing rule remains:

> When Foundation and Box2D differ in core simulation behaviour, use the Box2D 3.1.1 source as the reference. Deviate only at an explicit Bloc/GT integration boundary, and document the reason.

The practical goal has not changed: stable resting bodies must settle and sleep naturally. The remaining unresolved question is:

> What is adding velocity to bodies that should be at rest, and therefore continually resetting their sleep time?

This is now a causal-debugging task, not a request for more broad parity changes.

## Repository and reference

- Workspace: `/opt/git/BenjaVisionPro/gt-runtime-workspace`
- Main project: `/opt/git/BenjaVisionPro/gt-runtime-workspace/CatalystFoundation`
- Box2D reference clone: `/private/tmp/box2d-3.1.1`
- Important Box2D sources:
  - `src/solver.c`
  - `src/contact_solver.c`
  - `src/joint.c` and individual `*_joint.c` files
  - `src/distance.c`
  - `src/broad_phase.c`

Do not use Graphify for this work. It was explicitly rejected because it relies on stale documentation rather than the live source and running GT image.

## Current state

The physics pipeline and much of the contact/joint model are now intentionally close to Box2D Soft Step:

1. velocity integration
2. persistent broadphase pair discovery
3. contact update
4. constraint preparation
5. island building/waking
6. biased solve
7. position integration
8. unbiased relaxation solve
9. continuous collision handling
10. island sleep decision
11. contact events

The engine has mature contact and sleep telemetry, including persistent/began/continued/ended contacts, manifold and point reuse, solver penetration/impulse metrics, and velocity-versus-correction sleep rejection ratios.

Despite this, resting objects still fail to settle and sleep. No source-level cause has yet been proven.

## Confirmed work in this chat

All items below were loaded and reported green by the user unless marked **pending validation**.

### Contact and solver alignment

- Contact persistence and stored-anchor separation reconstruction were retained as the core Soft Step model.
- Persistent manifold points now retain Box2D-style `totalNormalImpulse` and `normalVelocity` state through contact writeback.
- The prismatic perpendicular and angular constraints were changed from independent solves to Box2D's coupled 2×2 block solve.
- Motor, prismatic, and weld angular error now use shortest-arc/unwound angle handling in their constraint solve. Persistent presentation rotations remain unwrapped deliberately; only the constraint error is wrapped.

### Distance joints

- Distance joints now expose and solve Box2D 3.1.1 minimum/maximum lengths and the axial motor.
- Constraint writeback no longer sends a nil limit impulse through `asFloat`.
- Infinite maximum length is rendered as `Unlimited` in the inspector rather than attempting to format infinity as a fraction.

### Motor joints

- `CFPhysicsMotorJoint` was audited against Box2D.
- Its existing world-space `linearOffset` behaviour is intentionally retained: although the public Box2D comment describes a body-A frame, Box2D 3.1.1's prepare code subtracts the stored vector directly. Foundation matches that actual source path.

### Filter joints

- Added `CFPhysicsFilterJoint`, modelled on Box2D's collision-only filter joint.
- It initially disables collision, produces no prepared solver constraint/impulse, but remains a persistent island-graph edge exactly as Box2D does.
- Added world and element lifecycle support, body retirement support, inspector/overlay support, and examples covering collision filtering, no solver constraint, and island linkage.
- Found and fixed an adjacent lifecycle omission: retiring a body had not removed its motor joints.

### Broadphase collision-policy transition

- A filter-joint example exposed a real broadphase discrepancy: after `collideConnected` changed from false to true, stationary overlapping bodies did not form a pair.
- Cause: Foundation woke the bodies but did not buffer a broadphase proxy; Box2D `b2Joint_SetCollideConnected` explicitly buffers a connected shape proxy when enabling collision.
- Fixed by adding a proxy-touch path from `CFPhysicsJoint>>collideConnected:` through `CFPhysicsWorld`, `CFPhysicsStepPipeline`, and `CFPhysicsBroadphase`.
- The user loaded this fix and reported all green.

### Continuous collision and sensors

- The continuous stage runs after the soft solve and uses swept solved transforms.
- Fast-body policy was checked against Box2D: ordinary fast dynamics test statics; bullets also test kinematic/dynamic bodies but skip other bullets.
- Swept sensor contacts are intentionally a Catalyst event contract, not Box2D solver contacts. Preserve this distinction unless the user explicitly changes the integration contract.

### Motion integration guard

- A screenshot showed `A Physics Motion Behaviour cannot move backwards in time`.
- Cause: a wall-clock regression produced a negative frame elapsed time.
- Added a frame-driver guard that clamps negative elapsed time to zero, with a focused motion test.

### Mouse-joint defaults — pending validation

The current worktree contains an unvalidated, focused patch that changes base `CFPhysicsMouseJoint` defaults to Box2D 3.1.1 values:

| Property | Previous Foundation | Box2D 3.1.1 / pending Foundation |
| --- | ---: | ---: |
| Hertz | 5.0 | 4.0 |
| Damping ratio | 0.7 | 1.0 |
| Maximum force | 1000.0 | 1.0 |
| `collideConnected` | true | false |

The Bloc pull handler is unaffected: it explicitly applies its own UI values (`30 Hz`, damping `1.0`, and force derived from body mass). The pending example is `CFPhysicsCleanSlateTests>>mouseJointDefaultsMatchBox2D`.

Before starting other work, load this small patch and run the affected example/tests. Do not claim it is green yet.

## What has not been solved

The central failure is still unresolved: some bodies that should be resting keep exceeding their sleep threshold, so their sleep time repeatedly resets.

The existing sleep decision is source-shaped and not obviously the defect:

- `CFPhysicsBodyStepState>>sleepVelocityForElapsed:positionCorrectionFactor:` computes the farthest-point velocity and combines it with the position-correction velocity.
- The calculation uses the Box2D-shaped terms:
  - linear speed plus angular speed × bounding radius;
  - position delta plus `abs(sin(deltaRotation))` × bounding radius;
  - correction factor `0.5`.
- `CFPhysicsIslandSleepStage` resets sleep time only when that measured velocity exceeds the body threshold or sleeping is disabled.

Do not loosen thresholds, increase time-to-sleep, damp velocities aggressively, or suppress sleeping telemetry as a workaround. First identify the stage and constraint that introduces the velocity.

## Most likely causes, in priority order

These are hypotheses, not findings.

1. A contact solver phase adds non-convergent velocity.
   - Compare the same body's velocity after warm start, after biased contact solve, after position integration, and after relaxation.
   - Split normal, tangent, rolling, and restitution contributions.

2. A persistent contact's accumulated impulse is reused incorrectly.
   - Inspect `normalImpulse`, `tangentImpulse`, `rollingImpulse`, `totalNormalImpulse`, restitution state, feature identity, and point ordering across consecutive resting frames.
   - A stable manifold with a changing warm-start impulse is more suspicious than a manifold replacement.

3. Contact preparation reconstructs a valid separation but prepares an incorrect effective mass, anchor, or softness coefficient.
   - Compare one concrete resting contact, field-for-field, against `b2PrepareOverflowContacts` / `b2PrepareContacts` and `contact_solver.c`.

4. A non-contact constraint contributes velocity to the resting island.
   - The new filter joint is explicitly not a solver constraint, but distance, mouse, motor, revolute, weld, prismatic, and wheel constraints remain potential sources.
   - Run the minimal resting case with no joints first; then add constraints one at a time.

5. The sleep measurement is observing an expected correction that should have been removed by relaxation.
   - This would be a solver/phase-order issue, not a reason to change the sleep rule.

6. Continuous collision or a GT behaviour is repeatedly waking a body.
   - Establish this only after the minimal no-CCD, no-Behaviour stack has been measured.

## Required next investigation

### 1. Establish one deterministic minimal reproducer

Create a focused GT example with:

- a static floor;
- one dynamic rectangle (then a two-box stack);
- gravity `0 @ 9.81` in the desired world units;
- no behaviours, mouse joints, motor joints, CCD bullets, or external input;
- fixed step duration and fixed substep count;
- telemetry enabled.

The example must run enough steps to show whether sleep time grows to `0.5` seconds or resets. It should answer one question: which body first exceeds its sleep threshold, and on which step?

### 2. Add temporary, structured per-body stage deltas

Do not use Transcript logging. Add a small diagnostic object or test-only capture to `CFPhysicsSoftStepSolver` / `CFPhysicsStepPipelineResult` that records, for a selected body sequence:

| Boundary | Required values |
| --- | --- |
| captured | linear velocity, angular velocity, delta position, delta rotation |
| after velocity integration | same |
| after warm start | same, plus impulse source totals |
| after biased solve | same |
| after position integration | same |
| after relaxation | same |
| after CCD | same |
| before sleep decision | computed sleep velocity, motion term, correction term, threshold, sleep time |

For each solver boundary, retain signed velocity delta and source labels. A useful first split is:

- gravity/force integration;
- contact normal;
- contact friction/tangent;
- rolling resistance;
- restitution;
- each joint type.

The output should be inspectable in GT and removable once the cause is proven.

### 3. Compare a single frame against Box2D source

Once the first non-zero stage delta is found, stop broad auditing. Compare only that path against the exact Box2D 3.1.1 code:

- contact normal/tangent/rolling/restitution: `src/contact_solver.c`;
- Soft Step ordering and sleep measurement: `src/solver.c`;
- joint contribution: its individual `src/*_joint.c` file.

Record the exact divergence: inputs, formula/order difference, and resulting impulse. Then implement one focused parity patch and add a regression example that verifies eventual sleep.

### 4. Use the existing telemetry to triage before modifying solver code

For a failing frame, capture:

- `worstSleepBodySequence`;
- `worstSleepReason`;
- `worstSleepMotionBodySequence` and ratio;
- `worstSleepCorrectionBodySequence` and ratio;
- `worstSleepLinearSpeed`, `worstSleepAngularSpeed`;
- `worstSleepMaximumVelocity`, `worstSleepCorrectionVelocity`;
- `worstSleepNormalImpulse`, `worstSleepTangentImpulse`;
- persistent/began/continued/ended contact counts;
- stable/changed manifold and reused/new point counts;
- initial/final penetration and maximum body translation.

Interpretation:

- high **motion** ratio with low correction ratio: find the velocity-producing solver stage;
- high **correction** ratio with low motion ratio: find the non-converging positional correction/relaxation path;
- changed manifolds or new points at rest: investigate broadphase/manifold identity before impulse math;
- stable manifolds but changing velocity: investigate warm starting and the contact solver directly.

## Guardrails for the next chat

- Do not tune sleep thresholds as a substitute for fixing velocity generation.
- Do not make bulk Box2D API additions unless they directly help isolate the sleep failure.
- Keep Box2D 3.1.1 source open beside the Foundation method being changed.
- Treat Bloc/GT behaviour as an explicit integration boundary, not an accidental source of solver differences.
- Use GT live inspection for failures shown in screenshots; do not infer object state solely from image text when a live query is available.
- Preserve existing user changes and do not reset/revert the worktree.
- Run `git diff --check` before handing a patch back. The user runs the image examples/tests and reports the result.

## Definition of success

This effort is complete only when the deterministic resting examples show:

- velocity and correction terms falling below the Box2D-equivalent sleep threshold;
- sleep time accumulating without unexplained resets;
- the island sleeping after the configured `0.5` seconds;
- stable contact/manifold identity while resting;
- a source-level explanation and regression test for the formerly velocity-producing path.
