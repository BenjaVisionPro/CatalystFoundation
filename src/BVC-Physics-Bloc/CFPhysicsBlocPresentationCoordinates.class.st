Class {
	#name : 'CFPhysicsBlocPresentationCoordinates',
	#superclass : 'Object',
	#category : 'BVC-Physics-Bloc',
	#package : 'BVC-Physics-Bloc'
}

{ #category : 'converting' }
CFPhysicsBlocPresentationCoordinates class >> globalPointForWorldPoint: aPoint inWorld: aWorld [
	"Physics world coordinates are expressed in the world's owner's children
	coordinate system. Cross that boundary through Bloc rather than treating the
	point as owner-local geometry."
	^ aWorld owner
		localPointToGlobal: (aWorld owner childrenPointToLocal: aPoint)
]

{ #category : 'converting' }
CFPhysicsBlocPresentationCoordinates class >> globalPointForWorldPoint: aPoint attachedTo: aBody inWorld: aWorld [
	"Ordinary body-attached points follow the body's currently presented Bloc
	transformation, including Motion interpolation. Containment geometry is
	expressed directly in the world's owner-children coordinate system."
	| bodyLocalPoint elementLocalPoint |
	aBody ifNil: [
		^ self globalPointForWorldPoint: aPoint inWorld: aWorld ].
	aBody == aWorld containmentBoundaryBody ifTrue: [
		^ self globalPointForWorldPoint: aPoint inWorld: aWorld ].
	bodyLocalPoint := aBody bodyLocalPointForWorldPoint: aPoint.
	elementLocalPoint := aBody shapeState
		elementLocalPointForBodyLocalPoint: bodyLocalPoint.
	^ aBody element localPointToGlobal: elementLocalPoint
]
