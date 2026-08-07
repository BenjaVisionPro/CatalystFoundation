"
I repel each selected Physics body from every other selected body.

My distance response determines the repulsive force magnitude for each body pair.
"
Class {
	#name : 'CFPhysicsManyBodyRepulsionForce',
	#superclass : 'CFPhysicsBodyForce',
	#instVars : [ 'distanceResponse' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsManyBodyRepulsionForce >> initialize [
	super initialize.
	distanceResponse := CFPhysicsConstantForceResponse new
]

{ #category : 'configuration' }
CFPhysicsManyBodyRepulsionForce >> distanceResponse [
	^ distanceResponse
]

{ #category : 'configuration' }
CFPhysicsManyBodyRepulsionForce >> distanceResponse: aDistanceResponse [
	distanceResponse := aDistanceResponse
]

{ #category : 'configuration' }
CFPhysicsManyBodyRepulsionForce >> force [
	^ distanceResponse force
]

{ #category : 'configuration' }
CFPhysicsManyBodyRepulsionForce >> force: aNumber [
	distanceResponse force: aNumber
]

{ #category : 'configuration' }
CFPhysicsManyBodyRepulsionForce >> maximumDistance [
	^ distanceResponse maximumDistance
]

{ #category : 'configuration' }
CFPhysicsManyBodyRepulsionForce >> maximumDistance: aNumber [
	distanceResponse maximumDistance: aNumber
]

{ #category : 'stepping' }
CFPhysicsManyBodyRepulsionForce >> applyForStep: seconds [
	1 to: bodies size do: [ :firstIndex |
		firstIndex + 1 to: bodies size do: [ :secondIndex |
			self
				applyBetween: (bodies at: firstIndex)
				and: (bodies at: secondIndex) ] ]
]

{ #category : 'private - stepping' }
CFPhysicsManyBodyRepulsionForce >> applyBetween: firstBody and: secondBody [
	| firstCentre secondCentre displacement distance magnitude direction force |
	firstCentre := firstBody position + (firstBody extent / 2.0).
	secondCentre := secondBody position + (secondBody extent / 2.0).
	displacement := secondCentre - firstCentre.
	distance := displacement r.
	distance = 0 ifTrue: [ ^ self ].
	magnitude := distanceResponse forceMagnitudeAtDistance: distance.
	magnitude = 0 ifTrue: [ ^ self ].
	direction := displacement / distance.
	force := direction * magnitude.
	self applyForce: force negated to: firstBody.
	self applyForce: force to: secondBody
]
