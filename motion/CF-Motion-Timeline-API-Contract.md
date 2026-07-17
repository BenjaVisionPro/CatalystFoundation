# Motion timeline API contract

This is the public contract for composable Motion. It is the source of truth for
the timeline work; source implementation must not introduce additional public
synonyms without first updating and agreeing this contract.

## Entry point and result

`BlElement>>motion` is the Motion entry point.

```smalltalk
motion := element motion play: [ :timeline |
	"declare tracks and their temporal layout"
].
```

`play:` is the only general-purpose way to start a composed motion. It returns
one running `CFMotion`. A caller never receives a builder, a layout
transaction, an adoption operation, or a timer.

`CFMotion` owns lifecycle: state, trace, cancellation, completion, and later
retargeting.

## Simple motions

Named simple motions stay available for standard, zero-configuration
intentions:

```smalltalk
element motion fadeIn.
element motion fadeOut.
element motion riseAndFadeIn.
element motion fallAndFadeOut.
element motion scaleAndFadeIn.
element motion scaleAndFadeOut.
```

Each returns a running `CFMotion`. A simple motion is implemented as a preset
timeline containing its named track; it is not a separate execution model.

## Tracks and temporal layout

A timeline contains tracks. Creating a track declares its visual, layout, or
structural intent. Timing is then expressed through the track's temporal
layout. A track is a real part of the timeline, not a partially configured
builder.

```smalltalk
(timeline fadeTo: 1)
	duration: 700 milliseconds.

(timeline followPath: path)
	duration: 1 second.
```

The generic temporal layout protocol is deliberately small and symmetric:

```smalltalk
track
	duration: aDuration;
	startsAt: anAnchor;
	starts: aDuration before: anAnchor;
	starts: aDuration after: anAnchor;
	endsAt: anAnchor;
	ends: aDuration before: anAnchor;
	ends: aDuration after: anAnchor;
	repeatsEvery: anInterval;
	startsOn: anEventClass from: anElement;
	endsOn: anEventClass from: anElement.
```

The selectors name the actual domain concepts:

- `duration:` is the duration of one track occurrence.
- `starts...` and `ends...` place a track relative to a temporal anchor.
- `repeatsEvery:` is the interval between occurrences.
- `startsOn:from:` and `endsOn:from:` make Bloc events temporal anchors.

There are no public `delay:`, `at:`, `during:`, `over:`, `stopsAt:`,
`parallel:`, or nested timeline objects.

## Temporal anchors

The available anchors are:

```smalltalk
timeline start.
timeline end.
track start.
track end.
```

`timeline end` is derived from the finite temporal layout: it is the latest
end of a finite, placed track. The timeline itself has no user-set duration.
Tracks whose final end is placed relative to `timeline end` do not establish
that end. A temporal layout without an end-defining finite track is rejected
when it needs `timeline end`.

Event-started or indefinite tracks do not contribute to the derived end. They
leave the returned `CFMotion` armed until their event arrives, an end event
arrives, or the motion is cancelled.

## Composition example

```smalltalk
motion := element motion play: [ :timeline |
	(timeline fadeTo: 1)
		duration: 700 milliseconds.

	(timeline followPath: path)
		duration: 1 second.

	(timeline bounceVertically: 8)
		duration: 250 milliseconds;
		repeatsEvery: 250 milliseconds;
		endsAt: timeline end.

	(timeline pulseScaleTo: 1.08)
		duration: 100 milliseconds;
		repeatsEvery: 300 milliseconds;
		endsAt: timeline end.

	(timeline fadeTo: 0)
		duration: 100 milliseconds;
		ends: 100 milliseconds before: timeline end ].
```

Tracks without a start placement begin at `timeline start`; that is a default,
not a restriction. The path establishes the finite end in this example.

## Bloc integration rules

- `BlSpace time` is the only clock; simulated `BlTime` remains the test clock.
- A composed timeline returns one root `CFMotion` even though its tracks have
  independent durations, repetitions, and start anchors.
- Base path translation, additive translation, multiplicative scale, and
  additive rotation compose inside that root motion. Unrelated root motions
  remain subject to coordinator ownership rules.
- Layout and adoption keep their existing deferred-layout and overlay
  mechanics, but appear as tracks and still return the root `CFMotion`.
- No callbacks launch child animations at runtime. Timeline tracks compile to
  Bloc frame animations before the root motion starts.
