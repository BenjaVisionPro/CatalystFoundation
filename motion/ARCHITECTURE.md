# Catalyst Foundation Motion Architecture

## Purpose

Catalyst Foundation Motion is the temporal-composition and playback framework for Bloc presentation and long-running dynamic work.

A Motion is not a Bloc animation wrapper. It is a playable composition advanced by the presentation cadence of one `BlSpace`. The framework separates scheduling, playback lifecycle, temporal composition, temporal placement and evaluated work so each concern has one owner.

Motion supports:

- finite interpolation;
- overlapping and sequenced tracks;
- indefinite procedural Behaviours;
- multiple Motions sharing one presentation frame;
- deterministic presentation-property ownership and retargeting;
- transform composition across independent Motions;
- pause, resume, stop and explicit cancellation policies;
- integration with dynamic runtimes such as Physics.

Motion does not define simulation policy, solver policy or domain-specific effects. Those belong in Behaviours supplied by the integrating package.

## Architectural model

```text
BlSpace
    CFMotionCoordinator
        CFMotionFrameDriver
            CFMotionFrame
            active CFMotions

CFMotion
    CFMotionTimeline
        CFMotionTimelineTracks
            CFMotionBehaviours
                presentation or dynamic work
```

The runtime flow is:

```text
Bloc pulse
    -> CFMotionFrameDriver samples BlSpace time once
    -> one immutable CFMotionFrame is created
    -> CFMotionCoordinator advances active Motions in registration order
    -> each CFMotion advances its Timeline
    -> the Timeline advances its playhead
    -> each active TimelineTrack creates a CFMotionEvaluation
    -> the Track sends the Evaluation to its Behaviour
```

Every object has one primary responsibility.

| Object | Responsibility |
| --- | --- |
| `CFMotionFrameDriver` | Converts Bloc pulses into shared Motion frames. |
| `CFMotionFrame` | Describes one immutable presentation-time sample. |
| `CFMotionCoordinator` | Coordinates Motions within one `BlSpace`. |
| `CFMotion` | Owns one playback lifecycle. |
| `CFMotionTimeline` | Owns temporal composition and playback position. |
| `CFMotionTimelineTrack` | Places one Behaviour in timeline time. |
| `CFMotionEvaluation` | Describes one immutable Behaviour evaluation. |
| `CFMotionBehaviour` | Performs presentation or dynamic work. |
| `CFMotionTransformChannel` | Composes transform contributions for one element. |
| `CFMotionTransformPresentation` | Owns one Behaviour's transform contribution. |

## Space-scoped coordination

Each `BlSpace` has one `CFMotionCoordinator` and one reusable `CFMotionFrameDriver`.

The coordinator owns:

- the stable registration order of active Motions;
- the single frame driver;
- presentation-property ownership;
- transform-channel identity;
- Motion playback history.

The coordinator does not:

- interpret timelines;
- own playback positions;
- interpolate values;
- perform presentation work;
- define simulation steps.

Stable registration order is the deterministic ordering contract for Motions advanced in the same Bloc frame.

## Shared frame cadence

`CFMotionFrameDriver` is the sole Bloc task that advances Motion in a space.

On each execution it:

1. synchronises on the `BlSpace` clock;
2. samples the current absolute time once;
3. computes elapsed presentation time from the previous active frame;
4. creates one `CFMotionFrame`;
5. gives that same frame instance to every active Motion.

The first frame after activation has zero elapsed time. When the last Motion stops, the driver deactivates and clears its baseline. Time spent while no Motion is active is therefore never delivered as a later elapsed interval.

This gives Motion these guarantees:

- all Motions in one Bloc frame observe the same timestamp;
- all Motions in one Bloc frame observe the same elapsed duration;
- a newly activated run begins from a real zero-time frame;
- Motion never reads a clock independently;
- Motion never invents a presentation frame.

`CFMotionFrame` contains only:

