# Extending Catalyst Foundation Motion

A Motion Behaviour owns presentation or long-running dynamic work. It does not own a clock, schedule Bloc tasks, or advance itself.

## Subclassing

Create a subclass of `CFMotionBehaviour` and implement the smallest applicable protocol:

- `evaluate:` applies one immutable `CFMotionEvaluation`.
- `propertyKey` identifies an exclusively owned presentation property, or answers `nil` for non-exclusive procedural work.
- `animationTarget` answers the target whose attachment determines playback validity, or `nil` for targetless work.
- `captureOriginIn:`, `prepareFromCurrentPresentation`, `restoreOrigin`, `preserveCurrentPresentation`, and `applyDestination` implement reversible presentation where applicable.
- `playbackStartedIn:` and `playbackEndedWith:` delimit one whole playback lifetime. Pause and resume do not repeat these callbacks.

## Evaluation

Use `timelineTime` for coordination across Behaviours and `localTime` for time relative to the Behaviour's temporal placement. Finite evaluations provide progress; indefinite evaluations do not. Test `hasProgress` before reading progress-dependent presentation.

## Scheduling

Never read a clock or enqueue a task from a Behaviour. `CFMotionCoordinator` supplies one shared `CFMotionFrame` per Bloc presentation frame and the timeline derives every evaluation from it.

## Transform presentation

Transform Behaviours contribute through the coordinator's `CFMotionTransformChannel`. Do not replace an element's transformation directly while participating in composed Motion presentation.

## Cleanup

Release external resources in `playbackEndedWith:`. The terminal callback is delivered exactly once for completion, settlement, stop, cancellation, or invalid target attachment.
