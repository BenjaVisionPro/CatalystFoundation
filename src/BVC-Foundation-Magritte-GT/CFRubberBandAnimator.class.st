Class {
	#name : 'CFRubberBandAnimator',
	#superclass : 'Object',
	#instVars : [
		'motion',
		'mode',
		'targetPosition',
		'springStiffness',
		'springDamping',
		'decelerationRate',
		'positionEpsilon',
		'velocityEpsilon'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'instance creation' }
CFRubberBandAnimator class >> on: aMotion [
	^ self new
		motion: aMotion;
		yourself
]

{ #category : 'configuration' }
CFRubberBandAnimator >> decelerationRate [
	^ decelerationRate
]

{ #category : 'configuration' }
CFRubberBandAnimator >> decelerationRate: aNumber [
	aNumber < 0
		ifTrue: [ self error: 'Deceleration rate must not be negative.' ].
	decelerationRate := aNumber
]

{ #category : 'animation' }
CFRubberBandAnimator >> decelerate [
	motion logicalVelocity = (0 @ 0)
		ifTrue: [ ^ self stop ].
	mode := #decelerating.
	targetPosition := nil.
	^ self
]

{ #category : 'animation' }
CFRubberBandAnimator >> decelerateWithVelocity: aVelocityPoint [
	motion logicalVelocity: aVelocityPoint.
	^ self decelerate
]

{ #category : 'testing' }
CFRubberBandAnimator >> hasTargetPosition [
	^ targetPosition notNil
]

{ #category : 'projection configuration' }
CFRubberBandAnimator >> horizontal [
	^ motion horizontal
]

{ #category : 'initialization' }
CFRubberBandAnimator >> initialize [
	super initialize.
	motion := CFRubberBandMotion new.
	mode := #idle.
	targetPosition := nil.
	springStiffness := 120.
	springDamping := 22.
	decelerationRate := 5.
	positionEpsilon := 0.01.
	velocityEpsilon := 0.01
]

{ #category : 'testing' }
CFRubberBandAnimator >> isAnimating [
	^ self isIdle not
]

{ #category : 'testing' }
CFRubberBandAnimator >> isDecelerating [
	^ mode = #decelerating
]

{ #category : 'testing' }
CFRubberBandAnimator >> isIdle [
	^ mode = #idle
]

{ #category : 'testing' }
CFRubberBandAnimator >> isSettling [
	^ mode = #settling
]

{ #category : 'private - testing' }
CFRubberBandAnimator >> isVelocitySmall: aVelocityPoint [
	^ aVelocityPoint x abs <= velocityEpsilon
		and: [ aVelocityPoint y abs <= velocityEpsilon ]
]

{ #category : 'private - testing' }
CFRubberBandAnimator >> isPosition: aPosition closeTo: anotherPosition [
	^ (aPosition x - anotherPosition x) abs <= positionEpsilon
		and: [ (aPosition y - anotherPosition y) abs <= positionEpsilon ]
]

{ #category : 'accessing' }
CFRubberBandAnimator >> mode [
	^ mode
]

{ #category : 'accessing' }
CFRubberBandAnimator >> motion [
	^ motion
]

{ #category : 'accessing' }
CFRubberBandAnimator >> motion: aMotion [
	motion := aMotion
]

{ #category : 'configuration' }
CFRubberBandAnimator >> positionEpsilon [
	^ positionEpsilon
]

{ #category : 'configuration' }
CFRubberBandAnimator >> positionEpsilon: aNumber [
	aNumber < 0
		ifTrue: [ self error: 'Position epsilon must not be negative.' ].
	positionEpsilon := aNumber
]

{ #category : 'printing' }
CFRubberBandAnimator >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(mode: ';
		nextPutAll: mode asString;
		nextPutAll: ', motion: ';
		nextPutAll: motion asString;
		nextPut: $)
]

{ #category : 'animation' }
CFRubberBandAnimator >> settleToBounds [
	targetPosition := motion releaseTargetPosition.
	(self isPosition: motion logicalPosition closeTo: targetPosition)
		ifTrue: [
			motion snapToBounds.
			^ self stop ].
	mode := #settling.
	^ self
]

{ #category : 'private - animation' }
CFRubberBandAnimator >> stepDecelerationBy: deltaSeconds [
	| factor |
	motion moveBy: motion logicalVelocity * deltaSeconds.

	factor := 1 - (decelerationRate * deltaSeconds).
	factor < 0
		ifTrue: [ factor := 0 ].
	motion logicalVelocity: motion logicalVelocity * factor.

	motion isOutOfBounds
		ifTrue: [ ^ self settleToBounds ].

	(self isVelocitySmall: motion logicalVelocity)
		ifTrue: [ self stop ].

	^ self
]

{ #category : 'animation' }
CFRubberBandAnimator >> stepBy: deltaSeconds [
	deltaSeconds < 0
		ifTrue: [ self error: 'Step duration must not be negative.' ].

	self isIdle
		ifTrue: [ ^ self ].

	self isDecelerating
		ifTrue: [ ^ self stepDecelerationBy: deltaSeconds ].

	self isSettling
		ifTrue: [ ^ self stepSettlingBy: deltaSeconds ].

	^ self
]

{ #category : 'private - animation' }
CFRubberBandAnimator >> stepSettlingBy: deltaSeconds [
	| displacement acceleration newVelocity newPosition |
	targetPosition ifNil: [ targetPosition := motion releaseTargetPosition ].

	displacement := targetPosition - motion logicalPosition.
	acceleration := (displacement * springStiffness) - (motion logicalVelocity * springDamping).
	newVelocity := motion logicalVelocity + (acceleration * deltaSeconds).
	newPosition := motion logicalPosition + (newVelocity * deltaSeconds).

	motion
		logicalVelocity: newVelocity;
		moveTo: newPosition.

	((self isPosition: newPosition closeTo: targetPosition)
		and: [ self isVelocitySmall: newVelocity ])
		ifTrue: [
			motion
				moveTo: targetPosition;
				logicalVelocity: 0 @ 0.
			self stop ].

	^ self
]

{ #category : 'animation' }
CFRubberBandAnimator >> stop [
	mode := #idle.
	targetPosition := nil.
	motion logicalVelocity: 0 @ 0.
	^ self
]

{ #category : 'configuration' }
CFRubberBandAnimator >> springDamping [
	^ springDamping
]

{ #category : 'configuration' }
CFRubberBandAnimator >> springDamping: aNumber [
	aNumber < 0
		ifTrue: [ self error: 'Spring damping must not be negative.' ].
	springDamping := aNumber
]

{ #category : 'configuration' }
CFRubberBandAnimator >> springStiffness [
	^ springStiffness
]

{ #category : 'configuration' }
CFRubberBandAnimator >> springStiffness: aNumber [
	aNumber < 0
		ifTrue: [ self error: 'Spring stiffness must not be negative.' ].
	springStiffness := aNumber
]

{ #category : 'accessing' }
CFRubberBandAnimator >> targetPosition [
	^ targetPosition
]

{ #category : 'configuration' }
CFRubberBandAnimator >> velocityEpsilon [
	^ velocityEpsilon
]

{ #category : 'configuration' }
CFRubberBandAnimator >> velocityEpsilon: aNumber [
	aNumber < 0
		ifTrue: [ self error: 'Velocity epsilon must not be negative.' ].
	velocityEpsilon := aNumber
]

{ #category : 'projection configuration' }
CFRubberBandAnimator >> vertical [
	^ motion vertical
]
