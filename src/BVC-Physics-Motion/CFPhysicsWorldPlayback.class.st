"
I manage continuous Motion playback for one Physics world.

My responsibility is to create, control, and release the Motion, Physics Behaviour, and presentation that make up one playback lifetime.
"
Class {
	#name : 'CFPhysicsWorldPlayback',
	#superclass : 'Object',
	#instVars : [ 'world', 'motion', 'presentation' ],
	#category : 'BVC-Physics-Motion',
	#package : 'BVC-Physics-Motion'
}

{ #category : 'instance creation' }
CFPhysicsWorldPlayback class >> on: aWorld [
	^ self new
		world: aWorld;
		yourself
]

{ #category : 'controlling' }
CFPhysicsWorldPlayback >> start [
	| coordinator |
	self isActive ifTrue: [
		motion isPaused ifTrue: [ motion resume ].
		^ motion ].
	self validateForStart.
	coordinator := world owner space motionCoordinator.
	presentation := CFPhysicsWorldPresentation on: world in: coordinator.
	motion := self newMotionWith: presentation in: coordinator.
	motion onTerminalDo: [ :endedMotion | self playbackEnded: endedMotion ].
	[ motion start ]
		on: Error
		do: [ :anError |
			self releasePlayback.
			anError pass ].
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
CFPhysicsWorldPlayback >> newMotionWith: aPresentation in: aCoordinator [
	| behaviour timeline |
	behaviour := CFPhysicsWorldMotionBehaviour
		on: world
		frameConsumer: aPresentation.
	timeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: behaviour in: timeline) indefinite.
	^ CFMotion timeline: timeline coordinator: aCoordinator
]

{ #category : 'private - lifecycle' }
CFPhysicsWorldPlayback >> playbackEnded: anEndedMotion [
	motion == anEndedMotion ifTrue: [ self releasePlayback ]
]

{ #category : 'private - lifecycle' }
CFPhysicsWorldPlayback >> releasePlayback [
	presentation ifNotNil: [ :aPresentation | aPresentation release ].
	presentation := nil.
	motion := nil
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
