"
I own the ordered collision shapes attached to a Physics body.

The current body integration installs one primary shape state. The ordered collection is the ownership seam for Box2D-style bodies with multiple shapes, including chain segment shapes.
"
Class {
	#name : 'CFPhysicsShapeCollection',
	#superclass : 'Object',
	#instVars : [ 'shapes' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsShapeCollection class >> with: aShape [
	^ self new
		add: aShape;
		yourself
]

{ #category : 'adding' }
CFPhysicsShapeCollection >> add: aShape [
	shapes add: aShape.
	^ aShape
]

{ #category : 'enumerating' }
CFPhysicsShapeCollection >> do: aBlock [
	shapes do: aBlock
]

{ #category : 'initialization' }
CFPhysicsShapeCollection >> initialize [
	super initialize.
	shapes := OrderedCollection new
]

{ #category : 'testing' }
CFPhysicsShapeCollection >> isEmpty [
	^ shapes isEmpty
]

{ #category : 'accessing' }
CFPhysicsShapeCollection >> primaryShape [
	^ shapes first
]

{ #category : 'accessing' }
CFPhysicsShapeCollection >> shapes [
	^ shapes asArray
]

{ #category : 'accessing' }
CFPhysicsShapeCollection >> size [
	^ shapes size
]
