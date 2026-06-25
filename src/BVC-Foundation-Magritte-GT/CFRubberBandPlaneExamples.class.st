Class {
	#name : 'CFRubberBandPlaneExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'examples' }
CFRubberBandPlaneExamples >> verticalPlane [
	<gtExample>
	| plane |

	plane := CFRubberBandPlane vertical.
	plane vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.

	self assert: plane hasVertical.
	self assert: plane hasHorizontal not.
	self assert: plane position = (0 @ 0).
	self assert: plane wantsSnapBack not.

	^ plane
]

{ #category : 'examples' }
CFRubberBandPlaneExamples >> userMoveIntoOverscrollSlowsDown [
	<gtExample>
	| plane |

	plane := self verticalPlane.
	plane moveByUserInput: 0 @ 100.

	self assert: plane position y > 0.
	self assert: plane position y < 100.
	self assert: plane projectedPosition y > 0.
	self assert: plane projectedPosition y < plane position y.

	^ plane
]

{ #category : 'examples' }
CFRubberBandPlaneExamples >> repeatedUserMoveApproachesStopWithoutRunaway [
	<gtExample>
	| plane stop |

	plane := self verticalPlane.
	stop := plane vertical afterOverscrollStop.
	100 timesRepeat: [ plane moveByUserInput: 0 @ 1000 ].

	self assert: plane position y = stop.
	self assert: plane wantsSnapBack.
	self assert: plane projectedPosition y < 120.

	^ plane
]

{ #category : 'examples' }
CFRubberBandPlaneExamples >> endInteractionWhileOverscrolledRequestsSnapBack [
	<gtExample>
	| plane |

	plane := self verticalPlane.
	plane beginInteraction.
	plane moveByUserInput: 0 @ 50.
	plane endInteraction.

	self assert: plane isOverscrolled.
	self assert: plane wantsSnapBack.

	^ plane
]

{ #category : 'examples' }
CFRubberBandPlaneExamples >> snapBackMovementMovesDirectlyTowardBounds [
	<gtExample>
	| plane previous |

	plane := self verticalPlane.
	plane jumpTo: 0 @ -760.
	previous := plane position y.
	plane moveBySnapBack: 0 @ 20.

	self assert: plane position y = (previous + 20).
	self assert: plane isOverscrolled.

	^ plane
]

{ #category : 'examples' }
CFRubberBandPlaneExamples >> jumpToCanHoldOverscrollForDebug [
	<gtExample>
	| plane |

	plane := self verticalPlane.
	plane jumpTo: 0 @ 100.

	self assert: plane isOverscrolled.
	self assert: plane wantsSnapBack not.
	self assert: plane state = #idle.

	^ plane
]
