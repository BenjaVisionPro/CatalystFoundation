"
I describe a convex shape translated through the dynamic tree.

My points and radius are expressed in physics length units. My translation is expressed in physics length units for the complete cast. maximumFraction selects how much of that translation is considered. canEncroach is retained because it is part of the Box2D 3.1.1 shape-cast input contract; dynamic-tree traversal itself does not interpret it.
"
Class {
	#name : 'CFPhysicsShapeCastInput',
	#superclass : 'Object',
	#instVars : [ 'points', 'radius', 'translation', 'maximumFraction', 'canEncroach' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsShapeCastInput >> initialize [
	super initialize.
	points := #().
	radius := 0.0.
	translation := 0 @ 0.
	maximumFraction := 1.0.
	canEncroach := false
]

{ #category : 'accessing' }
CFPhysicsShapeCastInput >> points [
	^ points
]

{ #category : 'accessing' }
CFPhysicsShapeCastInput >> points: aCollection [
	points := aCollection asArray
]

{ #category : 'accessing' }
CFPhysicsShapeCastInput >> radius [
	^ radius
]

{ #category : 'accessing' }
CFPhysicsShapeCastInput >> radius: aNumber [
	radius := aNumber asFloat
]

{ #category : 'accessing' }
CFPhysicsShapeCastInput >> translation [
	^ translation
]

{ #category : 'accessing' }
CFPhysicsShapeCastInput >> translation: aPoint [
	translation := aPoint
]

{ #category : 'accessing' }
CFPhysicsShapeCastInput >> maximumFraction [
	^ maximumFraction
]

{ #category : 'accessing' }
CFPhysicsShapeCastInput >> maximumFraction: aNumber [
	maximumFraction := aNumber asFloat
]

{ #category : 'accessing' }
CFPhysicsShapeCastInput >> canEncroach [
	^ canEncroach
]

{ #category : 'accessing' }
CFPhysicsShapeCastInput >> canEncroach: aBoolean [
	canEncroach := aBoolean
]

{ #category : 'copying' }
CFPhysicsShapeCastInput >> withMaximumFraction: aNumber [
	^ self shallowCopy
		maximumFraction: aNumber;
		yourself
]
