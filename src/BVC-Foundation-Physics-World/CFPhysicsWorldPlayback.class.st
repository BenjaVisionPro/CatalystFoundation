"
I own continuous Motion playback for one CFPhysicsWorld.

I am the explicit integration boundary between Physics simulation and Motion playback. The world asks me to start, pause, resume or stop; I assemble and retain the Motion timeline, Physics Behaviour and world presentation needed for that playback.

One instance represents the reusable playback capability of one world. A running or paused Motion is one playback lifetime. Once that Motion reaches a terminal state I forget it, so a later #start creates a fresh Behaviour, presentation and fixed-step accumulator.
"
Class {
	#name : 'CFPhysicsWorldPlayback',
	#superclass : 'Object',
	#instVars : [ 'world', 'motion' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
}

{ #category : 'instance creation' }
CFPhysicsWorldPlayback class >> on: aWorld [
	^ self new
		world: aWorld;
		yourself
]

{ #category : 'controlling' }
CFPhysicsWorldPlayback >> start [
	self isActive ifTrue: [
		motion isPaused ifTrue: [ motion resume ].
		^ motion ].
	self validateForStart.
	world releasePresentation.
	motion := self newMotion.
	motion onTerminalDo: [ :endedMotion |
		motion == endedMotion ifTrue: [ motion := nil ] ].
	motion start.
	^ motion
]

{ #category : 'controlling' }
CFPhysicsWorldPlayback >> pause [
	motion ifNotNil: [ :aMotion | aMotion pause ]
]

{ #category : 'controlling' }
CFPhysicsWorldPlayback >> resume [
	motion ifNotNil: [ :aMotion | aMotion resume ]
]

{ #category : 'controlling' }
CFPhysicsWorldPlayback >> stop [
	motion ifNotNil: [ :aMotion | aMotion stop ]
]

{ #category : 'testing' }
CFPhysicsWorldPlayback >> isActive [
	^ motion notNil and: [
		motion isRunning or: [ motion isPaused ] ]
]

{ #category : 'accessing' }
CFPhysicsWorldPlayback >> motion [
	^ motion
]

{ #category : 'private - creation' }
CFPhysicsWorldPlayback >> newMotion [
	| coordinator behaviour timeline |
	coordinator := world owner space cfMotionCoordinator.
	behaviour := CFPhysicsWorldBehaviour
		on: world
		presentation: (CFPhysicsWorldPresentation on: world in: coordinator).
	timeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: behaviour in: timeline) indefinite.
	^ CFMotion timeline: timeline coordinator: coordinator
]

{ #category : 'private - validation' }
CFPhysicsWorldPlayback >> validateForStart [
	world owner ifNil: [
		self error: 'A Physics world needs an owner before it can start stepping' ].
	world owner space ifNil: [
		self error: 'A Physics world owner must be attached to a BlSpace before it can start stepping' ]
]

{ #category : 'private - initialization' }
CFPhysicsWorldPlayback >> world: aWorld [
	world := aWorld
]
