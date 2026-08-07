"
I keep the geometric centre of selected Physics bodies near a configured world point.

I apply one uniform force derived from the offset between the current group centre and the configured centre.
"
Class {
	#name : 'CFPhysicsCentreForce',
	#superclass : 'CFPhysicsBodyForce',
	#instVars : [ 'centre', 'stiffness' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsCentreForce >> initialize [
	super initialize.
	centre := 0 @ 0.
	stiffness := 1.0
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
CFPhysicsCentreForce >> stiffness [
	^ stiffness
]

{ #category : 'accessing' }
CFPhysicsCentreForce >> stiffness: aNumber [
	"Spring stiffness in newtons per metre."
	stiffness := aNumber asFloat max: 0.0
]

{ #category : 'stepping' }
CFPhysicsCentreForce >> applyForStep: seconds [
	| currentCentre displacementMetres force |
	(bodies isEmpty or: [ stiffness isZero ]) ifTrue: [ ^ self ].
	currentCentre := bodies
		inject: 0 @ 0
		into: [ :sum :body | sum + body position + (body extent / 2.0) ].
	currentCentre := currentCentre / bodies size.
	displacementMetres := (centre - currentCentre) / self lengthUnitsPerMetre.
	force := displacementMetres * stiffness.
	force = (0 @ 0) ifTrue: [ ^ self ].
	bodies do: [ :body | self applyForce: force to: body ]
]
