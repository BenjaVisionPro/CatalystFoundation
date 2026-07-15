Class {
	#name : 'CFMotionGeometrySnapshot',
	#superclass : 'Object',
	#instVars : [ 'element', 'coordinateSpace', 'bounds', 'parent' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionGeometrySnapshot class >> of: anElement in: aCoordinateSpace [
	| mutableBounds |
	anElement isAttachedToSceneGraph ifFalse: [
		self error: 'A geometry subject must be attached to a BlSpace' ].
	aCoordinateSpace isAttachedToSceneGraph ifFalse: [
		self error: 'A geometry coordinate space must be attached to a BlSpace' ].
	anElement space == aCoordinateSpace space ifFalse: [
		self error: 'A geometry subject and coordinate space must share a BlSpace' ].
	mutableBounds := BlBounds fromRectangle: anElement boundsInSpace.
	aCoordinateSpace globalBoundsToLocal: mutableBounds.
	^ self new
		element: anElement;
		coordinateSpace: aCoordinateSpace;
		bounds: mutableBounds asRectangle;
		parent: (anElement hasParent ifTrue: [ anElement parent ]);
		yourself
]

{ #category : 'accessing' }
CFMotionGeometrySnapshot >> bounds [ ^ bounds ]

{ #category : 'accessing' }
CFMotionGeometrySnapshot >> bounds: aRectangle [ bounds := aRectangle ]

{ #category : 'accessing' }
CFMotionGeometrySnapshot >> coordinateSpace [ ^ coordinateSpace ]

{ #category : 'accessing' }
CFMotionGeometrySnapshot >> coordinateSpace: anElement [ coordinateSpace := anElement ]

{ #category : 'accessing' }
CFMotionGeometrySnapshot >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionGeometrySnapshot >> element: anElement [ element := anElement ]

{ #category : 'accessing' }
CFMotionGeometrySnapshot >> parent [ ^ parent ]

{ #category : 'accessing' }
CFMotionGeometrySnapshot >> parent: anElement [ parent := anElement ]

{ #category : 'testing' }
CFMotionGeometrySnapshot >> isValid [
	^ element isAttachedToSceneGraph
		and: [ coordinateSpace isAttachedToSceneGraph
			and: [ element space == coordinateSpace space ] ]
]
