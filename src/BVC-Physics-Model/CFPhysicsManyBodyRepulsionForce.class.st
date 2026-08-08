"
I repel each selected Physics body from every other selected body.

My distance response maps separation in metres to repulsive force magnitude in newtons.
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
	distanceResponse == aDistanceResponse ifTrue: [ ^ self ].
	distanceResponse := aDistanceResponse.
	self configurationChanged
]

{ #category : 'configuration' }
CFPhysicsManyBodyRepulsionForce >> force [
	^ distanceResponse force
]

{ #category : 'configuration' }
CFPhysicsManyBodyRepulsionForce >> force: aNumber [
	| oldForce newForce |
	oldForce := distanceResponse force value asFloat.
	distanceResponse force: aNumber.
	newForce := distanceResponse force value asFloat.
	oldForce = newForce ifFalse: [ self configurationChanged ]
]

{ #category : 'configuration' }
CFPhysicsManyBodyRepulsionForce >> maximumDistance [
	^ distanceResponse maximumDistance
]

{ #category : 'configuration' }
CFPhysicsManyBodyRepulsionForce >> maximumDistance: aNumber [
	| oldMaximum newMaximum |
	oldMaximum := distanceResponse maximumDistance ifNotNil: [ :value | value value asFloat ].
	distanceResponse maximumDistance: aNumber.
	newMaximum := distanceResponse maximumDistance ifNotNil: [ :value | value value asFloat ].
	oldMaximum = newMaximum ifFalse: [ self configurationChanged ]
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
	| firstCentre secondCentre displacement distance distanceMetres magnitude direction force |
	firstCentre := firstBody position + (firstBody extent / 2.0).
	secondCentre := secondBody position + (secondBody extent / 2.0).
	displacement := secondCentre - firstCentre.
	distance := displacement r.
	distance = 0 ifTrue: [ ^ self ].
	distanceMetres := self metresForLengthUnits: distance.
	magnitude := distanceResponse forceMagnitudeAtDistance: distanceMetres.
	magnitude = 0 ifTrue: [ ^ self ].
	direction := displacement / distance.
	force := direction * magnitude.
	self applyForce: force negated to: firstBody.
	self applyForce: force to: secondBody
]
