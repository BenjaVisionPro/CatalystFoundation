"
I apply tangential force around a configured world point.

My distance response maps each body's distance in metres to tangential force magnitude in newtons.
"
Class {
	#name : 'CFPhysicsVortexForce',
	#superclass : 'CFPhysicsBodyForce',
	#instVars : [ 'centre', 'distanceResponse' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsVortexForce >> initialize [
	super initialize.
	centre := 0 @ 0.
	distanceResponse := CFPhysicsConstantForceResponse new
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> centre [
	^ centre
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> centre: aPoint [
	centre = aPoint ifTrue: [ ^ self ].
	centre := aPoint.
	self configurationChanged
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> distanceResponse [
	^ distanceResponse
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> distanceResponse: aDistanceResponse [
	distanceResponse == aDistanceResponse ifTrue: [ ^ self ].
	distanceResponse := aDistanceResponse.
	self configurationChanged
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> force [
	^ distanceResponse force
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> force: aNumber [
	| oldForce newForce |
	oldForce := distanceResponse force value asFloat.
	distanceResponse force: aNumber.
	newForce := distanceResponse force value asFloat.
	oldForce = newForce ifFalse: [ self configurationChanged ]
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> maximumDistance [
	^ distanceResponse maximumDistance
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> maximumDistance: aNumber [
	| oldMaximum newMaximum |
	oldMaximum := distanceResponse maximumDistance ifNotNil: [ :value | value value asFloat ].
	distanceResponse maximumDistance: aNumber.
	newMaximum := distanceResponse maximumDistance ifNotNil: [ :value | value value asFloat ].
	oldMaximum = newMaximum ifFalse: [ self configurationChanged ]
]

{ #category : 'stepping' }
CFPhysicsVortexForce >> applyForStep: seconds [
	bodies do: [ :body |
		| displacement distance distanceMetres magnitude tangent |
		displacement := body position + (body extent / 2.0) - centre.
		distance := displacement r.
		distance > 0 ifTrue: [
			distanceMetres := self metresForLengthUnits: distance.
			magnitude := distanceResponse forceMagnitudeAtDistance: distanceMetres.
			magnitude > 0 ifTrue: [
				tangent := displacement y negated @ displacement x.
				self applyForce: tangent / distance * magnitude to: body ] ] ]
]
