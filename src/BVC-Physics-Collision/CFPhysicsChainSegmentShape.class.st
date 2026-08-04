"
I represent one Box2D-style chain segment with adjacent ghost vertices.

My points are local to the static body that owns my parent chain. My segment index is stable within that chain.
"
Class {
	#name : 'CFPhysicsChainSegmentShape',
	#superclass : 'Object',
	#instVars : [ 'ghost1', 'point1', 'point2', 'ghost2', 'chain', 'segmentIndex' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsChainSegmentShape class >> ghost1: firstGhost point1: firstPoint point2: secondPoint ghost2: secondGhost chain: aChain segmentIndex: anInteger [
	^ self new
		ghost1: firstGhost;
		point1: firstPoint;
		point2: secondPoint;
		ghost2: secondGhost;
		chain: aChain;
		segmentIndex: anInteger;
		yourself
]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> chain [ ^ chain ]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> chain: aChain [ chain := aChain ]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> ghost1 [ ^ ghost1 ]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> ghost1: aPoint [ ghost1 := aPoint ]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> ghost2 [ ^ ghost2 ]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> ghost2: aPoint [ ghost2 := aPoint ]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> point1 [ ^ point1 ]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> point1: aPoint [ point1 := aPoint ]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> point2 [ ^ point2 ]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> point2: aPoint [ point2 := aPoint ]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> segmentIndex [ ^ segmentIndex ]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> segmentIndex: anInteger [ segmentIndex := anInteger ]


{ #category : 'testing' }
CFPhysicsChainSegmentShape >> isChainSegment [
	^ true
]

{ #category : 'accessing' }
CFPhysicsChainSegmentShape >> body [
	^ chain body
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> localAABB [
	| minimum maximum |
	minimum := (point1 x min: point2 x) @ (point1 y min: point2 y).
	maximum := (point1 x max: point2 x) @ (point1 y max: point2 y).
	^ CFPhysicsAABB position: minimum extent: maximum - minimum
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> worldPoint1AtBodyOrigin: bodyOrigin rotation: rotation [
	^ bodyOrigin + (self rotateVector: point1 by: rotation)
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> worldPoint2AtBodyOrigin: bodyOrigin rotation: rotation [
	^ bodyOrigin + (self rotateVector: point2 by: rotation)
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> worldGhost1AtBodyOrigin: bodyOrigin rotation: rotation [
	^ bodyOrigin + (self rotateVector: ghost1 by: rotation)
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> worldGhost2AtBodyOrigin: bodyOrigin rotation: rotation [
	^ bodyOrigin + (self rotateVector: ghost2 by: rotation)
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> aabbAtBodyOrigin: bodyOrigin rotation: rotation [
	| first second minimum maximum |
	first := self worldPoint1AtBodyOrigin: bodyOrigin rotation: rotation.
	second := self worldPoint2AtBodyOrigin: bodyOrigin rotation: rotation.
	minimum := (first x min: second x) @ (first y min: second y).
	maximum := (first x max: second x) @ (first y max: second y).
	^ CFPhysicsAABB position: minimum extent: maximum - minimum
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> rotateVector: aPoint by: anAngle [
	| cosine sine |
	anAngle = 0 ifTrue: [ ^ aPoint ].
	cosine := anAngle cos.
	sine := anAngle sin.
	^ ((aPoint x * cosine) - (aPoint y * sine))
		@ ((aPoint x * sine) + (aPoint y * cosine))
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> localPointForWorldPoint: aPoint bodyOrigin: aBodyOrigin rotation: anAngle [
	^ self rotateVector: aPoint - aBodyOrigin by: anAngle negated
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> bodyLocalPointForElementLocalPoint: aPoint [
	^ aPoint
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> elementLocalPointForBodyLocalPoint: aPoint [
	^ aPoint
]

{ #category : 'sensors' }
CFPhysicsChainSegmentShape >> isSensor [
	^ false
]


{ #category : 'capturing' }
CFPhysicsChainSegmentShape >> capturedForStep [
	^ self shallowCopy
]


{ #category : 'continuous collision' }
CFPhysicsChainSegmentShape >> distanceProxy [
	^ CFPhysicsDistanceProxy points: { point1. point2 } radius: 0.0
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> localCentroid [
	^ (point1 + point2) / 2.0
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> localCollisionVertices [
	^ { point1. point2 }
]

{ #category : 'continuous collision' }
CFPhysicsChainSegmentShape >> minimumExtent [
	^ (point2 - point1) r / 2.0
]

{ #category : 'material' }
CFPhysicsChainSegmentShape >> material [
	^ chain material
]

{ #category : 'filtering' }
CFPhysicsChainSegmentShape >> collisionFilter [
	^ chain collisionFilter
]

{ #category : 'filtering' }
CFPhysicsChainSegmentShape >> collisionCategoryBits [
	^ self collisionFilter categoryBits
]

{ #category : 'filtering' }
CFPhysicsChainSegmentShape >> collisionMaskBits [
	^ self collisionFilter maskBits
]

{ #category : 'filtering' }
CFPhysicsChainSegmentShape >> collisionGroupIndex [
	^ self collisionFilter groupIndex
]

{ #category : 'filtering' }
CFPhysicsChainSegmentShape >> allowsCollisionWith: anotherShape [
	^ self collisionFilter allowsCollisionWith: anotherShape collisionFilter
]

{ #category : 'testing' }
CFPhysicsChainSegmentShape >> isCircle [
	^ false
]

{ #category : 'testing' }
CFPhysicsChainSegmentShape >> isPolygon [
	^ false
]

{ #category : 'testing' }
CFPhysicsChainSegmentShape >> isRectangle [
	^ false
]

{ #category : 'testing' }
CFPhysicsChainSegmentShape >> isRoundedRectangle [
	^ false
]

{ #category : 'collision' }
CFPhysicsChainSegmentShape >> supportPointAtBodyOrigin: aBodyOrigin rotation: anAngle inDirection: aDirection [
	| first second |
	first := self worldPoint1AtBodyOrigin: aBodyOrigin rotation: anAngle.
	second := self worldPoint2AtBodyOrigin: aBodyOrigin rotation: anAngle.
	^ ((first dotProduct: aDirection) >= (second dotProduct: aDirection))
		ifTrue: [ first ]
		ifFalse: [ second ]
]

{ #category : 'continuous collision' }
CFPhysicsChainSegmentShape >> sweptAABBAlong: aSweep [
	| startTransform endTransform startBounds endBounds radius startCentre endCentre minimum maximum |
	startTransform := aSweep startTransform.
	endTransform := aSweep endTransform.
	startBounds := self
		aabbAtBodyOrigin: startTransform bodyOrigin
		rotation: startTransform rotation.
	endBounds := self
		aabbAtBodyOrigin: endTransform bodyOrigin
		rotation: endTransform rotation.
	startTransform rotation = endTransform rotation ifTrue: [
		^ startBounds mergedWith: endBounds ].

	radius := self boundingRadius.
	startCentre := startTransform bodyOrigin.
	endCentre := endTransform bodyOrigin.
	minimum := ((startCentre x min: endCentre x) - radius)
		@ ((startCentre y min: endCentre y) - radius).
	maximum := ((startCentre x max: endCentre x) + radius)
		@ ((startCentre y max: endCentre y) + radius).
	^ CFPhysicsAABB position: minimum extent: maximum - minimum
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> boundingRadius [
	^ point1 r max: point2 r
]

{ #category : 'geometry' }
CFPhysicsChainSegmentShape >> rollingResistanceRadius [
	^ 0.0
]
