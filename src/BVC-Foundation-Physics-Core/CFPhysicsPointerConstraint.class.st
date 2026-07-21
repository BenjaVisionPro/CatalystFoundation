Class {
	#name : 'CFPhysicsPointerConstraint',
	#superclass : 'Object',
	#instVars : [ 'body', 'pointerPosition', 'previousPointerPosition', 'previousTimestamp', 'pointerVelocity', 'grabOffset', 'responsiveness', 'velocityRetention', 'maximumSpeed', 'active' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsPointerConstraint class >> body: aBodyState pointerPosition: aPoint [
	^ self new
		body: aBodyState;
		beginAt: aPoint;
		yourself
]

{ #category : 'instance creation' }
CFPhysicsPointerConstraint class >> body: aBodyState pointerPosition: aPoint timestamp: aDateAndTime [
	^ self new
		body: aBodyState;
		beginAt: aPoint timestamp: aDateAndTime;
		yourself
]

{ #category : 'initialization' }
CFPhysicsPointerConstraint >> initialize [
	super initialize.
	responsiveness := 24.0.
	velocityRetention := 0.2.
	maximumSpeed := 2400.0.
	pointerVelocity := 0 @ 0.
	active := false
]

{ #category : 'accessing' }
CFPhysicsPointerConstraint >> body [ ^ body ]

{ #category : 'accessing' }
CFPhysicsPointerConstraint >> body: aBodyState [ body := aBodyState ]

{ #category : 'controlling' }
CFPhysicsPointerConstraint >> beginAt: aPoint [
	self beginAt: aPoint timestamp: self currentTimestamp
]

{ #category : 'controlling' }
CFPhysicsPointerConstraint >> beginAt: aPoint timestamp: aDateAndTime [
	pointerPosition := aPoint.
	previousPointerPosition := aPoint.
	previousTimestamp := aDateAndTime ifNil: [ self currentTimestamp ].
	pointerVelocity := 0 @ 0.
	grabOffset := aPoint - body position.
	active := true.
	body wake
]


{ #category : 'controlling' }
CFPhysicsPointerConstraint >> movePointerPositionTo: aPoint [
	self movePointerPositionTo: aPoint timestamp: self currentTimestamp
]

{ #category : 'controlling' }
CFPhysicsPointerConstraint >> movePointerPositionTo: aPoint timestamp: aDateAndTime [
	active ifFalse: [ ^ self ].
	pointerPosition := aPoint.
	previousPointerPosition := aPoint.
	previousTimestamp := aDateAndTime ifNil: [ self currentTimestamp ].
	pointerVelocity := 0 @ 0.
	body wake
]

{ #category : 'controlling' }
CFPhysicsPointerConstraint >> updatePointerPosition: aPoint [
	self updatePointerPosition: aPoint timestamp: self currentTimestamp
]

{ #category : 'controlling' }
CFPhysicsPointerConstraint >> updatePointerPosition: aPoint timestamp: aDateAndTime [
	| seconds |
	active ifFalse: [ ^ self ].
	aDateAndTime ifNil: [ ^ self updatePointerPosition: aPoint ].
	seconds := (aDateAndTime - previousTimestamp) asMilliSeconds / 1000.0.
	seconds > 0 ifTrue: [
		pointerVelocity := (aPoint - previousPointerPosition) / seconds ].
	previousPointerPosition := aPoint.
	previousTimestamp := aDateAndTime.
	pointerPosition := aPoint.
	body wake
]

{ #category : 'private' }
CFPhysicsPointerConstraint >> currentTimestamp [
	^ DateAndTime now
]

{ #category : 'stepping' }
CFPhysicsPointerConstraint >> prepareForStep: seconds [
	| desiredPosition correction desiredVelocity blendedVelocity |
	(active and: [ body isDynamic ]) ifFalse: [ ^ self ].
	desiredPosition := pointerPosition - grabOffset.
	correction := desiredPosition - body position.
	desiredVelocity := (correction * responsiveness) + pointerVelocity.
	blendedVelocity := (body velocity * velocityRetention)
		+ (desiredVelocity * (1.0 - velocityRetention)).
	body velocity: (self limitedVelocity: blendedVelocity).
	body wake
]

{ #category : 'private' }
CFPhysicsPointerConstraint >> limitedVelocity: aPoint [
	| speed |
	speed := aPoint r.
	(speed <= maximumSpeed or: [ speed = 0 ]) ifTrue: [ ^ aPoint ].
	^ aPoint * (maximumSpeed / speed)
]

{ #category : 'controlling' }
CFPhysicsPointerConstraint >> cancel [
	active := false
]

{ #category : 'controlling' }
CFPhysicsPointerConstraint >> release [
	active ifFalse: [ ^ self ].
	active := false.
	body isDynamic ifTrue: [ body velocity: (self limitedVelocity: pointerVelocity) ]
]

{ #category : 'testing' }
CFPhysicsPointerConstraint >> isActive [ ^ active ]

{ #category : 'accessing' }
CFPhysicsPointerConstraint >> pointerPosition [ ^ pointerPosition ]

{ #category : 'accessing' }
CFPhysicsPointerConstraint >> pointerVelocity [ ^ pointerVelocity ]

{ #category : 'accessing' }
CFPhysicsPointerConstraint >> grabOffset [ ^ grabOffset ]

{ #category : 'configuration' }
CFPhysicsPointerConstraint >> responsiveness [ ^ responsiveness ]

{ #category : 'configuration' }
CFPhysicsPointerConstraint >> responsiveness: aNumber [ responsiveness := aNumber asFloat max: 0.0 ]

{ #category : 'configuration' }
CFPhysicsPointerConstraint >> velocityRetention [ ^ velocityRetention ]

{ #category : 'configuration' }
CFPhysicsPointerConstraint >> velocityRetention: aNumber [ velocityRetention := (aNumber asFloat max: 0.0) min: 1.0 ]

{ #category : 'configuration' }
CFPhysicsPointerConstraint >> maximumSpeed [ ^ maximumSpeed ]

{ #category : 'configuration' }
CFPhysicsPointerConstraint >> maximumSpeed: aNumber [ maximumSpeed := aNumber asFloat max: 0.0 ]
