"
I attract selected Physics bodies toward a configured world point.

Each body receives its own restoring force based on its displacement from that point.
"
Class {
	#name : 'CFPhysicsPointAttractionForce',
	#superclass : 'CFPhysicsBodyForce',
	#instVars : [ 'point', 'stiffness' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsPointAttractionForce >> initialize [
	super initialize.
	point := 0 @ 0.
	stiffness := 1.0
]

{ #category : 'accessing' }
CFPhysicsPointAttractionForce >> point [
	^ point
]

{ #category : 'accessing' }
CFPhysicsPointAttractionForce >> point: aPoint [
	point = aPoint ifTrue: [ ^ self ].
	point := aPoint.
	self configurationChanged
]

{ #category : 'accessing' }
CFPhysicsPointAttractionForce >> stiffness [
	^ stiffness
]

{ #category : 'accessing' }
CFPhysicsPointAttractionForce >> stiffness: aNumber [
	| newStiffness |
	"Spring stiffness in newtons per metre."
	newStiffness := aNumber asFloat max: 0.0.
	stiffness = newStiffness ifTrue: [ ^ self ].
	stiffness := newStiffness.
	self configurationChanged
]

{ #category : 'stepping' }
CFPhysicsPointAttractionForce >> applyForStep: seconds [
	stiffness isZero ifTrue: [ ^ self ].
	bodies do: [ :body |
		| bodyCentre displacementMetres force |
		bodyCentre := body position + (body extent / 2.0).
		displacementMetres := (point - bodyCentre) / self lengthUnitsPerMetre.
		force := displacementMetres * stiffness.
		force = (0 @ 0) ifFalse: [ self applyForce: force to: body ] ]
]