- `absoluteTime`;
- `elapsedTime`;
- `frameId`.

It deliberately contains no easing, playback, interpolation or simulation policy.

## Motion lifecycle

`CFMotion` owns one playback lifecycle. Its states are represented by `CFMotionState`.

The principal lifecycle is:

```text
idle -> running -> paused -> running -> terminal
```

A terminal Motion does not restart. Starting another playback creates another Motion.

### Starting

Starting a Motion:

1. validates its tracks and Behaviours;
2. prepares the Timeline for playback;
3. captures presentation origins;
4. claims exclusive presentation properties where applicable;
5. sends `playbackStartedIn:` once to each Behaviour;
6. registers the Motion with the coordinator.

Starting registers playback. Evaluation still begins on the next coordinator frame, whose elapsed time is zero.

### Pause and resume

Pause removes the Motion from active frame advancement without ending the Behaviour lifetime. Resume registers the same Motion again.

Paused wall-clock time is excluded because the frame driver resets its elapsed baseline whenever no Motion remains active. When other Motions remain active, the paused Motion still receives no frames and therefore accumulates no playback time.

Pause and resume do not resend `playbackStartedIn:`.

### Stop and cancellation

`stop` is the canonical ordinary termination message. It preserves the current presentation.

Explicit alternatives define other presentation policies:

- `cancelAndRestore` restores captured origins;
- `cancelSettlingAtEnd` applies destinations;
- `cancelPreservingCurrentPresentation` preserves the current presentation.

Terminal processing:

1. removes the Motion from active advancement;
2. applies the selected presentation policy;
3. records the terminal state;
4. sends `playbackEndedWith:` exactly once;
5. releases property claims;
6. notifies terminal handlers.

A naturally completed finite Motion applies its destination unless configured to hold its current destination ownership.

## Timeline ownership of time

A `CFMotionTimeline` is the sole owner of playback position for a timeline-backed Motion.

It owns:

- the ordered tracks;
- temporal anchors;
- resolved timeline end;
- elapsed playback time;
- finite or indefinite status;
- completion and progress reporting.

It does not own:

- scheduling;
- Motion lifecycle;
- presentation-property claims;
- presentation logic.

Before playback, the Timeline resolves temporal layout. During playback it advances its playhead by the elapsed duration supplied by the Motion and evaluates all tracks at the resulting absolute timeline position.

### Finite timelines

A finite Timeline:

- has a resolved duration;
- clamps its playhead at the resolved end;
- reports normalised progress;
- completes automatically.

### Indefinite timelines

A Timeline is indefinite when any track is indefinite.

An indefinite Timeline:

- has no duration;
- has no normalised progress;
- has no timeline-end anchor;
- does not complete automatically;
- continues until the owning Motion is stopped or cancelled.

Finite tracks and indefinite tracks may coexist. A finite Behaviour can establish an initial phase while an indefinite Behaviour continues afterward.

## Tracks place Behaviours in time

`CFMotionTimelineTrack` owns temporal placement, not presentation.

A track owns:

- start and end anchors;
- offsets;
- finite duration or indefinite lifetime;
- easing;
- resolved start and end times;
- repeated temporal placement where configured.

At each timeline position, the track decides whether its Behaviour is active. When active, it creates a `CFMotionEvaluation`.

For a finite track, the Evaluation contains:

- absolute timeline time;
- local track time, clamped to the track duration;
- eased normalised progress.

For an indefinite track, the Evaluation contains:

- absolute timeline time;
- unbounded local track time;
- no progress value.

The track forwards to its Behaviour:

- validation;
- origin capture;
- presentation ownership identity;
- playback-started and playback-ended lifecycle;
- destination, restoration and preservation actions.

The track never reads a clock or owns a playhead.

## Behaviours perform evaluated work

`CFMotionBehaviour` is the framework extension point.

A Behaviour may:

