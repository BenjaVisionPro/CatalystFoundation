"
I make one element or a selected collection of elements jolt at irregular intervals like jumping beans.

Intensity is my public semantic control. I translate it into delay, linear impulse and angular impulse ranges. Each participant keeps an independent schedule, while one injected random source makes the Behaviour deterministic in tests and reproducible when supplied with a deterministic generator.

My jolts are discrete Physics events rather than interpolated values, so I apply impulses directly during fixed Physics steps. Motion remains responsible for continuous temporal interpolation; I do not create a parallel animation mechanism.
"
Class {
	#name : 'CFPhysicsJumpingBeanBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'random',
		'nextJoltTimes',
		'participants',
		'intensity',
		'minimumDelay',
		'maximumDelay',
		'minimumImpulse',
		'maximumImpulse',
		'minimumAngularImpulse',
		'maximumAngularImpulse'
	],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsJumpingBeanBehaviour >> initialize [
	super initialize.
	random := CFPhysicsRandomSource new.
	nextJoltTimes := IdentityDictionary new.
	self intensity: 0.25
]

{ #category : 'accessing' }
CFPhysicsJumpingBeanBehaviour >> random [
	^ random
]

{ #category : 'accessing' }
CFPhysicsJumpingBeanBehaviour >> random: aRandom [
	self randomSource: aRandom
]

{ #category : 'accessing' }
CFPhysicsJumpingBeanBehaviour >> randomSource: aRandom [
	random := aRandom
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> intensity [
	^ intensity
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> intensity: aNumber [
	intensity := (aNumber asFloat min: 1.0) max: 0.0.
	minimumDelay := 1.8 - (1.5 * intensity).
	maximumDelay := 3.0 - (2.3 * intensity).
	minimumImpulse := 30.0 + (90.0 * intensity).
	maximumImpulse := 70.0 + (180.0 * intensity).
	minimumAngularImpulse := 0.0 - (1.0 + (5.0 * intensity)).
	maximumAngularImpulse := 1.0 + (5.0 * intensity)
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> affecting: aCollectionOrProvider [
	participants := aCollectionOrProvider.
	^ self
]

{ #category : 'accessing' }
CFPhysicsJumpingBeanBehaviour >> participants [
	^ self resolvedParticipantsFrom: participants default: [ { self element } ]
]

{ #category : 'accessing' }
CFPhysicsJumpingBeanBehaviour >> nextJoltTime [
	^ self nextJoltTimeFor: self element
]

{ #category : 'accessing' }
CFPhysicsJumpingBeanBehaviour >> nextJoltTimeFor: anElement [
	^ nextJoltTimes at: anElement ifAbsent: [ nil ]
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> minimumDelay [
	^ minimumDelay
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> minimumDelay: aNumber [
	minimumDelay := aNumber asFloat max: 0.0.
	maximumDelay := maximumDelay max: minimumDelay
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> maximumDelay [
	^ maximumDelay
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> maximumDelay: aNumber [
	maximumDelay := aNumber asFloat max: minimumDelay
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> minimumImpulse [
	^ minimumImpulse
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> minimumImpulse: aNumber [
	minimumImpulse := aNumber asFloat max: 0.0.
	maximumImpulse := maximumImpulse max: minimumImpulse
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> maximumImpulse [
	^ maximumImpulse
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> maximumImpulse: aNumber [
	maximumImpulse := aNumber asFloat max: minimumImpulse
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> minimumAngularImpulse [
	^ minimumAngularImpulse
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> minimumAngularImpulse: aNumber [
	minimumAngularImpulse := aNumber asFloat.
	maximumAngularImpulse := maximumAngularImpulse max: minimumAngularImpulse
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> maximumAngularImpulse [
	^ maximumAngularImpulse
]

{ #category : 'configuration' }
CFPhysicsJumpingBeanBehaviour >> maximumAngularImpulse: aNumber [
	maximumAngularImpulse := aNumber asFloat max: minimumAngularImpulse
]

{ #category : 'updating' }
CFPhysicsJumpingBeanBehaviour >> updateForStep: aPhysicsStep [
	| currentParticipants |
	currentParticipants := self participants.
	self forgetParticipantsAbsentFrom: currentParticipants.
	currentParticipants do: [ :each |
		(world includes: each) ifTrue: [
			self updateParticipant: each forStep: aPhysicsStep ] ]
]

{ #category : 'private - updating' }
CFPhysicsJumpingBeanBehaviour >> updateParticipant: anElement forStep: aPhysicsStep [
	| nextJoltTime |
	nextJoltTime := self nextJoltTimeFor: anElement.
	nextJoltTime ifNil: [
		^ self scheduleNextJoltFor: anElement after: aPhysicsStep simulationTime ].
	aPhysicsStep simulationTime < nextJoltTime ifTrue: [ ^ self ].
	self applyJoltTo: anElement.
	self scheduleNextJoltFor: anElement after: aPhysicsStep simulationTime
]

{ #category : 'private - scheduling' }
CFPhysicsJumpingBeanBehaviour >> scheduleNextJoltFor: anElement after: simulationTime [
	nextJoltTimes
		at: anElement
		put: simulationTime + (self randomValueBetween: minimumDelay and: maximumDelay using: random)
]

{ #category : 'private - scheduling' }
CFPhysicsJumpingBeanBehaviour >> forgetParticipantsAbsentFrom: currentParticipants [
	(nextJoltTimes keys select: [ :each | (currentParticipants identityIncludes: each) not ])
		do: [ :each | nextJoltTimes removeKey: each ]
]

{ #category : 'private - jolting' }
CFPhysicsJumpingBeanBehaviour >> applyJoltTo: anElement [
	| body angle magnitude impulse angularImpulse |
	body := anElement physics requireBodyState.
	angle := random next * (Float pi * 2.0).
	magnitude := self randomValueBetween: minimumImpulse and: maximumImpulse using: random.
	impulse := angle cos @ angle sin * magnitude.
	angularImpulse := self
		randomValueBetween: minimumAngularImpulse
		and: maximumAngularImpulse
		using: random.
	body
		applyImpulse: impulse atWorldPoint: body centre;
		applyAngularImpulse: angularImpulse
]


{ #category : 'removing' }
CFPhysicsJumpingBeanBehaviour >> removing [
	nextJoltTimes removeAll
]
