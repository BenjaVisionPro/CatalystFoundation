"
I configure and apply containment for a Physics world.

I am enabled by default. My material describes the static boundary surface that will be used by the Box2D-shaped chain implementation. Until that chain is installed, I preserve the existing correction behaviour through the same world-owned API.
"
Class {
	#name : 'CFPhysicsWorldContainment',
	#superclass : 'Object',
	#instVars : [ 'enabled', 'margin', 'material' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsWorldContainment >> initialize [
	super initialize.
	enabled := true.
	margin := 0.0.
	material := CFPhysicsMaterial new
]

{ #category : 'controlling' }
CFPhysicsWorldContainment >> enable [
	enabled := true.
	^ self
]

{ #category : 'controlling' }
CFPhysicsWorldContainment >> disable [
	enabled := false.
	^ self
]

{ #category : 'testing' }
CFPhysicsWorldContainment >> isEnabled [
	^ enabled
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> margin [
	^ margin
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> margin: aNumber [
	margin := aNumber asFloat max: 0.0
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> material [
	^ material
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> friction [
	^ material friction
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> friction: aNumber [
	material friction: aNumber
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> restitution [
	^ material restitution
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> restitution: aNumber [
	material restitution: ((aNumber asFloat max: 0.0) min: 1.0)
]

{ #category : 'private - applying' }
CFPhysicsWorldContainment >> applyToBodies: bodyStates bounds: aRectangle [
	(enabled and: [
		aRectangle extent x > 0 and: [ aRectangle extent y > 0 ] ]) ifFalse: [ ^ self ].
	bodyStates do: [ :each |
		each isDynamic ifTrue: [
			CFPhysicsContainmentConstraint
				applyTo: each
				bounds: aRectangle
				margin: margin
				restitution: material restitution ] ]
]
