Class {
	#name : 'CFPhysicsBodyState',
	#superclass : 'Object',
	#instVars : [ 'element', 'world', 'position', 'rotation', 'presentation', 'velocity', 'dynamic', 'sequence', 'shapeState', 'contacts' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsBodyState class >> element: anElement world: aWorld [
	^ self new
		element: anElement;
		world: aWorld;
		yourself
]

{ #category : 'stepping' }
CFPhysicsBodyState >> advanceBy: seconds gravity: gravityVector [
	dynamic ifFalse: [ ^ self ].
	velocity := velocity + (gravityVector * seconds).
	position := position + (velocity * seconds)
]


{ #category : 'velocity' }
CFPhysicsBodyState >> addVelocity: aPoint [
	dynamic ifTrue: [ velocity := velocity + aPoint ]
]


{ #category : 'contacts' }
CFPhysicsBodyState >> addContact: aContact [
	contacts ifNil: [ contacts := IdentitySet new ].
	contacts add: aContact
]

{ #category : 'contacts' }
CFPhysicsBodyState >> contacts [
	contacts ifNil: [ contacts := IdentitySet new ].
	^ contacts asArray
]

{ #category : 'contacts' }
CFPhysicsBodyState >> removeContact: aContact [
	contacts ifNil: [ ^ self ].
	contacts remove: aContact ifAbsent: [ ]
]

{ #category : 'collision' }
CFPhysicsBodyState >> aabb [
	^ self shapeState aabbAt: position
]

{ #category : 'body type' }
CFPhysicsBodyState >> beDynamic [
	dynamic := true
]

{ #category : 'body type' }
CFPhysicsBodyState >> beStatic [
	dynamic := false.
	velocity := 0 @ 0
]

{ #category : 'accessing' }
CFPhysicsBodyState >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsBodyState >> element: anElement [
	element := anElement.
	presentation := CFPhysicsPresentation on: anElement.
	shapeState := CFPhysicsShapeState on: anElement
]


{ #category : 'geometry' }
CFPhysicsBodyState >> extent [
	^ element extent
]

{ #category : 'mass' }
CFPhysicsBodyState >> inverseMass [
	| area mass |
	dynamic ifFalse: [ ^ 0.0 ].
	area := self shapeState isCircle
		ifTrue: [ Float pi * self shapeState radius squared ]
		ifFalse: [ self shapeState extent x * self shapeState extent y ].
	mass := area * self shapeState material density.
	^ mass > 0 ifTrue: [ 1.0 / mass ] ifFalse: [ 0.0 ]
]

{ #category : 'material' }
CFPhysicsBodyState >> friction [
	^ self shapeState material friction
]

{ #category : 'material' }
CFPhysicsBodyState >> friction: aNumber [
	self shapeState material friction: aNumber
]

{ #category : 'material' }
CFPhysicsBodyState >> restitution [
	^ self shapeState material restitution
]

{ #category : 'material' }
CFPhysicsBodyState >> restitution: aNumber [
	self shapeState material restitution: aNumber
]

{ #category : 'material' }
CFPhysicsBodyState >> density [
	^ self shapeState material density
]

{ #category : 'material' }
CFPhysicsBodyState >> density: aNumber [
	self shapeState material density: aNumber
]

{ #category : 'initialization' }
CFPhysicsBodyState >> initialize [
	super initialize.
	position := 0 @ 0.
	rotation := 0.
	velocity := 0 @ 0.
	dynamic := true.
	contacts := IdentitySet new
]

{ #category : 'body type' }
CFPhysicsBodyState >> isDynamic [
	^ dynamic
]

{ #category : 'body type' }
CFPhysicsBodyState >> isStatic [
	^ dynamic not
]

{ #category : 'presenting' }
CFPhysicsBodyState >> present [
	presentation presentTranslation: position rotation: rotation
]

{ #category : 'accessing' }
CFPhysicsBodyState >> position [
	^ position
]

{ #category : 'accessing' }
CFPhysicsBodyState >> position: aPoint [
	position := aPoint.
	self present
]

{ #category : 'accessing' }
CFPhysicsBodyState >> presentation [
	^ presentation
]

{ #category : 'controlling' }
CFPhysicsBodyState >> release [
	presentation release
]

{ #category : 'accessing' }
CFPhysicsBodyState >> rotation [
	^ rotation
]

{ #category : 'accessing' }
CFPhysicsBodyState >> rotation: aNumber [
	rotation := aNumber.
	self present
]



{ #category : 'geometry' }
CFPhysicsBodyState >> shapeState [
	shapeState ifNil: [ shapeState := CFPhysicsShapeState on: element ].
	^ shapeState
]

{ #category : 'ordering' }
CFPhysicsBodyState >> sequence [
	^ sequence
]


{ #category : 'ordering' }
CFPhysicsBodyState >> sequence: anInteger [
	sequence := anInteger
]

{ #category : 'collision' }
CFPhysicsBodyState >> translateBy: aPoint [
	position := position + aPoint
]

{ #category : 'presenting' }
CFPhysicsBodyState >> translation: aPoint rotation: aNumber [
	position := aPoint.
	rotation := aNumber.
	self present
]

{ #category : 'accessing' }
CFPhysicsBodyState >> velocity [
	^ velocity
]

{ #category : 'accessing' }
CFPhysicsBodyState >> velocity: aPoint [
	velocity := dynamic
		ifTrue: [ aPoint ]
		ifFalse: [ 0 @ 0 ]
]

{ #category : 'accessing' }
CFPhysicsBodyState >> world [
	^ world
]

{ #category : 'accessing' }
CFPhysicsBodyState >> world: aWorld [
	world := aWorld
]
