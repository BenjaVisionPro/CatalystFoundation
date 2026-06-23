Class {
	#name : 'CFRubberBandMotion',
	#superclass : 'Object',
	#instVars : [
		'projectionPlane',
		'logicalPosition',
		'logicalVelocity'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'projection configuration' }
CFRubberBandMotion >> horizontal [
	"Answer the horizontal axis configuration, creating the projection plane and axis on first use."

	^ self projectionPlane horizontal
]

{ #category : 'initialization' }
CFRubberBandMotion >> initialize [
	super initialize.
	logicalPosition := 0 @ 0.
	logicalVelocity := 0 @ 0
]

{ #category : 'testing' }
CFRubberBandMotion >> hasProjectionPlane [
	^ projectionPlane notNil
]

{ #category : 'testing' }
CFRubberBandMotion >> isInBounds [
	^ projectionPlane
		ifNil: [ true ]
		ifNotNil: [ projectionPlane isInBounds: logicalPosition ]
]

{ #category : 'testing' }
CFRubberBandMotion >> isOutOfBounds [
	^ self isInBounds not
]

{ #category : 'accessing' }
CFRubberBandMotion >> logicalPosition [
	^ logicalPosition
]

{ #category : 'accessing' }
CFRubberBandMotion >> logicalPosition: aPoint [
	self moveTo: aPoint
]

{ #category : 'accessing' }
CFRubberBandMotion >> logicalVelocity [
	^ logicalVelocity
]

{ #category : 'accessing' }
CFRubberBandMotion >> logicalVelocity: aPoint [
	logicalVelocity := aPoint
]

{ #category : 'movement' }
CFRubberBandMotion >> moveBy: aDeltaPoint [
	^ self moveTo: logicalPosition + aDeltaPoint
]

{ #category : 'movement' }
CFRubberBandMotion >> moveTo: aPoint [
	logicalPosition := projectionPlane
		ifNil: [ aPoint ]
		ifNotNil: [ projectionPlane limitedPointFor: aPoint ].
	^ self
]

{ #category : 'overscroll' }
CFRubberBandMotion >> overscrollDistance [
	^ projectionPlane
		ifNil: [ 0 @ 0 ]
		ifNotNil: [ projectionPlane overscrollDistanceFor: logicalPosition ]
]

{ #category : 'printing' }
CFRubberBandMotion >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(logicalPosition: ';
		nextPutAll: logicalPosition asString;
		nextPutAll: ', logicalVelocity: ';
		nextPutAll: logicalVelocity asString;
		nextPut: $)
]

{ #category : 'projection' }
CFRubberBandMotion >> projectedOverscrollDistance [
	^ projectionPlane
		ifNil: [ 0 @ 0 ]
		ifNotNil: [ projectionPlane projectedOverscrollDistanceFor: logicalPosition ]
]

{ #category : 'projection' }
CFRubberBandMotion >> projectedPosition [
	^ projectionPlane
		ifNil: [ logicalPosition ]
		ifNotNil: [ projectionPlane project: logicalPosition ]
]

{ #category : 'velocity' }
CFRubberBandMotion >> projectedVelocity [
	^ projectionPlane
		ifNil: [ logicalVelocity ]
		ifNotNil: [ projectionPlane projectedVelocityFor: logicalVelocity at: logicalPosition ]
]

{ #category : 'accessing' }
CFRubberBandMotion >> projectionPlane [
	"Answer the projection plane, creating it on first use."

	projectionPlane ifNil: [ projectionPlane := CFRubberBandProjectionPlane new ].
	^ projectionPlane
]

{ #category : 'accessing' }
CFRubberBandMotion >> projectionPlane: aProjectionPlane [
	projectionPlane := aProjectionPlane
]

{ #category : 'release' }
CFRubberBandMotion >> releaseTargetPosition [
	^ projectionPlane
		ifNil: [ logicalPosition ]
		ifNotNil: [ projectionPlane nearestBoundFor: logicalPosition ]
]

{ #category : 'release' }
CFRubberBandMotion >> snapToBounds [
	logicalPosition := self releaseTargetPosition.
	logicalVelocity := 0 @ 0.
	^ self
]

{ #category : 'overscroll' }
CFRubberBandMotion >> signedOverscrollDistance [
	^ projectionPlane
		ifNil: [ 0 @ 0 ]
		ifNotNil: [ projectionPlane signedOverscrollDistanceFor: logicalPosition ]
]

{ #category : 'projection' }
CFRubberBandMotion >> signedProjectedOverscrollDistance [
	^ projectionPlane
		ifNil: [ 0 @ 0 ]
		ifNotNil: [ projectionPlane signedProjectedOverscrollDistanceFor: logicalPosition ]
]

{ #category : 'velocity' }
CFRubberBandMotion >> velocityScale [
	^ projectionPlane
		ifNil: [ 1 @ 1 ]
		ifNotNil: [ projectionPlane velocityScaleAt: logicalPosition ]
]

{ #category : 'projection configuration' }
CFRubberBandMotion >> vertical [
	"Answer the vertical axis configuration, creating the projection plane and axis on first use."

	^ self projectionPlane vertical
]
