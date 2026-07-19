Class {
	#name : 'CFMotionTest',
	#superclass : 'TestCase',
	#category : 'BVC-Foundation-Motion-Tests',
	#package : 'BVC-Foundation-Motion-Tests'
}

{ #category : 'examples - setup' }
CFMotionTest >> spaceWithElement [
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
CFMotionTest >> testOpacityCompletes [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.2.
	motion := (element motion
		duration: 1 milliSeconds;
		opacity: 1.0;
		build) start.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: (element opacity closeTo: 1.0).
	^ motion
]

{ #category : 'examples - property motion' }
CFMotionTest >> testScaleCompletesAtThePresentedValue [
	<gtExample>
	| space element applicationTransformation motion |
	space := self spaceWithElement.
	element := space root children first.
	applicationTransformation := element transformation.
	motion := (element motion
		duration: 1 milliSeconds;
		scale: 0.5 @ 0.8;
		build) start.
	self assert: motion isRunning.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: motion tracks first presentation isActive not.
	self assert: element transformation matrix ~= applicationTransformation matrix.
	^ motion
]

{ #category : 'examples - property motion' }
CFMotionTest >> testTranslationComposesWithASettledScale [
	<gtExample>
	| space element scaleMotion scaleTransformation translationMotion |
	space := self spaceWithElement.
	element := space root children first.
	scaleMotion := (element motion
		duration: 1 milliSeconds;
		scale: 0.5 @ 0.8;
		build) start.
	self finish: scaleMotion in: space.
	scaleTransformation := element transformation.
	translationMotion := (element motion
		duration: 1 milliSeconds;
		translation: 40 @ 20;
		build) start.
	self finish: translationMotion in: space.
	self assert: translationMotion isCompleted.
	self assert: element transformation matrix ~= scaleTransformation matrix.
	^ translationMotion
]

{ #category : 'examples - property motion' }
CFMotionTest >> testScaleRetargetsThroughItsPresentedProperty [
	<gtExample>
	| space element first second |
	space := self spaceWithElement.
	element := space root children first.
	first := (element motion
		duration: 1 second;
		scale: 0.5 @ 0.8;
		build)
		start.
	second := first
		retarget: (CFMotionScaleTrack on: element from: 1 @ 1 to: 0.8 @ 0.6)
		duration: 1 second
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: first == second.
	self assert: second tracks first targetScale equals: 0.8 @ 0.6.
	^ second
]

{ #category : 'examples - property motion' }
CFMotionTest >> testRotationCompletesAtThePresentedValue [
	<gtExample>
	| space element applicationTransformation motion |
	space := self spaceWithElement.
	element := space root children first.
	applicationTransformation := element transformation.
	motion := (element motion
		duration: 1 milliSeconds;
		rotation: 30;
		build) start.
	self assert: motion isRunning.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: motion tracks first presentation rotation equals: 30.
	self assert: element transformation matrix ~= applicationTransformation matrix.
	^ motion
]

{ #category : 'examples - property motion' }
CFMotionTest >> testRotationComposesWithASettledScale [
	<gtExample>
	| space element scaleMotion scaleTransformation rotationMotion |
	space := self spaceWithElement.
	element := space root children first.
	scaleMotion := (element motion
		duration: 1 milliSeconds;
		scale: 0.5 @ 0.8;
		build) start.
	self finish: scaleMotion in: space.
	scaleTransformation := element transformation.
	rotationMotion := (element motion
		duration: 1 milliSeconds;
		rotation: 30;
		build) start.
	self finish: rotationMotion in: space.
	self assert: rotationMotion isCompleted.
	self assert: element transformation matrix ~= scaleTransformation matrix.
	^ rotationMotion
]

{ #category : 'examples - motions' }
CFMotionTest >> testFadeInCompletesThroughTheSharedOpacityMotion [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.0.
	motion := (CFMotionBuilder fadeIn
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: motion tracks first property == CFMotionOpacityProperty uniqueInstance.
	self assert: (element opacity closeTo: 1.0).
	^ motion
]

{ #category : 'examples - motions' }
CFMotionTest >> testFadeOutRetargetsToFadeInThroughTheSharedOpacityMotion [
	<gtExample>
	| space element first second |
	space := self spaceWithElement.
	element := space root children first.
	first := (CFMotionBuilder fadeOut
		element: element;
		duration: 1 second;
		build)
		start.
	element opacity: 0.4.
	second := first
		retarget: (CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: 1.0)
		duration: 1 second
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: first == second.
	self assert: second isRunning.
	self assert: second tracks first startValue equals: 0.4.
	self assert: second tracks first targetValue equals: 1.0.
	^ second
]

{ #category : 'examples - public API' }
CFMotionTest >> testDirectNamedFadeInBuildsAndStartsImmediately [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	motion := element motion fadeIn.
	self assert: motion isRunning.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: motion isCompleted.
	self assert: (element opacity closeTo: 1.0).
	^ motion
]

{ #category : 'examples - public API' }
CFMotionTest >> testDirectNamedFadeOutBuildsAndStartsImmediately [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	motion := element motion fadeOut.
	self assert: motion isRunning.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: motion isCompleted.
	self assert: element opacity equals: 0.0.
	^ motion
]

{ #category : 'examples - public API' }
CFMotionTest >> testDirectNamedFadeOutCancellationPreservesCurrentPresentation [
	<gtExample>
	| space element motion presentedOpacity |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	motion := element motion fadeOut.
	space pulse.
	space time wait: 90 milliSeconds.
	space pulse.
	presentedOpacity := element opacity.
	motion cancelPreservingCurrentPresentation.
	self assert: motion isCancelled.
	self assert: element opacity equals: presentedOpacity.
	^ motion
]

{ #category : 'examples - public API' }
CFMotionTest >> testNamedFadeInConfigurationBlockStartsWhenItReturns [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.0.
	motion := element motion fadeIn: [ :builder |
		builder duration: 1 milliSeconds ].
	self assert: motion isRunning.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: (element opacity closeTo: 1.0).
	^ motion
]

{ #category : 'examples - public API' }
CFMotionTest >> testNamedMotionRequiresAnAttachedElement [
	<gtExample>
	| element didFail |
	element := BlElement new.
	didFail := false.
	[ element motion fadeOut ] on: Error do: [ :anError | didFail := true ].
	self assert: didFail.
	^ element
]

{ #category : 'examples - public API' }
CFMotionTest >> testCustomMotionBuildThenStartRemainsExplicit [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	element := space root children first.
	motion := element motion
		duration: 1 milliSeconds;
		opacity: 0.2;
		build.
	self assert: motion state == CFMotionState idle.
	motion start.
	self assert: motion isRunning.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: (element opacity closeTo: 0.2).
	^ motion
]

{ #category : 'examples - public API' }
CFMotionTest >> testDirectNamedRiseAndFadeInBuildsAndStartsImmediately [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	motion := element motion riseAndFadeIn.
	self assert: motion isRunning.
	self assert: motion tracks size equals: 2.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: motion isCompleted.
	self assert: (element opacity closeTo: 1.0).
	^ motion
]

{ #category : 'examples - public API' }
CFMotionTest >> testDirectNamedFallAndFadeOutBuildsAndStartsImmediately [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	motion := element motion fallAndFadeOut.
	self assert: motion isRunning.
	self assert: motion tracks size equals: 2.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: motion isCompleted.
	self assert: element opacity equals: 0.0.
	^ motion
]

{ #category : 'examples - public API' }
CFMotionTest >> testDirectNamedRiseAndFadeInCanRetargetThroughItsReturnedMotion [
	<gtExample>
	| space element motion retargeted |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	motion := element motion riseAndFadeIn.
	space pulse.
	space time wait: 90 milliSeconds.
	space pulse.
	retargeted := motion
		retarget: {
			CFMotionPropertyTrack
				on: element
				property: CFMotionOpacityProperty uniqueInstance
				target: 0.0.
			CFMotionTranslationTrack on: element from: 0 @ 0 to: 0 @ 12 }
		duration: 1 second
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: retargeted == motion description: 'Retargeting must keep the named Motion instance'.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: motion isCompleted description: 'The retargeted named Motion must complete'.
	self assert: (element opacity closeTo: 0.0) description: 'The retargeted named Motion must reach its opacity target'.
	^ motion
]

{ #category : 'examples - public API' }
CFMotionTest >> testDirectNamedScaleAndFadeInBuildsAndStartsImmediately [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	motion := element motion scaleAndFadeIn.
	self assert: motion isRunning.
	self assert: motion tracks size equals: 2.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: motion isCompleted.
	self assert: (element opacity closeTo: 1.0).
	^ motion
]

{ #category : 'examples - public API' }
CFMotionTest >> testDirectNamedScaleAndFadeOutBuildsAndStartsImmediately [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	motion := element motion scaleAndFadeOut.
	self assert: motion isRunning.
	self assert: motion tracks size equals: 2.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: motion isCompleted.
	self assert: element opacity equals: 0.0.
	^ motion
]

{ #category : 'examples - public API' }
CFMotionTest >> testDirectNamedScaleAndFadeInCanRetargetThroughItsReturnedMotion [
	<gtExample>
	| space element motion retargeted |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	motion := element motion scaleAndFadeIn.
	space pulse.
	space time wait: 90 milliSeconds.
	space pulse.
	retargeted := motion
		retarget: {
			CFMotionPropertyTrack
				on: element
				property: CFMotionOpacityProperty uniqueInstance
				target: 0.0.
			CFMotionScaleTrack on: element from: 1 @ 1 to: 0.8 @ 0.8 }
		duration: 1 second
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: retargeted == motion description: 'Retargeting must keep the named Motion instance'.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: motion isCompleted description: 'The retargeted named Motion must complete'.
	self assert: (element opacity closeTo: 0.0) description: 'The retargeted named Motion must reach its opacity target'.
	^ motion
]

{ #category : 'examples - composed motion' }
CFMotionTest >> testComposedMotionCompletesAfterItsLastComponent [
	<gtExample>
	| space element fade scale motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	fade := element motion
		duration: 400 milliSeconds;
		opacity: 1.0;
		build.
	scale := element motion
		duration: 1 second;
		scale: 1.2 @ 1.2;
		build.
	motion := (CFMotion composedOf: { fade. scale }) start.
	self assert: motion isRunning.
	self assert: motion componentMotions equals: { fade. scale }.
	space pulse.
	space time wait: 500 milliSeconds.
	space pulse.
	self assert: fade isCompleted.
	self assert: scale isRunning.
	self assert: motion isRunning.
	space time wait: 600 milliSeconds.
	space pulse.
	self assert: scale isCompleted.
	self assert: motion isCompleted.
	^ motion
]

{ #category : 'examples - composed motion' }
CFMotionTest >> testCancellingAComposedMotionCancelsAndRestoresEveryComponent [
	<gtExample>
	| space element originalTransformation fade scale motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	originalTransformation := element transformation.
	fade := element motion
		duration: 1 second;
		opacity: 1.0;
		build.
	scale := element motion
		duration: 1 second;
		scale: 1.2 @ 1.2;
		build.
	motion := (CFMotion composedOf: { fade. scale }) start.
	space pulse.
	space time wait: 90 milliSeconds.
	space pulse.
	motion cancelAndRestore.
	self assert: motion isCancelled.
	self assert: fade isCancelled.
	self assert: scale isCancelled.
	self assert: element opacity equals: 0.0.
	self assert: element transformation == originalTransformation.
	^ motion
]

{ #category : 'examples - timeline layout' }
CFMotionTest >> testTimelineDerivesItsEndAndPlacesTracksRelativeToIt [
	<gtExample>
	| timeline path bounce fade |
	timeline := CFMotionTimeline new.
	path := (CFMotionTimelineTrack in: timeline)
		duration: 1 second.
	bounce := (CFMotionTimelineTrack in: timeline)
		duration: 250 milliSeconds;
		repeatsEvery: 250 milliSeconds;
		endsAt: timeline end.
	fade := (CFMotionTimelineTrack in: timeline)
		duration: 100 milliSeconds;
		ends: 100 milliSeconds before: timeline end.
	self assert: timeline duration equals: 1 second.
	self assert: path resolvedStart equals: 0 milliSeconds.
	self assert: path resolvedEnd equals: 1 second.
	self assert: bounce resolvedStart equals: 0 milliSeconds.
	self assert: bounce resolvedEnd equals: 1 second.
	self assert: fade resolvedStart equals: 800 milliSeconds.
	self assert: fade resolvedEnd equals: 900 milliSeconds.
	^ timeline
]

{ #category : 'examples - timeline layout' }
CFMotionTest >> testTimelinePlacesATrackAfterAnotherTrackEnds [
	<gtExample>
	| timeline path arrival |
	timeline := CFMotionTimeline new.
	path := (CFMotionTimelineTrack in: timeline)
		duration: 1 second.
	arrival := (CFMotionTimelineTrack in: timeline)
		duration: 200 milliSeconds;
		starts: 100 milliSeconds after: path end.
	self assert: timeline duration equals: 1300 milliSeconds.
	self assert: arrival resolvedStart equals: 1100 milliSeconds.
	self assert: arrival resolvedEnd equals: 1300 milliSeconds.
	^ timeline
]

{ #category : 'examples - timeline execution' }
CFMotionTest >> testTimelineExecutesFiniteTracksFromOneRootMotion [
	<gtExample>
	| space element timeline fade translation scale motion easing |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	easing := BlDecelerateInterpolator factor: 1.4.
	timeline := CFMotionTimeline new.
	fade := (CFMotionTimelineTrack
		on: (CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: 1.0)
		in: timeline)
		duration: 400 milliSeconds.
	translation := (CFMotionTimelineTrack
		on: (CFMotionTranslationTrack on: element from: 0 @ 0 to: 40 @ 0)
		in: timeline)
		duration: 1 second.
	scale := (CFMotionTimelineTrack
		on: (CFMotionScaleTrack on: element from: 1 @ 1 to: 1.2 @ 1.2)
		in: timeline)
		duration: 400 milliSeconds;
		starts: 200 milliSeconds after: timeline start.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	self assert: motion tracks equals: { fade. translation. scale }.
	space pulse.
	space time wait: 500 milliSeconds.
	space pulse.
	self assert: (element opacity closeTo: 1.0).
	self assert: (translation behaviour presentation translation x
		closeTo: 40.0 * (easing interpolate: 0.5)).
	self assert: (scale behaviour presentation scale x
		closeTo: 1.0 + (0.2 * (easing interpolate: 0.75))).
	self assert: motion isRunning.
	space time wait: 600 milliSeconds.
	space pulse.
	self assert: motion isCompleted.
	^ motion
]

{ #category : 'examples - motions' }
CFMotionTest >> testScaleInBuilderBuildsAScaleMotion [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	element := space root children first.
	motion := (CFMotionBuilder scaleIn
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: motion tracks first sourceScale equals: 0.8 @ 0.8.
	self finish: motion in: space.
	self assert: motion isCompleted.
	^ motion
]

{ #category : 'examples - motions' }
CFMotionTest >> testScaleOutBuilderBuildsAScaleMotion [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	element := space root children first.
	motion := (CFMotionBuilder scaleOut
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: motion tracks first targetScale equals: 0.8 @ 0.8.
	self finish: motion in: space.
	self assert: motion isCompleted.
	^ motion
]

{ #category : 'examples - motions' }
CFMotionTest >> testCrossFadeUsesOneSharedMotion [
	<gtExample>
	| space outgoing incoming motion |
	space := self spaceWithElement.
	outgoing := space root children first.
	incoming := BlElement new size: 120 @ 80; yourself.
	incoming opacity: 0.0.
	space root addChild: incoming.
	motion := (CFMotion
		coordinator: space cfMotionCoordinator
		tracks: {
			CFMotionPropertyTrack on: outgoing property: CFMotionOpacityProperty uniqueInstance target: 0.0.
			CFMotionPropertyTrack on: incoming property: CFMotionOpacityProperty uniqueInstance target: 1.0 })
		duration: 1 milliSeconds;
		easing: (BlDecelerateInterpolator factor: 1.4);
		start.
	self assert: motion isRunning.
	self assert: motion tracks size equals: 2.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: outgoing opacity equals: 0.0.
	self assert: incoming opacity equals: 1.0.
	^ motion
]

{ #category : 'examples - motions' }
CFMotionTest >> testCrossFadeCancellationRestoresBothParticipants [
	<gtExample>
	| space outgoing incoming motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	outgoing := space root children first.
	incoming := BlElement new size: 120 @ 80; yourself.
	incoming opacity: 0.0.
	space root addChild: incoming.
	motion := (CFMotion
		coordinator: space cfMotionCoordinator
		tracks: {
			CFMotionPropertyTrack on: outgoing property: CFMotionOpacityProperty uniqueInstance target: 0.0.
			CFMotionPropertyTrack on: incoming property: CFMotionOpacityProperty uniqueInstance target: 1.0 })
		duration: 1 second;
		easing: (BlDecelerateInterpolator factor: 1.4);
		start.
	space pulse.
	space time wait: 500 milliSeconds.
	space pulse.
	self assert: motion isRunning.
	motion cancelAndRestore.
	self assert: motion isCancelled.
	self assert: outgoing opacity equals: 1.0.
	self assert: incoming opacity equals: 0.0.
	^ motion
]

{ #category : 'examples - motions' }
CFMotionTest >> testScaleInCompletesAndRestoresTheApplicationTransformation [
	<gtExample>
	| space element applicationTransformation motion |
	space := self spaceWithElement.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	motion := (CFMotionBuilder scaleIn
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: motion isRunning.
	self assert: motion tracks first presentation ownsCurrentTransformation.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: element transformation == applicationTransformation.
	^ motion
]

{ #category : 'examples - motions' }
CFMotionTest >> testScaleInComposesWithRunningLayoutGeometry [
	<gtExample>
	| space element transaction scaleMotion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	transaction := (space root motion
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
	self assert: transaction motion isRunning.
	scaleMotion := (CFMotionBuilder scaleIn
		element: element;
		duration: 1 second;
		build)
		start.
	space time wait: 500 milliSeconds.
	space pulse.
	self assert: scaleMotion isRunning.
	self assert: transaction motion tracks first presentation ownsCurrentTransformation.
	self assert: scaleMotion tracks first presentation ownsCurrentTransformation.
	scaleMotion cancelAndRestore.
	self assert: scaleMotion isCancelled.
	self assert: transaction motion tracks first presentation ownsCurrentTransformation.
	space time wait: 1 second.
	space pulse.
	self assert: transaction motion isCompleted.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: transaction destinationSnapshots first bounds.
	^ { transaction. scaleMotion }
]

{ #category : 'examples - motions' }
CFMotionTest >> testScaleAndFadeInCoordinatesOpacityAndScale [
	<gtExample>
	| space element applicationTransformation motion |
	space := self spaceWithElement.
	element := space root children first.
	element
		opacity: 0.0;
		transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	motion := (CFMotionBuilder scaleAndFadeIn
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: motion tracks size equals: 2.
	self assert: motion tracks second presentation ownsCurrentTransformation.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: (element opacity closeTo: 1.0).
	self assert: element transformation == applicationTransformation.
	^ motion
]

{ #category : 'examples - motions' }
CFMotionTest >> testScaleAndFadeOutCoordinatesOpacityAndScale [
	<gtExample>
	| space element applicationTransformation motion |
	space := self spaceWithElement.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	motion := (CFMotionBuilder scaleAndFadeOut
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: motion tracks size equals: 2.
	self assert: motion tracks second presentation ownsCurrentTransformation.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: element opacity equals: 0.0.
	self assert: element transformation == applicationTransformation.
	^ motion
]

{ #category : 'examples - motions' }
CFMotionTest >> testRiseAndFadeInCoordinatesOpacityAndTranslation [
	<gtExample>
	| space element applicationTransformation motion |
	space := self spaceWithElement.
	element := space root children first.
	element
		opacity: 0.0;
		transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	motion := (CFMotionBuilder riseAndFadeIn
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: motion tracks size equals: 2.
	self assert: motion tracks second presentation ownsCurrentTransformation.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: (element opacity closeTo: 1.0).
	self assert: element transformation == applicationTransformation.
	^ motion
]

{ #category : 'examples - motions' }
CFMotionTest >> testFallAndFadeOutCoordinatesOpacityAndTranslation [
	<gtExample>
	| space element applicationTransformation motion |
	space := self spaceWithElement.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	motion := (CFMotionBuilder fallAndFadeOut
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: motion tracks size equals: 2.
	self assert: motion tracks second presentation ownsCurrentTransformation.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: element opacity equals: 0.0.
	self assert: element transformation == applicationTransformation.
	^ motion
]

{ #category : 'examples - aptitude' }
CFMotionTest >> testMotionButtonAptitudeInstallsAndRemovesItsHandlers [
	<gtExample>
	| space element aptitude |
	space := self spaceWithElement.
	element := space root children first.
	aptitude := CFMotionButtonAptitude new.
	element addAptitude: aptitude.
	self assert: aptitude isAttachedToWidget.
	element removeAptitude: aptitude.
	self assert: aptitude isAttachedToWidget not.
	^ aptitude
]

{ #category : 'examples - aptitude' }
CFMotionTest >> testMotionButtonAptitudeRetargetsWhilePressed [
	<gtExample>
	| space element aptitude motion |
	space := self spaceWithElement.
	element := space root children first.
	aptitude := CFMotionButtonAptitude new.
	element addAptitude: aptitude.
	element dispatchEvent: BlMouseDownEvent primary.
	motion := aptitude activeMotion.
	self assert: motion isRunning.
	motion
		retarget: (CFMotionScaleTrack on: element from: 1 @ 1 to: 1 @ 1)
		duration: 1 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: motion tracks first targetScale equals: 1 @ 1.
	^ motion
]

{ #category : 'examples - aptitude' }
CFMotionTest >> testMotionButtonAptitudeReturnsToRestOnRelease [
	<gtExample>
	| space element aptitude motion |
	space := self spaceWithElement.
	element := space root children first.
	aptitude := CFMotionButtonAptitude new.
	element addAptitude: aptitude.
	element dispatchEvent: BlMouseDownEvent primary.
	motion := aptitude activeMotion.
	element dispatchEvent: BlMouseUpEvent primary.
	self assert: aptitude activeMotion == motion.
	self assert: (motion isRunning or: [ motion isCompleted ]).
	self assert: motion tracks first targetScale equals: 1 @ 1.
	^ motion
]

{ #category : 'examples - aptitude' }
CFMotionTest >> testMotionButtonAptitudeHoldsTheCompressedPresentation [
	<gtExample>
	| space element aptitude motion |
	space := self spaceWithElement.
	element := space root children first.
	aptitude := CFMotionButtonAptitude new.
	element addAptitude: aptitude.
	element dispatchEvent: BlMouseDownEvent primary.
	motion := aptitude activeMotion.
	space pulse.
	150 milliSeconds wait.
	space pulse.
	self assert: motion state == CFMotionState settled.
	self assert: motion tracks first presentation isActive.
	^ motion
]

{ #category : 'examples - aptitude' }
CFMotionTest >> testMotionButtonAptitudeReleasesTheHeldPresentation [
	<gtExample>
	| space element aptitude motion |
	space := self spaceWithElement.
	element := space root children first.
	aptitude := CFMotionButtonAptitude new.
	element addAptitude: aptitude.
	element dispatchEvent: BlMouseDownEvent primary.
	motion := aptitude activeMotion.
	space pulse.
	150 milliSeconds wait.
	space pulse.
	self assert: motion state == CFMotionState settled.
	element dispatchEvent: BlMouseUpEvent primary.
	space pulse.
	150 milliSeconds wait.
	space pulse.
	self assert: motion isCompleted.
	self assert: motion tracks first presentation isActive not.
	^ motion
]

{ #category : 'examples - retargeting' }
CFMotionTest >> testCoordinatorRetargetKeepsTheOwningMotion [
	<gtExample>
	| space element coordinator first retargeted key |
	space := self spaceWithElement.
	element := space root children first.
	coordinator := space cfMotionCoordinator.
	first := (element motion opacity: 0.2; build) start.
	retargeted := coordinator
		retarget: (CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: 0.8)
		duration: 180 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4).
	key := CFMotionPropertyKey
		element: element
		property: CFMotionOpacityProperty uniqueInstance.
	self assert: retargeted == first.
	self assert: (coordinator ownerOf: key) == first.
	self assert: coordinator activeMotions size equals: 1.
	^ first
]

{ #category : 'examples - retargeting' }
CFMotionTest >> testCoordinatorRetargetStartsAMotionForAnUnownedProperty [
	<gtExample>
	| space element coordinator motion key |
	space := self spaceWithElement.
	element := space root children first.
	coordinator := space cfMotionCoordinator.
	motion := coordinator
		retarget: (CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: 0.8)
		duration: 180 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4).
	key := CFMotionPropertyKey
		element: element
		property: CFMotionOpacityProperty uniqueInstance.
	self assert: motion isRunning.
	self assert: (coordinator ownerOf: key) == motion.
	self assert: coordinator activeMotions size equals: 1.
	^ motion
]

{ #category : 'examples - retargeting' }
CFMotionTest >> testOpacityRetargetsFromCurrentPresentation [
	<gtExample>
	| space element first second key |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.2.
	first := (element motion opacity: 1.0; build) start.
	element opacity: 0.6.
	second := first
		retarget: (CFMotionPropertyTrack on: element property: CFMotionOpacityProperty uniqueInstance target: 0.8)
		duration: 180 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4).
	key := CFMotionPropertyKey
		element: element
		property: CFMotionOpacityProperty uniqueInstance.
	self assert: first == second.
	self assert: (first tracks first startValue) equals: 0.6.
	self assert: (first tracks first targetValue) equals: 0.8.
	self assert: (space cfMotionCoordinator ownerOf: key) == first.
	^ first
]

{ #category : 'examples - ownership' }
CFMotionTest >> testOpacityReplacementKeepsOneOwner [
	<gtExample>
	| space element first second key |
	space := self spaceWithElement.
	element := space root children first.
	first := (element motion opacity: 0.2; build) start.
	second := first
		retarget: (CFMotionPropertyTrack on: element property: CFMotionOpacityProperty uniqueInstance target: 0.8)
		duration: 180 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4).
	key := CFMotionPropertyKey
		element: element
		property: CFMotionOpacityProperty uniqueInstance.
	self assert: first == second.
	self assert: (space cfMotionCoordinator ownerOf: key) == first.
	self assert: space cfMotionCoordinator activeMotions size equals: 1.
	^ first
]

{ #category : 'examples - cancellation' }
CFMotionTest >> testOpacityCancellationPreservesCurrentPresentation [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.2.
	motion := (element motion opacity: 1.0; build) start.
	element opacity: 0.6.
	motion cancelPreservingCurrentPresentation.
	self assert: motion isCancelled.
	self assert: element opacity equals: 0.6.
	^ motion
]

{ #category : 'examples - cleanup' }
CFMotionTest >> testOpacityCleanupReleasesOwnership [
	<gtExample>
	| space element motion key |
	space := self spaceWithElement.
	element := space root children first.
	motion := (element motion opacity: 0.2; build) start.
	key := CFMotionPropertyKey
		element: element
		property: CFMotionOpacityProperty uniqueInstance.
	motion cancelSettlingAtEnd.
	self assert: (space cfMotionCoordinator ownerOf: key) isNil.
	self assert: space cfMotionCoordinator activeMotions isEmpty.
	^ motion
]

{ #category : 'examples - structural motion' }
CFMotionTest >> testOverlayTracksItsReferenceAndCleansUp [
	<gtExample>
	| space reference overlay |
	space := BlSpace new.
	reference := BlElement new
		relocate: 40 @ 30;
		size: 120 @ 80;
		yourself.
	overlay := BlOverlayElement on: reference.
	space root addChild: reference.
	space root addChild: overlay.
	space pulse.
	self assertBounds: (CFMotionGeometrySnapshot of: overlay in: space root) bounds
		closeTo: (CFMotionGeometrySnapshot of: reference in: space root) bounds.
	reference
		relocate: 180 @ 90;
		size: 240 @ 100.
	space pulse.
	self assertBounds: (CFMotionGeometrySnapshot of: overlay in: space root) bounds
		closeTo: (CFMotionGeometrySnapshot of: reference in: space root) bounds.
	overlay detach.
	overlay removeFromParent.
	self assert: overlay isAttached not.
	self assert: overlay hasParent not.
	^ overlay
]

{ #category : 'examples - structural motion' }
CFMotionTest >> testMotionOverlayTracksANestedReferenceAndCleansUp [
	<gtExample>
	| space container reference motionOverlay |
	space := BlSpace new.
	container := BlElement new
		relocate: 60 @ 40;
		size: 300 @ 200;
		yourself.
	reference := BlElement new
		relocate: 40 @ 30;
		size: 120 @ 80;
		yourself.
	space root addChild: container.
	container addChild: reference.
	motionOverlay := CFMotionOverlay on: reference in: space root.
	space pulse.
	self assert: motionOverlay isInstalled.
	self assert: motionOverlay overlay parent == space root.
	self assertBounds: (CFMotionGeometrySnapshot of: motionOverlay overlay in: space root) bounds
		closeTo: (CFMotionGeometrySnapshot of: reference in: space root) bounds.
	container relocate: 180 @ 90.
	reference size: 240 @ 100.
	space pulse.
	self assertBounds: (CFMotionGeometrySnapshot of: motionOverlay overlay in: space root) bounds
		closeTo: (CFMotionGeometrySnapshot of: reference in: space root) bounds.
	motionOverlay release.
	self assert: motionOverlay isInstalled not.
	self assert: motionOverlay overlay isAttached not.
	^ motionOverlay
]

{ #category : 'examples - transform ownership probe' }
CFMotionTest >> testRelativeTransformAnimationOverwritesAnExternalTransform [
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
CFMotionTest >> testTransformPresentationReleasesOnlyItsOwnTransformation [
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

{ #category : 'examples - transform ownership probe' }
CFMotionTest >> testTransformPresentationsDoNotComposeWithoutASharedChannel [
	<gtExample>
	| space element translationPresentation scalePresentation |
	space := self spaceWithElement.
	element := space root children first.
	translationPresentation := CFMotionTransformPresentation on: element.
	translationPresentation translation: 40 @ 20.
	scalePresentation := CFMotionTransformPresentation on: element.
	scalePresentation scale: 0.5 @ 0.8.
	self assert: translationPresentation ownsCurrentTransformation not.
	self assert: scalePresentation ownsCurrentTransformation.
	translationPresentation translation: 60 @ 30.
	self assert: translationPresentation isActive not.
	self assert: scalePresentation ownsCurrentTransformation.
	^ scalePresentation
]

{ #category : 'examples - transform ownership probe' }
CFMotionTest >> testTransformPresentationsComposeThroughASharedChannel [
	<gtExample>
	| space element applicationTransformation channel translationPresentation scalePresentation |
	space := self spaceWithElement.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	channel := CFMotionTransformChannel on: element.
	translationPresentation := CFMotionTransformPresentation on: element using: channel.
	translationPresentation translation: 40 @ 20.
	scalePresentation := CFMotionTransformPresentation on: element using: channel.
	scalePresentation scale: 0.5 @ 0.8.
	self assert: translationPresentation ownsCurrentTransformation.
	self assert: scalePresentation ownsCurrentTransformation.
	translationPresentation translation: 60 @ 30.
	self assert: translationPresentation isActive.
	self assert: scalePresentation ownsCurrentTransformation.
	scalePresentation release.
	self assert: translationPresentation ownsCurrentTransformation.
	translationPresentation release.
	self assert: element transformation == applicationTransformation.
	^ channel
]

{ #category : 'examples - geometry snapshots' }
CFMotionTest >> testGeometrySnapshotCapturesImmutableBoundsInDeclaredSpace [
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
CFMotionTest >> testGeometrySnapshotConvertsBoundsIntoAnotherParent [
	<gtExample>
	| space source destination element snapshot expectedBounds |
	space := BlSpace new.
	source := BlElement new
		relocate: 20 @ 30;
		size: 200 @ 160;
		yourself.
	destination := BlElement new
		relocate: 360 @ 80;
		size: 200 @ 160;
		yourself.
	element := BlElement new
		relocate: 40 @ 50;
		size: 120 @ 80;
		yourself.
	space root addChild: source.
	space root addChild: destination.
	source addChild: element.
	space pulse.
	snapshot := CFMotionGeometrySnapshot of: element in: space root.
	expectedBounds := BlBounds fromRectangle: element boundsInSpace.
	destination globalBoundsToLocal: expectedBounds.
	self assert: (snapshot boundsIn: destination) equals: expectedBounds asRectangle.
	^ snapshot
]

{ #category : 'examples - geometry snapshots' }
CFMotionTest >> testLayoutComputedEventCapturesAuthoritativeDestinationGeometry [
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
CFMotionTest >> testInverseScalePresentsSourceExtentOverLaidOutDestination [
	<gtExample>
	| space element source destination presentation presented |
	space := self spaceWithElement.
	element := space root children first.
	source := CFMotionGeometrySnapshot of: element in: space root.
	element size: 240 @ 100.
	space pulse.
	destination := CFMotionGeometrySnapshot of: element in: space root.
	presentation := CFMotionTransformPresentation on: element.
	presentation transformOrigin: BlAffineTransformationTopLeftOrigin new.
	presentation scale: (source bounds extent x / destination bounds extent x)
		@ (source bounds extent y / destination bounds extent y).
	presented := CFMotionGeometrySnapshot of: element in: space root.
	self assert: destination bounds extent equals: 240 @ 100.
	self assert: presented bounds extent equals: source bounds extent.
	^ presentation
]

{ #category : 'examples - geometry presentation probe' }
CFMotionTest >> testInverseTransformPresentsSourceBoundsOverMovedAndResizedDestination [
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
	presentation transformOrigin: BlAffineTransformationTopLeftOrigin new.
	presentation scale: (source bounds extent x / destination bounds extent x)
		@ (source bounds extent y / destination bounds extent y).
	presentation translation: source bounds origin - destination bounds origin.
	presented := CFMotionGeometrySnapshot of: element in: space root.
	self assert: destination bounds equals: ((60 @ 20) extent: 240 @ 100).
	self assert: presented bounds equals: source bounds.
	^ presentation
]

{ #category : 'examples - geometry motion' }
CFMotionTest >> testGeometryMotionCompletesAtAuthoritativeLayout [
	<gtExample>
	| space element source destination track motion |
	space := self spaceWithElement.
	element := space root children first.
	source := CFMotionGeometrySnapshot of: element in: space root.
	element
		relocate: 60 @ 20;
		size: 240 @ 100.
	space pulse.
	destination := CFMotionGeometrySnapshot of: element in: space root.
	track := CFMotionGeometryTrack from: source to: destination.
	motion := CFMotion
		coordinator: space cfMotionCoordinator
		tracks: { track }.
	motion duration: 1 milliSeconds.
	motion start.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds equals: source bounds.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds equals: destination bounds.
	self assert: track presentation isActive not.
	^ motion
]

{ #category : 'examples - vertical extent motion' }
CFMotionTest >> testVerticalExtentMotionCompletesAtItsRequestedExtent [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	element := space root children first.
	motion := (element motion
		duration: 1 milliSeconds;
		verticalExtent: 140;
		build) start.
	self assert: motion isRunning.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: element extent y equals: 140.
	^ motion
]

{ #category : 'examples - vertical extent motion' }
CFMotionTest >> testVerticalExtentMotionCancellationPreservesCurrentExtent [
	<gtExample>
	| space element motion presentedExtent |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	motion := (element motion
		duration: 1 second;
		verticalExtent: 140;
		build) start.
	space pulse.
	space time wait: 500 milliSeconds.
	space pulse.
	presentedExtent := element extent.
	motion cancelPreservingCurrentPresentation.
	self assert: motion isCancelled.
	self assert: element extent equals: presentedExtent.
	^ motion
]

{ #category : 'examples - vertical extent motion' }
CFMotionTest >> testVerticalExtentMotionCollapsesToItsRequestedExtent [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	element := space root children first.
	element constraintsDo: [ :constraints |
		constraints vertical exact: 140 ].
	space pulse.
	motion := (element motion
		duration: 1 milliSeconds;
		verticalExtent: 40;
		build) start.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: element extent y equals: 40.
	^ motion
]

{ #category : 'examples - vertical extent motion' }
CFMotionTest >> testVerticalExtentMotionRetargetsTheCurrentMotion [
	<gtExample>
	| space element first second |
	space := self spaceWithElement.
	element := space root children first.
	first := (element motion
		duration: 1 second;
		verticalExtent: 140;
		build)
		start.
	second := first
		retarget: (CFMotionExtentTrack on: element from: element extent to: element extent x @ 100)
		duration: 1 second
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: first == second.
	self assert: second tracks first targetExtent y equals: 100.
	^ second
]

{ #category : 'examples - extent motion' }
CFMotionTest >> testHorizontalExtentMotionPreservesVerticalLayout [
	<gtExample>
	| space element originalHeight motion |
	space := self spaceWithElement.
	element := space root children first.
	originalHeight := element extent y.
	motion := (element motion
		duration: 1 milliSeconds;
		horizontalExtent: 180;
		build) start.
	self assert: motion isRunning.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: element extent x equals: 180.
	self assert: element extent y equals: originalHeight.
	^ motion
]

{ #category : 'examples - extent motion' }
CFMotionTest >> testExtentMotionCompletesAcrossBothAxes [
	<gtExample>
	| space element sourceExtent targetExtent motion |
	space := self spaceWithElement.
	element := space root children first.
	sourceExtent := element extent.
	targetExtent := 180 @ 140.
	motion := (element motion
		duration: 1 milliSeconds;
		extentFrom: sourceExtent to: targetExtent;
		build) start.
	self assert: motion isRunning.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: element extent equals: targetExtent.
	^ motion
]

{ #category : 'examples - vertical extent motion' }
CFMotionTest >> testVerticalExtentTrackReleasesItsExactConstraintAtCompletion [
	<gtExample>
	| space element track motion |
	space := self spaceWithElement.
	element := space root children first.
	track := (CFMotionExtentTrack
		on: element
		from: element extent x @ element extent y
		to: element extent x @ 140)
		fitContentAtDestination.
	motion := CFMotion
		coordinator: space cfMotionCoordinator
		tracks: { track }.
	motion duration: 1 milliSeconds.
	motion start.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: element constraints vertical resizer class name equals: #BlLayoutFitContentResizer.
	^ motion
]

{ #category : 'examples - vertical extent motion' }
CFMotionTest >> testVerticalExtentCoordinatesPreviewOpacityAndReleasesLayout [
	<gtExample>
	| space element preview extentTrack opacityTrack motion |
	space := self spaceWithElement.
	element := space root children first.
	preview := BlElement new
		size: 120 @ 40;
		opacity: 0;
		yourself.
	space root addChild: preview.
	space pulse.
	extentTrack := (CFMotionExtentTrack
		on: element
		from: element extent x @ element extent y
		to: element extent x @ 140)
		fitContentAtDestination.
	opacityTrack := CFMotionPropertyTrack
		on: preview
		property: CFMotionOpacityProperty uniqueInstance
		target: 0.58.
	motion := CFMotion
		coordinator: space cfMotionCoordinator
		tracks: { extentTrack. opacityTrack }.
	motion duration: 1 milliSeconds.
	motion start.
	self finish: motion in: space.
	self assert: motion isCompleted.
	self assert: preview opacity equals: 0.58.
	self assert: element constraints vertical resizer class name equals: #BlLayoutFitContentResizer.
	^ motion
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionCapturesThenCompletesGeometry [
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
	self assert: transaction motion isRunning.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: transaction sourceSnapshots first bounds.
	self finish: transaction motion in: space.
	self assert: transaction motion isCompleted.
	self assert: transaction phase == CFMotionState completed.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: transaction destinationSnapshots first bounds.
	^ transaction
]

{ #category : 'examples - layout convenience' }
CFMotionTest >> testLayoutMotionConveniencesDescribeSingleElementGeometry [
	<gtExample>
	| space element relocation resize geometry |
	space := self spaceWithElement.
	element := space root children first.
	relocation := element motion
		duration: 1 milliSeconds;
		relocate: 60 @ 20.
	space pulse.
	self finish: relocation motion in: space.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: ((60 @ 20) extent: 120 @ 80).
	resize := element motion
		duration: 1 milliSeconds;
		resize: 240 @ 100.
	space pulse.
	self finish: resize motion in: space.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: ((60 @ 20) extent: 240 @ 100).
	geometry := element motion
		duration: 1 milliSeconds;
		geometry: ((120 @ 40) extent: 180 @ 60).
	space pulse.
	self finish: geometry motion in: space.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: ((120 @ 40) extent: 180 @ 60).
	^ { relocation. resize. geometry }
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionInsertsAtTheDeclaredIndex [
	<gtExample>
	| space first second inserted transaction |
	space := BlSpace new.
	first := BlElement new size: 120 @ 80; yourself.
	second := BlElement new size: 120 @ 80; yourself.
	inserted := BlElement new size: 120 @ 80; yourself.
	space root addChildren: { first. second }.
	space pulse.
	transaction := (space root motion
		duration: 1 milliSeconds;
		layout)
		affecting: { first. second };
		insert: inserted into: space root at: 2;
		play.
	self assert: inserted hasParent not.
	space pulse.
	self assert: inserted parent == space root.
	self assert: (space root children at: 1) == first.
	self assert: (space root children at: 2) == inserted.
	self assert: (space root children at: 3) == second.
	self finish: transaction motion in: space.
	self assert: transaction motion isCompleted.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionInsertsAndFadesInTheDeclaredElement [
	<gtExample>
	| space first inserted transaction |
	space := BlSpace new.
	first := BlElement new size: 120 @ 80; yourself.
	inserted := BlElement new size: 120 @ 80; yourself.
	space root addChild: first.
	space pulse.
	transaction := (space root motion
		duration: 1 milliSeconds;
		layout)
		affecting: { first };
		insert: inserted into: space root at: 2;
		fadeIn: inserted;
		play.
	space pulse.
	self assert: transaction motion tracks size equals: 2.
	self assert: inserted opacity equals: 0.0.
	self finish: transaction motion in: space.
	self assert: transaction motion isCompleted.
	self assert: inserted opacity equals: 1.0.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionRemovesTheDeclaredElement [
	<gtExample>
	| space removed survivor transaction |
	space := BlSpace new.
	removed := BlElement new size: 120 @ 80; yourself.
	survivor := BlElement new size: 120 @ 80; yourself.
	space root addChildren: { removed. survivor }.
	space pulse.
	transaction := (space root motion
		duration: 1 milliSeconds;
		layout)
		affecting: { survivor };
		remove: removed;
		play.
	space pulse.
	self assert: removed hasParent not.
	self assert: survivor parent == space root.
	self finish: transaction motion in: space.
	self assert: transaction motion isCompleted.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionExposesCompletedNextLayoutReadiness [
	<gtExample>
	| space element transaction |
	space := self spaceWithElement.
	element := space root children first.
	transaction := (space root motion
		duration: 1 milliSeconds;
		layout)
		affecting: { element };
		mutate: [ element size: 240 @ 100 ];
		play.
	self assert: transaction readiness isNil.
	space pulse.
	self assert: transaction readiness isCompleted.
	self assert: transaction motion isRunning.
	self finish: transaction motion in: space.
	self assert: transaction motion isCompleted.
	^ transaction
]

{ #category : 'examples - readiness' }
CFMotionTest >> testNextLayoutReadinessCancellationRemovesItsObserver [
	<gtExample>
	| space readiness completed |
	space := self spaceWithElement.
	completed := false.
	readiness := CFMotionNextLayoutReadiness
		on: space root
		then: [ completed := true ].
	readiness start.
	self assert: readiness isWaiting.
	readiness cancel.
	self assert: readiness isCancelled.
	space root requestLayout.
	space pulse.
	self assert: completed not.
	^ readiness
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionMovesBetweenParentsThroughDeclaredCoordinateSpace [
	<gtExample>
	| space source destination element transaction sourceBounds destinationBounds |
	space := BlSpace new.
	source := BlElement new
		relocate: 20 @ 30;
		size: 200 @ 160;
		yourself.
	destination := BlElement new
		relocate: 360 @ 80;
		size: 200 @ 160;
		yourself.
	element := BlElement new
		relocate: 40 @ 50;
		size: 120 @ 80;
		yourself.
	space root addChild: source.
	space root addChild: destination.
	source addChild: element.
	space pulse.
	sourceBounds := (CFMotionGeometrySnapshot of: element in: space root) bounds.
	transaction := (space root motion
		duration: 1 milliSeconds;
		layout)
		affecting: { element };
		move: element from: source to: destination;
		play.
	space pulse.
	self assert: transaction motion isRunning.
	self assert: element parent == destination.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds equals: sourceBounds.
	self finish: transaction motion in: space.
	destinationBounds := (CFMotionGeometrySnapshot of: element in: space root) bounds.
	self assert: transaction motion isCompleted.
	self assert: destinationBounds equals: transaction destinationSnapshots first bounds.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionMovesBetweenParentsAtTheDeclaredIndex [
	<gtExample>
	| space source destination element first second transaction |
	space := BlSpace new.
	source := BlElement new
		relocate: 20 @ 30;
		size: 200 @ 160;
		yourself.
	destination := BlElement new
		relocate: 360 @ 80;
		size: 200 @ 160;
		yourself.
	element := BlElement new size: 120 @ 80; yourself.
	first := BlElement new size: 80 @ 40; yourself.
	second := BlElement new size: 80 @ 40; yourself.
	space root addChild: source.
	space root addChild: destination.
	source addChild: element.
	destination addChild: first.
	destination addChild: second.
	space pulse.
	transaction := (space root motion
		duration: 1 milliSeconds;
		layout)
		affecting: { element };
		move: element from: source to: destination at: 2;
		play.
	space pulse.
	self assert: transaction motion isRunning.
	self assert: element parent == destination.
	self assert: (destination children at: 1) == first.
	self assert: (destination children at: 2) == element.
	self assert: (destination children at: 3) == second.
	self finish: transaction motion in: space.
	self assert: transaction motion isCompleted.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testCancellingCrossParentMoveKeepsDestinationMembershipAndPresentation [
	<gtExample>
	| space source destination element transaction presentationBounds |
	space := BlSpace new.
	space time: BlTime simulated.
	source := BlElement new
		relocate: 20 @ 30;
		size: 200 @ 160;
		yourself.
	destination := BlElement new
		relocate: 360 @ 80;
		size: 200 @ 160;
		yourself.
	element := BlElement new
		relocate: 40 @ 50;
		size: 120 @ 80;
		yourself.
	space root addChild: source.
	space root addChild: destination.
	source addChild: element.
	space pulse.
	transaction := (space root motion
		duration: 1 second;
		layout)
		affecting: { element };
		move: element from: source to: destination;
		play.
	space pulse.
	space pulse.
	space time wait: 500 milliSeconds.
	space pulse.
	self assert: transaction motion isRunning.
	presentationBounds := (CFMotionGeometrySnapshot of: element in: space root) bounds.
	transaction cancel.
	self assert: transaction isCancelled.
	self assert: element parent == destination.
	self assertBounds: (CFMotionGeometrySnapshot of: element in: space root) bounds
		closeTo: presentationBounds.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionCancellationRemovesPendingLayoutObserver [
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
	self assert: transaction motion isNil.
	space pulse.
	self assert: transaction motion isNil.
	self assert: transaction destinationSnapshots isEmpty.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionCancellationPreservesRunningGeometry [
	<gtExample>
	| space element transaction presentation |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	transaction := (space root motion
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
	self assert: transaction motion isRunning.
	presentation := CFMotionGeometrySnapshot of: element in: space root.
	transaction cancel.
	self assert: transaction isCancelled.
	self assert: transaction motion isCancelled.
	self assert: transaction phase == CFMotionState cancelled.
	self assert: transaction motion tracks first presentation isActive not.
	self assert: space cfMotionCoordinator activeMotions isEmpty.
	self
		assertBounds: (CFMotionGeometrySnapshot of: element in: space root) bounds
		closeTo: presentation bounds.
	space pulse.
	self
		assertBounds: (CFMotionGeometrySnapshot of: element in: space root) bounds
		closeTo: presentation bounds.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionCoordinatesMultipleParticipants [
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
	self assert: transaction motion tracks size equals: 2.
	self assert: (CFMotionGeometrySnapshot of: first in: space root) bounds
		equals: transaction sourceSnapshots first bounds.
	self assert: (CFMotionGeometrySnapshot of: second in: space root) bounds
		equals: transaction sourceSnapshots second bounds.
	self finish: transaction motion in: space.
	self assert: (CFMotionGeometrySnapshot of: first in: space root) bounds
		equals: transaction destinationSnapshots first bounds.
	self assert: (CFMotionGeometrySnapshot of: second in: space root) bounds
		equals: transaction destinationSnapshots second bounds.
	^ transaction
]

{ #category : 'examples - geometry motion' }
CFMotionTest >> testGeometryMotionComposesWithApplicationTransform [
	<gtExample>
	| space element applicationTransformation source destination track motion |
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
	motion := CFMotion
		coordinator: space cfMotionCoordinator
		tracks: { track }.
	motion duration: 1 milliSeconds.
	motion start.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds equals: source bounds.
	self finish: motion in: space.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds equals: destination bounds.
	self assert: element transformation == applicationTransformation.
	^ motion
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionRetargetsFromCurrentPresentation [
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
	self assert: first motion isCancelled.
	self assert: second motion isRunning.
	self assert: second destinationSnapshots first bounds equals: ((120 @ 40) extent: 180 @ 60).
	self assert: second motion tracks first presentation ownsCurrentTransformation.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: second sourceSnapshots first bounds.
	self assert: space cfMotionCoordinator activeMotions size equals: 1.
	space pulse.
	space time wait: 5 milliSeconds.
	space pulse.
	self assert: second motion isCompleted.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: second destinationSnapshots first bounds.
	^ second
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionRetargetsMultipleParticipantsFromCurrentPresentation [
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
	self assert: first motion isCancelled.
	self assert: second motion isRunning.
	self assert: second destinationSnapshots first bounds equals: ((120 @ 40) extent: 180 @ 60).
	self assert: second destinationSnapshots second bounds equals: ((80 @ 180) extent: 100 @ 120).
	self assert: second motion tracks first presentation ownsCurrentTransformation.
	self assert: second motion tracks second presentation ownsCurrentTransformation.
	self
		assertBounds: (CFMotionGeometrySnapshot of: firstElement in: space root) bounds
		closeTo: second sourceSnapshots first bounds.
	self
		assertBounds: (CFMotionGeometrySnapshot of: secondElement in: space root) bounds
		closeTo: second sourceSnapshots second bounds.
	self assert: space cfMotionCoordinator activeMotions size equals: 1.
	space pulse.
	space time wait: 5 milliSeconds.
	space pulse.
	self assert: second motion isCompleted.
	self assert: (CFMotionGeometrySnapshot of: firstElement in: space root) bounds
		equals: second destinationSnapshots first bounds.
	self assert: (CFMotionGeometrySnapshot of: secondElement in: space root) bounds
		equals: second destinationSnapshots second bounds.
	^ second
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionUsesNestedContainerCoordinateSpace [
	<gtExample>
	| space container element transaction |
	space := BlSpace new.
	container := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 120 @ 80; yourself.
	space root addChild: container.
	container addChild: element.
	container relocate: 50 @ 40.
	element relocate: 20 @ 30.
	space pulse.
	transaction := (container motion
		duration: 1 milliSeconds;
		layout)
		affecting: { element };
		mutate: [
			element
				relocate: 120 @ 90;
				size: 180 @ 60 ];
		play.
	self assert: transaction coordinateSpace == container.
	self assert: transaction sourceSnapshots first bounds equals: ((20 @ 30) extent: 120 @ 80).
	space pulse.
	self assert: transaction motion isRunning.
	self
		assertBounds: (CFMotionGeometrySnapshot of: element in: container) bounds
		closeTo: transaction sourceSnapshots first bounds.
	self finish: transaction motion in: space.
	self assert: transaction motion isCompleted.
	self assert: transaction destinationSnapshots first bounds equals: ((120 @ 90) extent: 180 @ 60).
	self assert: (CFMotionGeometrySnapshot of: element in: container) bounds
		equals: transaction destinationSnapshots first bounds.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionTest >> testLayoutTransactionUsesRootCoordinateSpaceAcrossScaledContainer [
	<gtExample>
	| space container element source transaction |
	space := BlSpace new.
	container := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 120 @ 80; yourself.
	space root addChild: container.
	container addChild: element.
	container
		relocate: 50 @ 40;
		transformDo: [ :aBuilder |
			aBuilder
				topLeftOrigin;
				scaleBy: 2 ].
	element relocate: 20 @ 30.
	space pulse.
	source := CFMotionGeometrySnapshot of: element in: space root.
	transaction := (container motion
		duration: 1 milliSeconds;
		layout)
		coordinateSpace: space root;
		affecting: { element };
		mutate: [
			element
				relocate: 120 @ 90;
				size: 180 @ 60 ];
		play.
	self assert: transaction coordinateSpace == space root.
	self assert: transaction sourceSnapshots first bounds equals: source bounds.
	space pulse.
	self assert: transaction motion isRunning.
	self
		assertBounds: (CFMotionGeometrySnapshot of: element in: space root) bounds
		closeTo: source bounds.
	self finish: transaction motion in: space.
	self assert: transaction motion isCompleted.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: transaction destinationSnapshots first bounds.
	^ transaction
]

{ #category : 'private - running' }
CFMotionTest >> assertBounds: actualBounds closeTo: expectedBounds [
	self assert: (actualBounds origin closeTo: expectedBounds origin precision: 0.0001).
	self assert: (actualBounds corner closeTo: expectedBounds corner precision: 0.0001)
]

{ #category : 'private - running' }
CFMotionTest >> finish: anMotion in: aSpace [
	aSpace pulse.
	5 milliSeconds wait.
	aSpace pulse.
	^ anMotion
]

{ #category : 'examples - frame driver' }
CFMotionTest >> testCoordinatorAdvancesActiveMotionsWithOneSharedFrame [
	<gtExample>
	| space coordinator firstMotion secondMotion |
	space := BlSpace new.
	space time: BlTime simulated.
	coordinator := space cfMotionCoordinator.
	firstMotion := CFMotionFrameRecorder new.
	secondMotion := CFMotionFrameRecorder new.
	coordinator play: firstMotion.
	coordinator play: secondMotion.
	space pulse.
	self assert: firstMotion frames size equals: 1.
	self assert: secondMotion frames size equals: 1.
	self assert: firstMotion frames first == secondMotion frames first.
	self assert: firstMotion frames first elapsedTime equals: 0 milliSeconds.
	self assert: coordinator frameDriver isActive.
	^ coordinator
]

{ #category : 'examples - frame driver' }
CFMotionTest >> testCoordinatorFrameDriverUsesSpaceTime [
	<gtExample>
	| space coordinator motion |
	space := BlSpace new.
	space time: BlTime simulated.
	coordinator := space cfMotionCoordinator.
	motion := CFMotionFrameRecorder new.
	coordinator play: motion.
	space pulse.
	space time wait: 17 milliSeconds.
	space pulse.
	self assert: motion frames size equals: 2.
	self assert: motion frames second elapsedTime equals: 17 milliSeconds.
	self assert: motion frames second absoluteTime equals: space time now.
	^ motion
]

{ #category : 'examples - frame driver' }
CFMotionTest >> testCoordinatorFrameDriverIdlesWithoutActiveMotions [
	<gtExample>
	| space coordinator motion frameCount |
	space := BlSpace new.
	space time: BlTime simulated.
	coordinator := space cfMotionCoordinator.
	motion := CFMotionFrameRecorder new.
	coordinator play: motion.
	space pulse.
	frameCount := motion frames size.
	coordinator removeActiveMotion: motion.
	self assert: coordinator hasActiveMotions not.
	self assert: coordinator frameDriver isActive not.
	space time wait: 17 milliSeconds.
	space pulse.
	self assert: motion frames size equals: frameCount.
	^ coordinator
]

{ #category : 'examples - frame driver' }
CFMotionTest >> testCoordinatorFrameDriverResetsElapsedTimeAfterInactivity [
	<gtExample>
	| space coordinator firstMotion secondMotion |
	space := BlSpace new.
	space time: BlTime simulated.
	coordinator := space cfMotionCoordinator.
	firstMotion := CFMotionFrameRecorder new.
	coordinator play: firstMotion.
	space pulse.
	coordinator removeActiveMotion: firstMotion.
	space time wait: 3 seconds.
	secondMotion := CFMotionFrameRecorder new.
	coordinator play: secondMotion.
	space pulse.
	self assert: secondMotion frames first elapsedTime equals: 0 milliSeconds.
	^ secondMotion
]

{ #category : 'examples - motion lifecycle' }
CFMotionTest >> testMotionAdvancesFromCoordinatorFramesWithoutABlocAnimation [
	<gtExample>
	| space element motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	motion := (CFMotion
		coordinator: space cfMotionCoordinator
		tracks: { CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: 1.0 })
		duration: 100 milliSeconds;
		easing: BlEasing linear;
		start.
	self assert: motion isRunning.
	self assert: space cfMotionCoordinator activeMotions equals: { motion }.
	space pulse.
	space time wait: 40 milliSeconds.
	space pulse.
	self assert: (element opacity closeTo: 0.4).
	self assert: motion elapsedTime equals: 40 milliSeconds.
	space time wait: 60 milliSeconds.
	space pulse.
	self assert: motion isCompleted.
	self assert: space cfMotionCoordinator hasActiveMotions not.
	self assert: (element opacity closeTo: 1.0).
	^ motion
]

{ #category : 'examples - motion lifecycle' }
CFMotionTest >> testMotionPauseAndResumePreservePlaybackPosition [
	<gtExample>
	| space element motion pausedOpacity |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	motion := (CFMotion
		coordinator: space cfMotionCoordinator
		tracks: { CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: 1.0 })
		duration: 100 milliSeconds;
		easing: BlEasing linear;
		start.
	space pulse.
	space time wait: 30 milliSeconds.
	space pulse.
	pausedOpacity := element opacity.
	motion pause.
	self assert: motion isPaused.
	self assert: space cfMotionCoordinator hasActiveMotions not.
	space time wait: 2 seconds.
	space pulse.
	self assert: element opacity equals: pausedOpacity.
	self assert: motion elapsedTime equals: 30 milliSeconds.
	motion resume.
	space pulse.
	self assert: motion elapsedTime equals: 30 milliSeconds.
	space time wait: 20 milliSeconds.
	space pulse.
	self assert: motion elapsedTime equals: 50 milliSeconds.
	self assert: (element opacity closeTo: 0.5).
	^ motion
]

{ #category : 'examples - motion lifecycle' }
CFMotionTest >> testMotionRetainsItsSourceTimeline [
	<gtExample>
	| space element timeline track motion |
	space := self spaceWithElement.
	element := space root children first.
	timeline := CFMotionTimeline new.
	track := (CFMotionTimelineTrack
		on: (CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: 0.0)
		in: timeline)
		duration: 100 milliSeconds.
	motion := CFMotion timeline: timeline coordinator: space cfMotionCoordinator.
	self assert: motion timeline == timeline.
	self assert: motion tracks equals: { track }.
	^ motion
]


{ #category : 'examples - timeline runtime' }
CFMotionTest >> testTimelineOwnsPlaybackPosition [
	<gtExample>
	| space element timeline motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	timeline := CFMotionTimeline new.
	(CFMotionTimelineTrack
		on: (CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: 1.0)
		in: timeline)
		duration: 100 milliSeconds;
		easing: BlEasing linear.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 35 milliSeconds.
	space pulse.
	self assert: timeline elapsedTime equals: 35 milliSeconds.
	self assert: motion elapsedTime equals: timeline elapsedTime.
	self assert: (timeline progress closeTo: 0.35).
	self assert: (element opacity closeTo: 0.35).
	^ timeline
]

{ #category : 'examples - timeline runtime' }
CFMotionTest >> testTimelineEvaluatesOverlappingTracksAtOnePosition [
	<gtExample>
	| space element timeline opacityTrack scaleTrack motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	timeline := CFMotionTimeline new.
	opacityTrack := (CFMotionTimelineTrack
		on: (CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: 1.0)
		in: timeline)
		duration: 100 milliSeconds;
		easing: BlEasing linear.
	scaleTrack := (CFMotionTimelineTrack
		on: (CFMotionScaleTrack on: element from: 1 @ 1 to: 2 @ 2)
		in: timeline)
		starts: 25 milliSeconds after: timeline start;
		duration: 50 milliSeconds;
		easing: BlEasing linear.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 50 milliSeconds.
	space pulse.
	self assert: timeline elapsedTime equals: 50 milliSeconds.
	self assert: (element opacity closeTo: 0.5).
	self assert: (scaleTrack behaviour presentation scale closeTo: 1.5 @ 1.5).
	self assert: motion isRunning.
	^ timeline
]

{ #category : 'examples - timeline runtime' }
CFMotionTest >> testTimelineClampsAtItsResolvedEndAndCompletesMotion [
	<gtExample>
	| space element timeline motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	timeline := CFMotionTimeline new.
	(CFMotionTimelineTrack
		on: (CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: 0.0)
		in: timeline)
		duration: 40 milliSeconds;
		easing: BlEasing linear.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 100 milliSeconds.
	space pulse.
	self assert: timeline elapsedTime equals: 40 milliSeconds.
	self assert: timeline isComplete.
	self assert: motion isCompleted.
	self assert: space cfMotionCoordinator hasActiveMotions not.
	^ motion
]


{ #category : 'examples - behaviours' }
CFMotionTest >> testTimelineTrackEvaluatesBehaviourWithTimelineAndLocalTime [
	<gtExample>
	| space element timeline timelineTrack behaviour motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	behaviour := CFMotionPropertyTrack
		on: element
		property: CFMotionOpacityProperty uniqueInstance
		target: 1.0.
	timeline := CFMotionTimeline new.
	timelineTrack := (CFMotionTimelineTrack on: behaviour in: timeline)
		starts: 20 milliSeconds after: timeline start;
		duration: 100 milliSeconds;
		easing: BlEasing linear.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 70 milliSeconds.
	space pulse.
	self assert: timeline elapsedTime equals: 70 milliSeconds.
	self assert: (element opacity closeTo: 0.5).
	self assert: timelineTrack behaviour == behaviour.
	self assert: motion isRunning.
	^ timelineTrack
]


{ #category : 'examples - transform composition' }
CFMotionTest >> testCoordinatorProvidesOneTransformChannelPerElement [
	<gtExample>
	| space element coordinator firstChannel secondChannel |
	space := self spaceWithElement.
	element := space root children first.
	coordinator := space cfMotionCoordinator.
	firstChannel := coordinator transformChannelFor: element.
	secondChannel := coordinator transformChannelFor: element.
	self assert: firstChannel == secondChannel.
	self assert: firstChannel element == element.
	^ firstChannel
]

{ #category : 'examples - transform composition' }
CFMotionTest >> testIndependentMotionsComposeThroughTheCoordinatorTransformChannel [
	<gtExample>
	| space element coordinator applicationTransformation translation scale translationMotion scaleMotion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element transformDo: [ :builder | builder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	coordinator := space cfMotionCoordinator.
	translation := CFMotionTranslationTrack
		on: element
		from: 0 @ 0
		to: 80 @ 40.
	scale := CFMotionScaleTrack
		on: element
		from: 1 @ 1
		to: 0.5 @ 0.75.
	translationMotion := (CFMotion coordinator: coordinator tracks: { translation })
		duration: 100 milliSeconds;
		easing: BlEasing linear;
		start.
	scaleMotion := (CFMotion coordinator: coordinator tracks: { scale })
		duration: 100 milliSeconds;
		easing: BlEasing linear;
		start.
	space pulse.
	space time wait: 50 milliSeconds.
	space pulse.
	self assert: translation presentation channel == scale presentation channel.
	self assert: translation presentation translation equals: 40 @ 20.
	self assert: scale presentation scale equals: 0.75 @ 0.875.
	self assert: translation presentation ownsCurrentTransformation.
	self assert: scale presentation ownsCurrentTransformation.
	translationMotion cancelAndRestore.
	self assert: translation presentation isActive not.
	self assert: scale presentation ownsCurrentTransformation.
	scaleMotion cancelAndRestore.
	self assert: scale presentation isActive not.
	self assert: element transformation == applicationTransformation.
	^ element
]

{ #category : 'examples - transform composition' }
CFMotionTest >> testTransformChannelPreservesStableRegistrationOrder [
	<gtExample>
	| space element channel first second |
	space := self spaceWithElement.
	element := space root children first.
	channel := space cfMotionCoordinator transformChannelFor: element.
	first := CFMotionTransformPresentation on: element using: channel.
	second := CFMotionTransformPresentation on: element using: channel.
	first scale: 2 @ 2.
	second translation: 30 @ 10.
	self assert: first ownsCurrentTransformation.
	self assert: second ownsCurrentTransformation.
	self assert: channel ownsCurrentTransformation.
	first release.
	self assert: second ownsCurrentTransformation.
	second release.
	self assert: channel isEmpty.
	^ channel
]


{ #category : 'examples - indefinite behaviours' }
CFMotionTest >> testIndefiniteTimelineAdvancesUntilExplicitlyCancelled [
	<gtExample>
	| space timeline behaviour track motion firstEvaluation secondEvaluation thirdEvaluation |
	space := self spaceWithElement.
	space time: BlTime simulated.
	behaviour := CFMotionEvaluationRecorder new.
	timeline := CFMotionTimeline new.
	track := (CFMotionTimelineTrack on: behaviour in: timeline) indefinite.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 40 milliSeconds.
	space pulse.
	space time wait: 60 milliSeconds.
	space pulse.
	firstEvaluation := behaviour evaluations first.
	secondEvaluation := behaviour evaluations second.
	thirdEvaluation := behaviour evaluations third.
	self assert: timeline isIndefinite.
	self assert: timeline duration isNil.
	self assert: timeline progress isNil.
	self assert: timeline isComplete not.
	self assert: motion isRunning.
	self assert: firstEvaluation timelineTime isZero.
	self assert: firstEvaluation localTime isZero.
	self assert: firstEvaluation hasProgress not.
	self assert: secondEvaluation timelineTime equals: 40 milliSeconds.
	self assert: secondEvaluation localTime equals: 40 milliSeconds.
	self assert: secondEvaluation hasProgress not.
	self assert: thirdEvaluation timelineTime equals: 100 milliSeconds.
	self assert: thirdEvaluation localTime equals: 100 milliSeconds.
	self assert: thirdEvaluation hasProgress not.
	motion cancel.
	self assert: motion isCancelled.
	self assert: space cfMotionCoordinator hasActiveMotions not.
	^ track
]

{ #category : 'examples - indefinite behaviours' }
CFMotionTest >> testIndefiniteTrackMayStartAfterFiniteTimelineContent [
	<gtExample>
	| space element timeline finiteTrack behaviour indefiniteTrack motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	timeline := CFMotionTimeline new.
	finiteTrack := (CFMotionTimelineTrack
		on: (CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: 1.0)
		in: timeline)
		duration: 50 milliSeconds;
		easing: BlEasing linear.
	behaviour := CFMotionEvaluationRecorder new.
	indefiniteTrack := (CFMotionTimelineTrack on: behaviour in: timeline)
		startsAt: finiteTrack end;
		indefinite.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 75 milliSeconds.
	space pulse.
	self assert: (element opacity closeTo: 1.0).
	self assert: behaviour evaluations size equals: 1.
	self assert: behaviour evaluations first timelineTime equals: 75 milliSeconds.
	self assert: behaviour evaluations first localTime equals: 25 milliSeconds.
	self assert: motion isRunning.
	motion cancel.
	^ indefiniteTrack
]


{ #category : 'examples - behaviour lifecycle' }
CFMotionTest >> testBehaviourLifecycleSpansPauseAndResume [
	<gtExample>
	| space timeline behaviour motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	behaviour := CFMotionLifecycleRecorder new.
	timeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: behaviour in: timeline) indefinite.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	self assert: behaviour coordinators equals: { space cfMotionCoordinator }.
	self assert: behaviour terminalStates isEmpty.
	space pulse.
	motion pause.
	space time wait: 40 milliSeconds.
	space pulse.
	self assert: behaviour evaluations size equals: 1.
	self assert: behaviour coordinators size equals: 1.
	self assert: behaviour terminalStates isEmpty.
	motion resume.
	space pulse.
	self assert: behaviour evaluations size equals: 2.
	self assert: behaviour coordinators size equals: 1.
	motion cancel.
	self assert: behaviour terminalStates equals: { CFMotionState cancelled }.
	motion cancel.
	self assert: behaviour terminalStates size equals: 1.
	^ behaviour
]

{ #category : 'examples - behaviour lifecycle' }
CFMotionTest >> testFiniteBehaviourEndsWithCompletedState [
	<gtExample>
	| space timeline behaviour motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	behaviour := CFMotionLifecycleRecorder new.
	timeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: behaviour in: timeline)
		duration: 50 milliSeconds;
		easing: BlEasing linear.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 50 milliSeconds.
	space pulse.
	self assert: motion isCompleted.
	self assert: behaviour coordinators size equals: 1.
	self assert: behaviour terminalStates equals: { CFMotionState completed }.
	^ behaviour
]

{ #category : 'examples - cleanup' }
CFMotionTest >> testDetachedPresentationTargetCancelsAndCleansUpItsMotion [
	<gtExample>
	| space element motion key |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	motion := (element motion
		duration: 1 second;
		opacity: 0.0;
		build) start.
	key := motion tracks first propertyKey.
	space pulse.
	self assert: motion isRunning.
	self assert: (space cfMotionCoordinator ownerOf: key) == motion.
	space root removeChild: element.
	space time wait: 40 milliSeconds.
	space pulse.
	self assert: motion isCancelled.
	self assert: (space cfMotionCoordinator ownerOf: key) isNil.
	self assert: space cfMotionCoordinator hasActiveMotions not.
	^ motion
]

{ #category : 'examples - architecture' }
CFMotionTest >> testStopPreservesCurrentPresentationAndTerminatesPlayback [
	<gtExample>
	| space element motion opacityAtStop |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	motion := (element motion
		duration: 100 milliSeconds;
		opacity: 0.0;
		build) start.
	space pulse.
	space time wait: 40 milliSeconds.
	space pulse.
	opacityAtStop := element opacity.
	motion stop.
	space time wait: 40 milliSeconds.
	space pulse.
	self assert: motion isCancelled.
	self assert: (element opacity closeTo: opacityAtStop).
	self assert: space cfMotionCoordinator hasActiveMotions not.
	^ motion
]

{ #category : 'examples - architecture' }
CFMotionTest >> testOneMotionComposesFiniteAndIndefiniteBehaviours [
	<gtExample>
	| space element timeline finiteTrack recorder indefiniteTrack motion |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	timeline := CFMotionTimeline new.
	finiteTrack := (CFMotionTimelineTrack
		on: (CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: 1.0)
		in: timeline)
		duration: 50 milliSeconds;
		easing: BlEasing linear.
	recorder := CFMotionEvaluationRecorder new.
	indefiniteTrack := (CFMotionTimelineTrack on: recorder in: timeline)
		startsAt: finiteTrack end;
		indefinite.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 75 milliSeconds.
	space pulse.
	self assert: (element opacity closeTo: 1.0).
	self assert: recorder evaluations first localTime equals: 25 milliSeconds.
	self assert: motion isRunning.
	motion stop.
	self assert: motion isCancelled.
	^ indefiniteTrack
]