- interpolate a presentation property;
- compose a transform contribution;
- calculate a procedural value;
- advance a spring or oscillator;
- drive a state machine;
- adapt Motion time to another runtime such as Physics.

A Behaviour does not own:

- temporal placement;
- timeline position;
- frame scheduling;
- Motion lifecycle state.

### Evaluation contract

A Behaviour receives immutable `CFMotionEvaluation` objects. It must treat the Evaluation as descriptive input and must not alter Motion time.

Finite Behaviours normally implement progress-based presentation. Indefinite or procedural Behaviours should override `evaluate:` and consume `localTime` and `timelineTime` directly.

### Playback lifecycle contract

`playbackStartedIn:` and `playbackEndedWith:` delimit one whole playback.

The framework guarantees:

- `playbackStartedIn:` is delivered once;
- pause and resume occur within the same lifetime;
- `playbackEndedWith:` is delivered once;
- the terminal callback receives the final `CFMotionState`.

A Behaviour should initialise per-playback resources in `playbackStartedIn:` and release or clear them in `playbackEndedWith:`.

### Presentation ownership

A Behaviour may return a `CFMotionPropertyKey` from `propertyKey` when it requires exclusive ownership of one presentation property.

A Behaviour returns `nil` when:

- it does not exclusively present one property;
- it controls a dynamic system;
- it coordinates several targets;
- ownership belongs to another mechanism.

Targetless Behaviours are valid by default. A target-backed Behaviour supplies `animationTarget`; Motion validates that the target remains attached to the coordinator's `BlSpace` before advancement. Detachment or movement to another space cancels the Motion and performs normal cleanup.

## Presentation-property ownership and retargeting

The coordinator maps each `CFMotionPropertyKey` to one owning Motion.

This prevents two independent Motions from simultaneously owning the same exclusive presentation property in one space.

Retargeting follows these rules:

- when the property already has an owner, that same Motion is retargeted;
- Motion identity and lifecycle are preserved;
- the current presentation becomes the new interpolation origin;
- registration history is not duplicated;
- when the property is unowned, the coordinator creates and starts a new Motion.

Property ownership is distinct from transform composition. Translation, scale and rotation can contribute through a shared transform channel while preserving deterministic composition.

## Transform composition

Directly replacing an element's transformation from multiple Motions would cause each Motion to overwrite the others. Motion therefore uses one `CFMotionTransformChannel` per element.

The channel:

- captures the element's pre-Motion transformation;
- holds active transform presentations in registration order;
- composes all contributions over the captured base transformation;
- restores the base transformation when the final contribution releases;
- removes itself from the coordinator when empty.

A `CFMotionTransformPresentation` owns one mutable contribution containing:

- translation;
- scale;
- rotation;
- transform origin.

The presentation never replaces the element transformation directly. It registers with the channel and asks the channel to apply the complete composition.

If application code externally replaces the transformation, the channel abandons ownership rather than overwriting that external change.

## Determinism contract

Motion determinism is defined for the same sequence of Bloc frames and playback commands.

The runtime guarantees:

- one clock sample per space frame;
- one shared immutable frame object;
- stable active-Motion registration order;
- stable Timeline track order;
- deterministic transform contribution order;
- no hidden clocks or independently scheduled animations;
- no elapsed-time contribution while a Motion is paused;
- zero elapsed time on the first frame after frame-driver activation;
- exactly-once Behaviour lifecycle termination.

A Behaviour is responsible for preserving determinism in its own evaluated work. It must not read unrelated wall-clock time, depend on unordered collection traversal or schedule independent animation work.

## Physics integration

Physics integrates through `CFPhysicsWorldBehaviour`, an indefinite targetless-property Behaviour.

The Behaviour adapts variable presentation-frame elapsed time to the world's fixed simulation step:

```text
Motion frame elapsed time
    -> accumulate elapsed duration
    -> while accumulator >= world stepDuration
           world step
           subtract stepDuration
    -> retain remainder for the next frame
```

Important contracts:

