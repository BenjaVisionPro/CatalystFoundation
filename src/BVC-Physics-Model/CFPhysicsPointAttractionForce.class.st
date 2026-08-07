"
I attract selected Physics bodies toward a configured world point.

Each body receives its own restoring force based on its displacement from that point.
"
Class {
	#name : 'CFPhysicsPointAttractionForce',
	#superclass : 'CFPhysicsBodyForce',
	#instVars : [ 'point', 'strength' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsPointAttractionForce >> initialize [
	super initialize.
	point := 0 @ 0.
	strength := 1.0
]

{ #category : 'accessing' }
CFPhysicsPointAttractionForce >> point [
	^ point
]

{ #category : 'accessing' }
CFPhysicsPointAttractionForce >> point: aPoint [
	point := aPoint
]

{ #category : 'accessing' }
CFPhysicsPointAttractionForce >> strength [
	^ strength
]

{ #category : 'accessing' }
CFPhysicsPointAttractionForce >> strength: aNumber [
	strength := aNumber asFloat max: 0.0
]

{ #category : 'stepping' }
CFPhysicsPointAttractionForce >> applyForStep: seconds [
	strength isZero ifTrue: [ ^ self ].
	bodies do: [ :body |
		| bodyCentre force |
		bodyCentre := body position + (body extent / 2.0).
		force := (point - bodyCentre) * strength.
		force = (0 @ 0) ifFalse: [ body applyForce: force ] ]
]
