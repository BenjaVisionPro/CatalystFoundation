"
I keep the geometric centre of selected Physics bodies near a configured world point.

I apply one uniform force derived from the offset between the current group centre and the configured centre.
"
Class {
	#name : 'CFPhysicsCentreForce',
	#superclass : 'CFPhysicsBodyForce',
	#instVars : [ 'centre', 'strength' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsCentreForce >> initialize [
	super initialize.
	centre := 0 @ 0.
	strength := 1.0
]

{ #category : 'accessing' }
CFPhysicsCentreForce >> centre [
	^ centre
]

{ #category : 'accessing' }
CFPhysicsCentreForce >> centre: aPoint [
	centre := aPoint
]

{ #category : 'accessing' }
CFPhysicsCentreForce >> strength [
	^ strength
]

{ #category : 'accessing' }
CFPhysicsCentreForce >> strength: aNumber [
	strength := aNumber asFloat max: 0.0
]

{ #category : 'stepping' }
CFPhysicsCentreForce >> applyForStep: seconds [
	| currentCentre force |
	(bodies isEmpty or: [ strength isZero ]) ifTrue: [ ^ self ].
	currentCentre := bodies
		inject: 0 @ 0
		into: [ :sum :body | sum + body position + (body extent / 2.0) ].
	currentCentre := currentCentre / bodies size.
	force := (centre - currentCentre) * strength.
	force = (0 @ 0) ifTrue: [ ^ self ].
	bodies do: [ :body | self applyForce: force to: body ]
]
