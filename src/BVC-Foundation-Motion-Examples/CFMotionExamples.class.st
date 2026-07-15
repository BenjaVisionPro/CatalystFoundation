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

{ #category : 'private - running' }
CFMotionExamples >> finish: anOperation in: aSpace [
	aSpace pulse.
	5 milliSeconds wait.
	aSpace pulse.
	^ anOperation
]
