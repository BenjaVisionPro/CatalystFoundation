"
I represent a force acting between two Physics endpoints.

My responsibility is to resolve endpoint geometry and a distance response, then apply equal and opposite forces to the connected bodies.
"
Class {
	#name : 'CFPhysicsPairForce',
	#superclass : 'CFPhysicsForce',
	#instVars : [ 'endpointPair', 'distanceResponse' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsPairForce class >> between: firstBody and: secondBody [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: firstBody)
		andAnchor: (CFPhysicsBodyCentreAnchor on: secondBody)
]

{ #category : 'instance creation' }
CFPhysicsPairForce class >> betweenAnchor: firstAnchor andAnchor: secondAnchor [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair
		anchorA: firstAnchor
		anchorB: secondAnchor)
]

{ #category : 'instance creation' }
CFPhysicsPairForce class >> betweenEndpoints: anEndpointPair [
	^ self new
		endpointPair: anEndpointPair;
		yourself
]

{ #category : 'initialization' }
CFPhysicsPairForce >> initialize [
	super initialize.
	distanceResponse := CFPhysicsConstantForceResponse new
]

{ #category : 'accessing' }
CFPhysicsPairForce >> endpointPair [
	^ endpointPair
]

{ #category : 'accessing' }
CFPhysicsPairForce >> endpointPair: anEndpointPair [
	endpointPair := anEndpointPair
]

{ #category : 'accessing' }
CFPhysicsPairForce >> anchorA [
	^ endpointPair anchorA
]

{ #category : 'accessing' }
CFPhysicsPairForce >> anchorB [
	^ endpointPair anchorB
]

{ #category : 'accessing' }
CFPhysicsPairForce >> bodyA [
	^ endpointPair bodyA
]

{ #category : 'accessing' }
CFPhysicsPairForce >> bodyB [
	^ endpointPair bodyB
]

{ #category : 'configuration' }
CFPhysicsPairForce >> distanceResponse [
	^ distanceResponse
]

{ #category : 'configuration' }
CFPhysicsPairForce >> distanceResponse: aDistanceResponse [
	distanceResponse := aDistanceResponse
]

{ #category : 'configuration' }
CFPhysicsPairForce >> force [
	^ distanceResponse force
]

{ #category : 'configuration' }
CFPhysicsPairForce >> force: aNumber [
	distanceResponse force: aNumber
]

{ #category : 'configuration' }
CFPhysicsPairForce >> maximumDistance [
	^ distanceResponse maximumDistance
]

{ #category : 'configuration' }
CFPhysicsPairForce >> maximumDistance: aNumber [
	distanceResponse maximumDistance: aNumber
]

{ #category : 'testing' }
CFPhysicsPairForce >> includesBody: aBody [
	^ endpointPair includesBody: aBody
]

{ #category : 'stepping' }
CFPhysicsPairForce >> applyForStep: seconds [
	| points displacement distance distanceMetres forceMagnitude force firstBody secondBody |
	firstBody := self bodyA.
	secondBody := self bodyB.
	points := endpointPair worldPoints.
	displacement := points second - points first.
	distance := displacement r.
	distance = 0 ifTrue: [ ^ self ].
	distanceMetres := self metresForLengthUnits: distance.
	forceMagnitude := distanceResponse forceMagnitudeAtDistance: distanceMetres.
	forceMagnitude = 0 ifTrue: [ ^ self ].
	force := (self directionFor: displacement distance: distance) * forceMagnitude.
	firstBody ifNotNil: [ self applyForce: force to: firstBody ].
	secondBody ifNotNil: [ self applyForce: force negated to: secondBody ]
]

{ #category : 'stepping' }
CFPhysicsPairForce >> directionFor: displacement distance: distance [
	self subclassResponsibility
]

{ #category : 'validation' }
CFPhysicsPairForce >> validateForWorld: aWorld [
	endpointPair ifNil: [ self error: 'A pair force requires endpoints' ].
	endpointPair world == aWorld ifFalse: [
		self error: 'Force endpoints must belong to the Physics world' ]
]
