Class {
	#name : 'CFPhysicsJumpingBeanBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'random',
		'nextJoltTime',
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
	random := Random new.
	minimumDelay := 0.5.
	maximumDelay := 2.0.
	minimumImpulse := 40.0.
	maximumImpulse := 120.0.
	minimumAngularImpulse := -3.0.
	maximumAngularImpulse := 3.0
]

{ #category : 'accessing' }
CFPhysicsJumpingBeanBehaviour >> random [
	^ random
]

{ #category : 'accessing' }
CFPhysicsJumpingBeanBehaviour >> random: aRandom [
	random := aRandom
]

{ #category : 'accessing' }
CFPhysicsJumpingBeanBehaviour >> nextJoltTime [
	^ nextJoltTime
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
	nextJoltTime ifNil: [
		^ self scheduleNextJoltAfter: aPhysicsStep simulationTime ].
	aPhysicsStep simulationTime < nextJoltTime ifTrue: [ ^ self ].
	self applyJolt.
	self scheduleNextJoltAfter: aPhysicsStep simulationTime
]

{ #category : 'private - scheduling' }
CFPhysicsJumpingBeanBehaviour >> scheduleNextJoltAfter: simulationTime [
	nextJoltTime := simulationTime
		+ (self randomValueBetween: minimumDelay and: maximumDelay)
]

{ #category : 'private - jolting' }
CFPhysicsJumpingBeanBehaviour >> applyJolt [
	| body angle magnitude impulse angularImpulse |
	body := physics requireBodyState.
	angle := random next * (Float pi * 2.0).
	magnitude := self randomValueBetween: minimumImpulse and: maximumImpulse.
	impulse := angle cos @ angle sin * magnitude.
	angularImpulse := self
		randomValueBetween: minimumAngularImpulse
		and: maximumAngularImpulse.
	body
		applyImpulse: impulse atWorldPoint: body centre;
		applyAngularImpulse: angularImpulse
]

{ #category : 'private - random' }
CFPhysicsJumpingBeanBehaviour >> randomValueBetween: minimum and: maximum [
	^ minimum + (random next * (maximum - minimum))
]
