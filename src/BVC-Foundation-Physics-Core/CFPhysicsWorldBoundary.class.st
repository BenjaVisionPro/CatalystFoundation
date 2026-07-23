"
I configure the default boundary applied by a Physics world to its dynamic member bodies.

World containment is enabled by default. Individual CFPhysicsContainmentConstraints remain available when one body needs a different margin or restitution.
"
Class {
	#name : 'CFPhysicsWorldBoundary',
	#superclass : 'Object',
	#instVars : [ 'enabled', 'margin', 'restitution' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsWorldBoundary >> initialize [
	super initialize.
	enabled := true.
	margin := 0.0.
	restitution := 0.0
]

{ #category : 'accessing' }
CFPhysicsWorldBoundary >> enabled [
	^ enabled
]

{ #category : 'accessing' }
CFPhysicsWorldBoundary >> enabled: aBoolean [
	enabled := aBoolean = true
]

{ #category : 'configuration' }
CFPhysicsWorldBoundary >> margin [
	^ margin
]

{ #category : 'configuration' }
CFPhysicsWorldBoundary >> margin: aNumber [
	margin := aNumber asFloat max: 0.0
]

{ #category : 'configuration' }
CFPhysicsWorldBoundary >> restitution [
	^ restitution
]

{ #category : 'configuration' }
CFPhysicsWorldBoundary >> restitution: aNumber [
	restitution := (aNumber asFloat max: 0.0) min: 1.0
]

{ #category : 'applying' }
CFPhysicsWorldBoundary >> applyTo: aBodyState bounds: aRectangle [
	(enabled and: [
		aBodyState isDynamic and: [
			aRectangle extent x > 0 and: [ aRectangle extent y > 0 ] ] ]) ifFalse: [ ^ self ].
	CFPhysicsContainmentConstraint
		applyTo: aBodyState
		bounds: aRectangle
		margin: margin
		restitution: restitution
]