- the initial zero-time frame performs no Physics step;
- a long presentation frame may perform several fixed steps;
- a partial remainder carries into the next frame;
- pause and resume preserve the same playback lifetime;
- terminal playback clears the remainder;
- a later playback starts from a clean fixed-step boundary;
- Motion does not know Physics exists;
- Physics owns simulation state and fixed-step configuration.

`CFPhysicsWorld` offers world-level stepping lifecycle messages as a convenience, but `world step` remains the deterministic simulation primitive.

## Extension guidance

### Adding a finite presentation Behaviour

Create a `CFMotionBehaviour` subclass that:

1. identifies its target and property key;
2. captures its origin;
3. implements progress-based evaluation;
4. implements destination, restoration and preservation policies;
5. validates required configuration;
6. implements reversal where meaningful.

Do not schedule a Bloc animation or read a clock.

### Adding an indefinite procedural Behaviour

Create a `CFMotionBehaviour` subclass that:

1. returns no exclusive property key unless one is genuinely required;
2. overrides `evaluate:`;
3. uses `localTime` as its playback-relative time;
4. initialises state in `playbackStartedIn:`;
5. clears playback-specific state in `playbackEndedWith:`;
6. remains deterministic for the same Evaluation sequence.

### Adapting another runtime

Follow the Physics pattern:

1. keep the other runtime's state and policies in that runtime;
2. use a Behaviour only as the temporal adapter;
3. convert Motion elapsed time into the runtime's own advancement units;
4. avoid presentation-property claims when the runtime controls several outputs;
5. use `animationTarget` only when attachment to one `BlSpace` defines validity.

Motion must remain unaware of the integrating package.

## Failure rules

The framework fails early when architectural contracts are violated.

Examples include:

- a finite track without resolvable temporal placement;
- a non-positive finite duration;
- use of the timeline-end anchor in an indefinite Timeline;
- two Motions claiming the same property;
- retargeting a property the Motion does not own;
- a target-backed Behaviour leaving the coordinator's space;
- a Behaviour evaluating outside its playback lifetime;
- a dynamic adapter moving backward in local time;
- an invalid frame-driver task state.

These are programming errors, not runtime recovery cases.

## Public entry points

Most clients should work through builders, timelines and world-level convenience APIs rather than manipulating coordinators or frame drivers.

The principal playback messages are:

```smalltalk
motion start.
motion pause.
motion resume.
motion stop.
```

Use explicit cancellation variants only when their presentation policy is required.

Timeline clients compose tracks and Behaviours, then create one Motion against the target `BlSpace` coordinator. `BlElement` and `BlSpace` extensions provide the normal framework entry points.

`CFMotionCoordinator`, `CFMotionFrameDriver`, transform channels and ownership maps are runtime infrastructure, not application-level scheduling APIs.

## Architectural boundaries

The following boundaries are intentional and must remain stable:

- Bloc owns presentation pulses.
- The coordinator owns space-scoped scheduling and ownership.
- Motion owns playback lifecycle.
- Timeline owns playback position and temporal composition.
- TimelineTrack owns temporal placement.
- Behaviour owns evaluated work.
- Presentation classes own presentation-specific state.
- Integrating packages own their domain state and policy.

A proposed change that moves one of these responsibilities across a boundary should be treated as an architectural change, not a local convenience refactor.

## Package boundaries

The framework is divided deliberately:

- `BVC-Foundation-Motion-Core` contains the runtime, reusable Behaviours, Bloc integration and architectural documentation.
- `BVC-Foundation-Motion-Tests` contains `TestCase` subclasses. Every test is also tagged with `<gtExample>` so the same contracts run through SUnit and the GT example runner.
- `BVC-Foundation-Motion-Examples` contains user-facing, inspectable demonstrations of useful Motion setups. It does not carry framework contract assertions.

There is no separate Effects package. Reusable behaviour belongs in Core; application-specific compositions belong with their application or in Examples.
