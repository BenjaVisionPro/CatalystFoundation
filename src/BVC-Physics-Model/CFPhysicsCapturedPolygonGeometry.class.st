
"
I am captured convex polygon geometry.

I follow the Box2D polygon model: no more than eight vertices and an optional external rounding radius.
"
Class {
	#name : 'CFPhysicsCapturedPolygonGeometry',
	#superclass : 'CFPhysicsCapturedGeometry',
	#instVars : [ 'vertices', 'radius', 'rotationCentre' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsCapturedPolygonGeometry class >> vertices: aCollection radius: aRadius rotationCentre: aPoint [
	^ self new
		vertices: aCollection;
		radius: aRadius;
		rotationCentre: aPoint;
		validate;
		yourself
]

{ #category : 'testing' }
CFPhysicsCapturedPolygonGeometry >> isPolygon [
	^ true
]

{ #category : 'testing' }
CFPhysicsCapturedPolygonGeometry >> isRounded [
	^ radius > 0.0
]

{ #category : 'accessing' }
CFPhysicsCapturedPolygonGeometry >> radius [
	^ radius
]

{ #category : 'accessing' }
CFPhysicsCapturedPolygonGeometry >> radius: aNumber [
	radius := aNumber asFloat
]

{ #category : 'accessing' }
CFPhysicsCapturedPolygonGeometry >> rotationCentre [
	^ rotationCentre
]

{ #category : 'accessing' }
CFPhysicsCapturedPolygonGeometry >> rotationCentre: aPoint [
	rotationCentre := aPoint
]

{ #category : 'validating' }
CFPhysicsCapturedPolygonGeometry >> validate [
	vertices size < 3 ifTrue: [ self error: 'A Physics polygon requires at least three vertices' ].
	vertices size > 8 ifTrue: [ self error: 'A Physics polygon may contain at most eight vertices, matching Box2D' ]
]

{ #category : 'accessing' }
CFPhysicsCapturedPolygonGeometry >> vertices [
	^ vertices
]

{ #category : 'accessing' }
CFPhysicsCapturedPolygonGeometry >> vertices: aCollection [
	vertices := aCollection asArray copy
]
