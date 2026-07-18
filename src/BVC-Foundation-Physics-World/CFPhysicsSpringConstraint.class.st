Class {
	#name : 'CFPhysicsSpringConstraint',
	#superclass : 'Object',
	#instVars : [ 'endpointPair', 'restLength', 'stiffness', 'damping', 'maximumForce', 'active', 'sequence' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
}

{ #category : 'instance creation' }
CFPhysicsSpringConstraint class >> between: firstBodyState and: secondBodyState [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: firstBodyState)
		andAnchor: (CFPhysicsBodyCentreAnchor on: secondBodyState)
]

{ #category : 'instance creation' }
CFPhysicsSpringConstraint class >> betweenAnchor: firstAnchor andAnchor: secondAnchor [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair
		anchorA: firstAnchor
		anchorB: secondAnchor)
]

{ #category : 'instance creation' }
CFPhysicsSpringConstraint class >> betweenEndpoints: anEndpointPair [
	^ self new
		endpointPair: anEndpointPair;
		restLength: (self distanceBetweenEndpoints: anEndpointPair);
		yourself
]

{ #category : 'private' }
CFPhysicsSpringConstraint class >> distanceBetweenEndpoints: anEndpointPair [
	^ (anEndpointPair worldPointB - anEndpointPair worldPointA) r
]

{ #category : 'initialization' }
CFPhysicsSpringConstraint >> initialize [
	super initialize.
	restLength := 0.0.
	stiffness := 40.0.
	damping := 8.0.
	maximumForce := 100000.0.
	active := true.
	sequence := 0
]

{ #category : 'accessing' }
CFPhysicsSpringConstraint >> endpointPair [ ^ endpointPair ]

{ #category : 'accessing' }
CFPhysicsSpringConstraint >> endpointPair: anEndpointPair [ endpointPair := anEndpointPair ]

{ #category : 'accessing' }
CFPhysicsSpringConstraint >> anchorA [ ^ endpointPair anchorA ]

{ #category : 'accessing' }
CFPhysicsSpringConstraint >> anchorB [ ^ endpointPair anchorB ]

{ #category : 'accessing' }
CFPhysicsSpringConstraint >> bodyA [ ^ endpointPair bodyA ]

{ #category : 'accessing' }
CFPhysicsSpringConstraint >> bodyB [ ^ endpointPair bodyB ]

{ #category : 'accessing' }
CFPhysicsSpringConstraint >> firstBody [ ^ self bodyA ]

{ #category : 'accessing' }
CFPhysicsSpringConstraint >> secondBody [ ^ self bodyB ]

{ #category : 'ordering' }
CFPhysicsSpringConstraint >> sequence [ ^ sequence ]

{ #category : 'ordering' }
CFPhysicsSpringConstraint >> sequence: anInteger [ sequence := anInteger ]

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
	^ endpointPair includesBody: aBodyState
]

{ #category : 'ordering' }
CFPhysicsSpringConstraint >> orderingKey [
	^ sequence
]

{ #category : 'stepping' }
CFPhysicsSpringConstraint >> prepareForStep: seconds [
	| displacement distance direction relativeSpeed extension force impulse firstBody secondBody |
	active ifFalse: [ ^ self ].
	firstBody := self bodyA.
	secondBody := self bodyB.
	(firstBody isDynamic or: [ secondBody isDynamic ]) ifFalse: [ ^ self ].
	displacement := endpointPair worldPointB - endpointPair worldPointA.
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
