Class {
	#name : 'CFMotionExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Examples',
	#package : 'BVC-Foundation-Motion-Examples'
}

{ #category : 'examples - setup' }
CFMotionExamples >> spaceWithElement [
	| space element |
	space := BlSpace new.
	element := BlElement new
		size: 120 @ 80;
		background: Color veryLightGray;
		yourself.
	space root addChild: element.
	space pulse.
	^ space
]

{ #category : 'examples - property motion' }
CFMotionExamples >> opacityCompletes [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.2.
	operation := element motion
		duration: 1 milliSeconds;
		opacity: 1.0.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element opacity equals: 1.0.
	^ operation
]

{ #category : 'examples - retargeting' }
CFMotionExamples >> opacityRetargetsFromCurrentPresentation [
	<gtExample>
	| space element first second key |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.2.
	first := element motion opacity: 1.0.
	element opacity: 0.6.
	second := element motion opacity: 0.8.
	key := CFMotionPropertyKey
		element: element
		property: CFOpacityMotionProperty uniqueInstance.
	self assert: first == second.
	self assert: (first tracks first startValue) equals: 0.6.
	self assert: (first tracks first targetValue) equals: 0.8.
	self assert: (space cfMotionCoordinator ownerOf: key) == first.
	^ first
]

{ #category : 'examples - ownership' }
CFMotionExamples >> opacityReplacementKeepsOneOwner [
	<gtExample>
	| space element first second key |
	space := self spaceWithElement.
	element := space root children first.
	first := element motion opacity: 0.2.
	second := element motion opacity: 0.8.
	key := CFMotionPropertyKey
		element: element
		property: CFOpacityMotionProperty uniqueInstance.
	self assert: first == second.
	self assert: (space cfMotionCoordinator ownerOf: key) == first.
	self assert: space cfMotionCoordinator activeOperations size equals: 1.
	^ first
]

{ #category : 'examples - cancellation' }
CFMotionExamples >> opacityCancellationPreservesCurrentPresentation [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.2.
	operation := element motion opacity: 1.0.
	element opacity: 0.6.
	operation cancelPreservingCurrentPresentation.
	self assert: operation isCancelled.
	self assert: element opacity equals: 0.6.
	^ operation
]

{ #category : 'examples - cleanup' }
CFMotionExamples >> opacityCleanupReleasesOwnership [
	<gtExample>
	| space element operation key |
	space := self spaceWithElement.
	element := space root children first.
	operation := element motion opacity: 0.2.
	key := CFMotionPropertyKey
		element: element
		property: CFOpacityMotionProperty uniqueInstance.
	operation cancelSettlingAtEnd.
	self assert: (space cfMotionCoordinator ownerOf: key) isNil.
	self assert: space cfMotionCoordinator activeOperations isEmpty.
	^ operation
]

{ #category : 'examples - inspection' }
CFMotionExamples >> opacityOperationIsInspectable [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	operation := element motion opacity: 0.2.
	self assert: operation coordinator == space cfMotionCoordinator.
	self assert: operation tracks size equals: 1.
	self assert: operation trace entries isNotEmpty.
	^ operation
]

{ #category : 'examples - transform ownership probe' }
CFMotionExamples >> relativeTransformAnimationOverwritesAnExternalTransform [
	<gtExample>
	| space element animation applicationMatrix externalMatrix |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationMatrix := element transformation matrix.

	animation := BlTransformAnimation translate: 40 @ 0.
	animation duration: 1 second.
	element addAnimation: animation.
	space pulse.
	space time wait: 500 milliSeconds.
	space pulse.
	self assert: element transformation matrix ~= applicationMatrix.

	"An application transform arriving while the relative animation is running
	 is replaced by the animation's next absolute matrix."
	element transformDo: [ :aBuilder | aBuilder translateBy: 100 @ 0 ].
	externalMatrix := element transformation matrix.
	space time wait: 100 milliSeconds.
	space pulse.
	self assert: element transformation matrix ~= externalMatrix.
	^ animation
]

{ #category : 'examples - transform ownership probe' }
CFMotionExamples >> transformPresentationReleasesOnlyItsOwnTransformation [
	<gtExample>
	| space element applicationTransformation externalTransformation presentation |
	space := self spaceWithElement.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.

	presentation := CFMotionTransformPresentation on: element.
	presentation translation: 40 @ 0.
	self assert: presentation ownsCurrentTransformation.
	self assert: element transformation matrix ~= applicationTransformation matrix.
	presentation release.
	self assert: element transformation == applicationTransformation.

	presentation translation: 40 @ 0.
	element transformDo: [ :aBuilder | aBuilder translateBy: 100 @ 0 ].
	externalTransformation := element transformation.
	presentation release.
	self assert: element transformation == externalTransformation.
	self assert: presentation isActive not.
	^ presentation
]

{ #category : 'examples - geometry snapshots' }
CFMotionExamples >> geometrySnapshotCapturesImmutableBoundsInDeclaredSpace [
	<gtExample>
	| space element snapshot expectedBounds |
	space := self spaceWithElement.
	element := space root children first.
	snapshot := CFMotionGeometrySnapshot of: element in: space root.
	expectedBounds := BlBounds fromRectangle: element boundsInSpace.
	space root globalBoundsToLocal: expectedBounds.
	self assert: snapshot isValid.
	self assert: snapshot coordinateSpace == space root.
	self assert: snapshot bounds equals: expectedBounds asRectangle.
	self assert: snapshot parent == space root.
	^ snapshot
]

{ #category : 'examples - geometry snapshots' }
CFMotionExamples >> layoutComputedEventCapturesAuthoritativeDestinationGeometry [
	<gtExample>
	| space element source destination |
	space := self spaceWithElement.
	element := space root children first.
	source := CFMotionGeometrySnapshot of: element in: space root.
	space root
		when: BlElementLayoutComputedEvent
		doOnce: [ :anEvent |
			destination := CFMotionGeometrySnapshot of: element in: space root ].
	element size: 240 @ 100.
	space pulse.
	self assert: destination isNotNil.
	self assert: source bounds extent equals: 120 @ 80.
	self assert: destination bounds extent equals: 240 @ 100.
	^ destination
]

{ #category : 'examples - geometry presentation probe' }
CFMotionExamples >> inverseScalePresentsSourceExtentOverLaidOutDestination [
	<gtExample>
	| space element source destination presentation presented |
	space := self spaceWithElement.
	element := space root children first.
	source := CFMotionGeometrySnapshot of: element in: space root.
	element size: 240 @ 100.
	space pulse.
	destination := CFMotionGeometrySnapshot of: element in: space root.
	presentation := CFMotionTransformPresentation on: element.
	presentation scale: (source bounds extent x / destination bounds extent x)
		@ (source bounds extent y / destination bounds extent y).
	presented := CFMotionGeometrySnapshot of: element in: space root.
	self assert: destination bounds extent equals: 240 @ 100.
	self assert: presented bounds extent equals: source bounds extent.
	^ presentation
]

{ #category : 'examples - geometry presentation probe' }
CFMotionExamples >> inverseTransformPresentsSourceBoundsOverMovedAndResizedDestination [
	<gtExample>
	| space element source destination presentation presented |
	space := self spaceWithElement.
	element := space root children first.
	source := CFMotionGeometrySnapshot of: element in: space root.
	element
		relocate: 60 @ 20;
		size: 240 @ 100.
	space pulse.
	destination := CFMotionGeometrySnapshot of: element in: space root.
	presentation := CFMotionTransformPresentation on: element.
	presentation scale: (source bounds extent x / destination bounds extent x)
		@ (source bounds extent y / destination bounds extent y).
	presentation translation: source bounds origin - destination bounds origin.
	presented := CFMotionGeometrySnapshot of: element in: space root.
	self assert: destination bounds equals: ((60 @ 20) extent: 240 @ 100).
	self assert: presented bounds equals: source bounds.
	^ presentation
]

{ #category : 'examples - geometry operation' }
CFMotionExamples >> geometryOperationCompletesAtAuthoritativeLayout [
	<gtExample>
	| space element source destination track operation |
	space := self spaceWithElement.
	element := space root children first.
	source := CFMotionGeometrySnapshot of: element in: space root.
	element
		relocate: 60 @ 20;
		size: 240 @ 100.
	space pulse.
	destination := CFMotionGeometrySnapshot of: element in: space root.
	track := CFMotionGeometryTrack from: source to: destination.
	operation := CFMotionOperation
		coordinator: space cfMotionCoordinator
		tracks: { track }.
	operation duration: 1 milliSeconds.
	operation start.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds equals: source bounds.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds equals: destination bounds.
	self assert: track presentation isActive not.
	^ operation
]

{ #category : 'examples - layout transaction' }
CFMotionExamples >> layoutTransactionCapturesThenCompletesGeometry [
	<gtExample>
	| space element transaction |
	space := self spaceWithElement.
	element := space root children first.
	transaction := (space root motion
		duration: 1 milliSeconds;
		layout).
	transaction
		affecting: { element };
		mutate: [
			element
				relocate: 60 @ 20;
				size: 240 @ 100 ];
		play.
	self assert: transaction isAwaitingLayout.
	self assert: transaction sourceSnapshots first bounds equals: ((0 @ 0) extent: 120 @ 80).
	space pulse.
	self assert: transaction operation isRunning.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: transaction sourceSnapshots first bounds.
	self finish: transaction operation in: space.
	self assert: transaction operation isCompleted.
	self assert: transaction phase == CFMotionOperationState completed.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: transaction destinationSnapshots first bounds.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionExamples >> layoutTransactionCancellationRemovesPendingLayoutObserver [
	<gtExample>
	| space element transaction |
	space := self spaceWithElement.
	element := space root children first.
	transaction := (space root motion layout)
		affecting: { element };
		mutate: [ element size: 240 @ 100 ];
		play.
	transaction cancel.
	self assert: transaction isCancelled.
	self assert: transaction operation isNil.
	space pulse.
	self assert: transaction operation isNil.
	self assert: transaction destinationSnapshots isEmpty.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionExamples >> layoutTransactionCoordinatesMultipleParticipants [
	<gtExample>
	| space first second transaction |
	space := BlSpace new.
	first := BlElement new size: 120 @ 80; yourself.
	second := BlElement new size: 120 @ 80; yourself.
	space root addChildren: { first. second }.
	first relocate: 0 @ 0.
	second relocate: 0 @ 100.
	space pulse.
	transaction := (space root motion
		duration: 1 milliSeconds;
		layout)
		affecting: { first. second };
		mutate: [
			first
				relocate: 60 @ 20;
				size: 240 @ 100.
			second
				relocate: 20 @ 150;
				size: 180 @ 40 ];
		play.
	space pulse.
	self assert: transaction operation tracks size equals: 2.
	self assert: (CFMotionGeometrySnapshot of: first in: space root) bounds
		equals: transaction sourceSnapshots first bounds.
	self assert: (CFMotionGeometrySnapshot of: second in: space root) bounds
		equals: transaction sourceSnapshots second bounds.
	self finish: transaction operation in: space.
	self assert: (CFMotionGeometrySnapshot of: first in: space root) bounds
		equals: transaction destinationSnapshots first bounds.
	self assert: (CFMotionGeometrySnapshot of: second in: space root) bounds
		equals: transaction destinationSnapshots second bounds.
	^ transaction
]

{ #category : 'examples - geometry operation' }
CFMotionExamples >> geometryOperationComposesWithApplicationTransform [
	<gtExample>
	| space element applicationTransformation source destination track operation |
	space := self spaceWithElement.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 30 @ 10 ].
	applicationTransformation := element transformation.
	source := CFMotionGeometrySnapshot of: element in: space root.
	element
		relocate: 60 @ 20;
		size: 240 @ 100.
	space pulse.
	destination := CFMotionGeometrySnapshot of: element in: space root.
	track := CFMotionGeometryTrack from: source to: destination.
	operation := CFMotionOperation
		coordinator: space cfMotionCoordinator
		tracks: { track }.
	operation duration: 1 milliSeconds.
	operation start.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds equals: source bounds.
	self finish: operation in: space.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds equals: destination bounds.
	self assert: element transformation == applicationTransformation.
	^ operation
]

{ #category : 'examples - layout transaction' }
CFMotionExamples >> layoutTransactionRetargetsFromCurrentPresentation [
	<gtExample>
	| space element first second |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	first := (space root motion
		duration: 1 second;
		layout)
		affecting: { element };
		mutate: [
			element
				relocate: 60 @ 20;
				size: 240 @ 100 ];
		play.
	space pulse.
	space pulse.
	space time wait: 500 milliSeconds.
	space pulse.
	second := (space root motion
		duration: 1 milliSeconds;
		layout)
		affecting: { element };
		mutate: [
			element
				relocate: 120 @ 40;
				size: 180 @ 60 ];
		play.
	space pulse.
	self assert: first operation isCancelled.
	self assert: second operation isRunning.
	self assert: second destinationSnapshots first bounds equals: ((120 @ 40) extent: 180 @ 60).
	self assert: second operation tracks first presentation ownsCurrentTransformation.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: second sourceSnapshots first bounds.
	self assert: space cfMotionCoordinator activeOperations size equals: 1.
	space pulse.
	space time wait: 5 milliSeconds.
	space pulse.
	self assert: second operation isCompleted.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: second destinationSnapshots first bounds.
	^ second
]

{ #category : 'examples - layout transaction' }
CFMotionExamples >> layoutTransactionRetargetsMultipleParticipantsFromCurrentPresentation [
	<gtExample>
	| space firstElement secondElement first second |
	space := BlSpace new.
	space time: BlTime simulated.
	firstElement := BlElement new size: 120 @ 80; yourself.
	secondElement := BlElement new size: 120 @ 80; yourself.
	space root addChildren: { firstElement. secondElement }.
	firstElement relocate: 0 @ 0.
	secondElement relocate: 0 @ 100.
	space pulse.
	first := (space root motion
		duration: 1 second;
		layout)
		affecting: { firstElement. secondElement };
		mutate: [
			firstElement
				relocate: 60 @ 20;
				size: 240 @ 100.
			secondElement
				relocate: 20 @ 150;
				size: 180 @ 40 ];
		play.
	space pulse.
	space pulse.
	space time wait: 500 milliSeconds.
	space pulse.
	second := (space root motion
		duration: 1 milliSeconds;
		layout)
		affecting: { firstElement. secondElement };
		mutate: [
			firstElement
				relocate: 120 @ 40;
				size: 180 @ 60.
			secondElement
				relocate: 80 @ 180;
				size: 100 @ 120 ];
		play.
	space pulse.
	self assert: first operation isCancelled.
	self assert: second operation isRunning.
	self assert: second destinationSnapshots first bounds equals: ((120 @ 40) extent: 180 @ 60).
	self assert: second destinationSnapshots second bounds equals: ((80 @ 180) extent: 100 @ 120).
	self assert: second operation tracks first presentation ownsCurrentTransformation.
	self assert: second operation tracks second presentation ownsCurrentTransformation.
	self
		assertBounds: (CFMotionGeometrySnapshot of: firstElement in: space root) bounds
		closeTo: second sourceSnapshots first bounds.
	self
		assertBounds: (CFMotionGeometrySnapshot of: secondElement in: space root) bounds
		closeTo: second sourceSnapshots second bounds.
	self assert: space cfMotionCoordinator activeOperations size equals: 1.
	space pulse.
	space time wait: 5 milliSeconds.
	space pulse.
	self assert: second operation isCompleted.
	self assert: (CFMotionGeometrySnapshot of: firstElement in: space root) bounds
		equals: second destinationSnapshots first bounds.
	self assert: (CFMotionGeometrySnapshot of: secondElement in: space root) bounds
		equals: second destinationSnapshots second bounds.
	^ second
]

{ #category : 'private - running' }
CFMotionExamples >> assertBounds: actualBounds closeTo: expectedBounds [
	self assert: (actualBounds origin closeTo: expectedBounds origin precision: 0.0001).
	self assert: (actualBounds corner closeTo: expectedBounds corner precision: 0.0001)
]

{ #category : 'private - running' }
CFMotionExamples >> finish: anOperation in: aSpace [
	aSpace pulse.
	5 milliSeconds wait.
	aSpace pulse.
	^ anOperation
]
