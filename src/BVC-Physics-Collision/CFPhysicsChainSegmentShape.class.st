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
