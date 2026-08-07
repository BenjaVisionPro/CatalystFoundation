"
I apply tangential force around a configured world point.

My distance response determines the force magnitude at each body's distance from the vortex centre.
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
	centre := aPoint
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> distanceResponse [
	^ distanceResponse
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> distanceResponse: aDistanceResponse [
	distanceResponse := aDistanceResponse
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> force [
	^ distanceResponse force
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> force: aNumber [
	distanceResponse force: aNumber
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> maximumDistance [
	^ distanceResponse maximumDistance
]

{ #category : 'accessing' }
CFPhysicsVortexForce >> maximumDistance: aNumber [
	distanceResponse maximumDistance: aNumber
]

{ #category : 'stepping' }
CFPhysicsVortexForce >> applyForStep: seconds [
	bodies do: [ :body |
		| displacement distance magnitude tangent |
		displacement := body position + (body extent / 2.0) - centre.
		distance := displacement r.
		distance > 0 ifTrue: [
			magnitude := distanceResponse forceMagnitudeAtDistance: distance.
			magnitude > 0 ifTrue: [
				tangent := displacement y negated @ displacement x.
				self applyForce: tangent / distance * magnitude to: body ] ] ]
]
