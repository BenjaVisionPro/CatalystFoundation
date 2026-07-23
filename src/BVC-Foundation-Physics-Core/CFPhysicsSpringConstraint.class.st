Class {
	#name : 'CFPhysicsSpringConstraint',
	#superclass : 'Object',
	#instVars : [ 'endpointPair', 'restLength', 'stiffness', 'damping', 'maximumForce', 'active', 'sequence' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
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
	| points |
	points := anEndpointPair worldPoints.
	^ (points second - points first) r
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
CFPhysicsSpringConstraint >> restLength: aValue [
	aValue isNumber
		ifTrue: [ restLength := aValue asFloat max: 0.0 ]
		ifFalse: [
			aValue physicsValue asFloat.
			restLength := aValue ]
]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> stiffness [ ^ stiffness ]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> stiffness: aValue [
	aValue isNumber
		ifTrue: [ stiffness := aValue asFloat max: 0.0 ]
		ifFalse: [
			aValue physicsValue asFloat.
			stiffness := aValue ]
]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> damping [ ^ damping ]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> damping: aValue [
	aValue isNumber
		ifTrue: [ damping := aValue asFloat max: 0.0 ]
		ifFalse: [
			aValue physicsValue asFloat.
			damping := aValue ]
]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> maximumForce [ ^ maximumForce ]

{ #category : 'configuration' }
CFPhysicsSpringConstraint >> maximumForce: aValue [
	aValue isNumber
		ifTrue: [ maximumForce := aValue asFloat max: 0.0 ]
		ifFalse: [
			aValue physicsValue asFloat.
			maximumForce := aValue ]
]

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
	| points displacement distance direction relativeSpeed extension force impulse firstBody secondBody firstVelocity secondVelocity resolvedMaximumForce |
	active ifFalse: [ ^ self ].
	firstBody := self bodyA.
	secondBody := self bodyB.
	points := endpointPair worldPoints.
	displacement := points second - points first.
	distance := displacement r.
	distance = 0 ifTrue: [ ^ self ].
	direction := displacement / distance.
	firstVelocity := firstBody ifNil: [ 0 @ 0 ] ifNotNil: [ firstBody velocity ].
	secondVelocity := secondBody ifNil: [ 0 @ 0 ] ifNotNil: [ secondBody velocity ].
	relativeSpeed := (secondVelocity - firstVelocity) dotProduct: direction.
	extension := distance - (restLength physicsValue asFloat max: 0.0).
	force :=
		(extension * (stiffness physicsValue asFloat max: 0.0))
			+ (relativeSpeed * (damping physicsValue asFloat max: 0.0)).
	resolvedMaximumForce := maximumForce physicsValue asFloat max: 0.0.
	force := (force max: resolvedMaximumForce negated) min: resolvedMaximumForce.
	impulse := direction * (force * seconds).
	firstBody ifNotNil: [
		firstBody addVelocity: impulse * firstBody inverseMass ].
	secondBody ifNotNil: [
		secondBody addVelocity: impulse negated * secondBody inverseMass ].
	force = 0 ifFalse: [
		firstBody ifNotNil: [ firstBody wake ].
		secondBody ifNotNil: [ secondBody wake ] ]
]

{ #category : 'controlling' }
CFPhysicsSpringConstraint >> release [
	active := false
]
