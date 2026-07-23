"
I apply a coordinated directional wind to one element or a selected collection of elements.

Intensity is the public semantic control. I translate it into a repeating gust profile built from ordinary CFMotionValue transitions. Motion owns the temporal shape and repetition of the gust. I own wind direction, participant selection and applying the current force to Physics bodies.
"
Class {
	#name : 'CFPhysicsWindBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [ 'direction', 'intensity', 'participants', 'forceValue', 'timeline' ],
	#category : 'BVC-Foundation-Physics-Motion-Behaviours',
	#package : 'BVC-Foundation-Physics-Motion'
}

{ #category : 'initialization' }
CFPhysicsWindBehaviour >> initialize [
	super initialize.
	direction := 1.0 @ 0.0.
	intensity := 0.25
]

{ #category : 'configuration' }
CFPhysicsWindBehaviour >> direction [
	^ direction
]

{ #category : 'configuration' }
CFPhysicsWindBehaviour >> direction: aPoint [
	| length |
	length := ((aPoint x * aPoint x) + (aPoint y * aPoint y)) sqrt.
	length isZero ifTrue: [ self error: 'Wind direction must not be zero' ].
	direction := (aPoint x / length) @ (aPoint y / length)
]

{ #category : 'configuration' }
CFPhysicsWindBehaviour >> intensity [
	^ intensity
]

{ #category : 'configuration' }
CFPhysicsWindBehaviour >> intensity: aNumber [
	intensity := (aNumber asFloat min: 1.0) max: 0.0.
	self rebuildMotion
]

{ #category : 'configuration' }
CFPhysicsWindBehaviour >> affecting: aCollectionOrProvider [
	participants := aCollectionOrProvider.
	^ self
]

{ #category : 'accessing' }
CFPhysicsWindBehaviour >> participants [
	^ self resolvedParticipantsFrom: participants default: [
		self element physics existingWorld == world
			ifTrue: [ world members ]
			ifFalse: [ { self element } ] ]
]

{ #category : 'accessing' }
CFPhysicsWindBehaviour >> currentForce [
	forceValue ifNil: [ self ensureMotion ].
	^ direction * forceValue value
]

{ #category : 'updating' }
CFPhysicsWindBehaviour >> updateForStep: aPhysicsStep [
	self ensureMotion.
	timeline advanceBy: world stepDuration.
	self participants do: [ :each |
		(world includes: each) ifTrue: [
			each physics requireBodyState applyForce: self currentForce ] ]
]

{ #category : 'private - motion' }
CFPhysicsWindBehaviour >> ensureMotion [
	timeline ifNil: [ self buildMotion ]
]

{ #category : 'private - motion' }
CFPhysicsWindBehaviour >> rebuildMotion [
	timeline := nil.
	forceValue := nil
]

{ #category : 'private - motion' }
CFPhysicsWindBehaviour >> buildMotion [
	| base peak lull rise hold release recovery riseDuration holdDuration releaseDuration recoveryDuration rise hold release recovery |
	base := 15.0 + (85.0 * intensity).
	peak := base * (1.15 + (1.85 * intensity)).
	lull := base * (0.55 - (0.25 * intensity)).
	riseDuration := (1.3 - (0.9 * intensity)) seconds.
	holdDuration := ((0.45 - (0.30 * intensity)) seconds) max: 1 milliSecond.
	releaseDuration := (1.8 - (1.15 * intensity)) seconds.
	recoveryDuration := (1.0 - (0.55 * intensity)) seconds.
	forceValue := CFMotionValue value: base.
	timeline := CFMotionTimeline new.
	rise := CFMotionTimelineTrack
		on: (forceValue transitionFrom: base to: peak)
		in: timeline.
	rise
		duration: riseDuration;
		easing: (BlDecelerateInterpolator factor: 1.2 + (intensity * 1.8)).
	hold := CFMotionTimelineTrack
		on: (forceValue transitionFrom: peak to: peak)
		in: timeline.
	hold startsAt: rise end; duration: holdDuration; easing: BlEasing linear.
	release := CFMotionTimelineTrack
		on: (forceValue transitionFrom: peak to: lull)
		in: timeline.
	release
		startsAt: hold end;
		duration: releaseDuration;
		easing: (BlDecelerateInterpolator factor: 2.4 - intensity).
	recovery := CFMotionTimelineTrack
		on: (forceValue transitionFrom: lull to: base)
		in: timeline.
	recovery
		startsAt: release end;
		duration: recoveryDuration;
		easing: (BlDecelerateInterpolator factor: 1.8).
	timeline repeat; prepareForPlayback
]

{ #category : 'removing' }
CFPhysicsWindBehaviour >> removing [
	self rebuildMotion
]
