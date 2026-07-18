Class {
	#name : 'CFPhysicsSpringConstraint',
	#superclass : 'Object',
	#instVars : [ 'firstBody', 'secondBody', 'restLength', 'stiffness', 'damping', 'maximumForce', 'active' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
}

{ #category : 'instance creation' }
CFPhysicsSpringConstraint class >> between: firstBodyState and: secondBodyState [
	^ self new
		firstBody: firstBodyState;
		secondBody: secondBodyState;
		restLength: (self distanceBetween: firstBodyState and: secondBodyState);
		yourself
]

{ #category : 'private' }
CFPhysicsSpringConstraint class >> distanceBetween: firstBodyState and: secondBodyState [
	^ ((secondBodyState position + (secondBodyState extent / 2.0))
		- (firstBodyState position + (firstBodyState extent / 2.0))) r
]

{ #category : 'initialization' }
CFPhysicsSpringConstraint >> initialize [
	super initialize.
	restLength := 0.0.
	stiffness := 40.0.
	damping := 8.0.
	maximumForce := 100000.0.
	active := true
]

{ #category : 'accessing' }
CFPhysicsSpringConstraint >> firstBody [ ^ firstBody ]

{ #category : 'accessing' }
CFPhysicsSpringConstraint >> firstBody: aBodyState [ firstBody := aBodyState ]

{ #category : 'accessing' }
CFPhysicsSpringConstraint >> secondBody [ ^ secondBody ]

{ #category : 'accessing' }
CFPhysicsSpringConstraint >> secondBody: aBodyState [ secondBody := aBodyState ]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> restLength [ ^ restLength ]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> restLength: aNumber [ restLength := aNumber asFloat max: 0.0 ]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> stiffness [ ^ stiffness ]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> stiffness: aNumber [ stiffness := aNumber asFloat max: 0.0 ]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> damping [ ^ damping ]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> damping: aNumber [ damping := aNumber asFloat max: 0.0 ]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> maximumForce [ ^ maximumForce ]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> maximumForce: aNumber [ maximumForce := aNumber asFloat max: 0.0 ]

{ #category : 'testing' }
CFPhysicsSpringConstraint >> isActive [ ^ active ]

{ #category : 'testing' }
CFPhysicsSpringConstraint >> includesBody: aBodyState [
	^ firstBody == aBodyState or: [ secondBody == aBodyState ]
]

{ #category : 'ordering' }
CFPhysicsSpringConstraint >> orderingKey [
	| firstSequence secondSequence |
	firstSequence := firstBody sequence min: secondBody sequence.
	secondSequence := firstBody sequence max: secondBody sequence.
	^ (firstSequence * 1000000) + secondSequence
]

{ #category : 'geometry' }
CFPhysicsSpringConstraint >> firstCentre [
	^ firstBody position + (firstBody extent / 2.0)
]

{ #category : 'geometry' }
CFPhysicsSpringConstraint >> secondCentre [
	^ secondBody position + (secondBody extent / 2.0)
]

{ #category : 'stepping' }
CFPhysicsSpringConstraint >> prepareForStep: seconds [
	| displacement distance direction relativeSpeed extension force impulse |
	active ifFalse: [ ^ self ].
	(firstBody isDynamic or: [ secondBody isDynamic ]) ifFalse: [ ^ self ].
	displacement := self secondCentre - self firstCentre.
	distance := displacement r.
	distance = 0 ifTrue: [ ^ self ].
	direction := displacement / distance.
	relativeSpeed := (secondBody velocity - firstBody velocity) dotProduct: direction.
	extension := distance - restLength.
	force := (extension * stiffness) + (relativeSpeed * damping).
	force := (force max: maximumForce negated) min: maximumForce.
	impulse := direction * (force * seconds).
	firstBody isDynamic ifTrue: [
		firstBody addVelocity: impulse * firstBody inverseMass ].
	secondBody isDynamic ifTrue: [
		secondBody addVelocity: impulse negated * secondBody inverseMass ].
	force = 0 ifFalse: [
		firstBody wake.
		secondBody wake ]
]

{ #category : 'controlling' }
CFPhysicsSpringConstraint >> release [
	active := false
]
