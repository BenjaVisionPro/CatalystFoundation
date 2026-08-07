"
I represent a uniform force applied to selected Physics bodies.
"
Class {
	#name : 'CFPhysicsWindForce',
	#superclass : 'CFPhysicsBodyForce',
	#instVars : [ 'force' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsWindForce >> initialize [
	super initialize.
	force := 0 @ 0
]

{ #category : 'accessing' }
CFPhysicsWindForce >> force [
	^ force
]

{ #category : 'accessing' }
CFPhysicsWindForce >> force: aPoint [
	force := aPoint
]

{ #category : 'stepping' }
CFPhysicsWindForce >> applyForStep: seconds [
	force = (0 @ 0) ifTrue: [ ^ self ].
	bodies do: [ :body | self applyForce: force to: body ]
]
