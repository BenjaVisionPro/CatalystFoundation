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
	operation := (element motion
		duration: 1 milliSeconds;
		opacity: 1.0;
		build) start.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element opacity equals: 1.0.
	^ operation
]

{ #category : 'examples - property motion' }
CFMotionExamples >> scaleCompletesAtThePresentedValue [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	applicationTransformation := element transformation.
	operation := (element motion
		duration: 1 milliSeconds;
		scale: 0.5 @ 0.8;
		build) start.
	self assert: operation isRunning.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: operation tracks first presentation isActive not.
	self assert: element transformation matrix ~= applicationTransformation matrix.
	^ operation
]

{ #category : 'examples - property motion' }
CFMotionExamples >> translationComposesWithASettledScale [
	<gtExample>
	| space element scaleOperation scaleTransformation translationOperation |
	space := self spaceWithElement.
	element := space root children first.
	scaleOperation := (element motion
		duration: 1 milliSeconds;
		scale: 0.5 @ 0.8;
		build) start.
	self finish: scaleOperation in: space.
	scaleTransformation := element transformation.
	translationOperation := (element motion
		duration: 1 milliSeconds;
		translation: 40 @ 20;
		build) start.
	self finish: translationOperation in: space.
	self assert: translationOperation isCompleted.
	self assert: element transformation matrix ~= scaleTransformation matrix.
	^ translationOperation
]

{ #category : 'examples - property motion' }
CFMotionExamples >> scaleRetargetsThroughItsPresentedProperty [
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
CFMotionExamples >> rotationCompletesAtThePresentedValue [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	applicationTransformation := element transformation.
	operation := (element motion
		duration: 1 milliSeconds;
		rotation: 30;
		build) start.
	self assert: operation isRunning.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: operation tracks first presentation rotation equals: 30.
	self assert: element transformation matrix ~= applicationTransformation matrix.
	^ operation
]

{ #category : 'examples - property motion' }
CFMotionExamples >> rotationComposesWithASettledScale [
	<gtExample>
	| space element scaleOperation scaleTransformation rotationOperation |
	space := self spaceWithElement.
	element := space root children first.
	scaleOperation := (element motion
		duration: 1 milliSeconds;
		scale: 0.5 @ 0.8;
		build) start.
	self finish: scaleOperation in: space.
	scaleTransformation := element transformation.
	rotationOperation := (element motion
		duration: 1 milliSeconds;
		rotation: 30;
		build) start.
	self finish: rotationOperation in: space.
	self assert: rotationOperation isCompleted.
	self assert: element transformation matrix ~= scaleTransformation matrix.
	^ rotationOperation
]

{ #category : 'examples - motions' }
CFMotionExamples >> fadeInCompletesThroughTheSharedOpacityOperation [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.0.
	operation := (CFMotionBuilder fadeIn
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: operation tracks first property == CFMotionOpacityProperty uniqueInstance.
	self assert: element opacity equals: 1.0.
	^ operation
]

{ #category : 'examples - motions' }
CFMotionExamples >> fadeOutRetargetsToFadeInThroughTheSharedOpacityOperation [
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
CFMotionExamples >> directNamedFadeInBuildsAndStartsImmediately [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	operation := element motion fadeIn.
	self assert: operation isRunning.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: operation isCompleted.
	self assert: element opacity equals: 1.0.
	^ operation
]

{ #category : 'examples - public API' }
CFMotionExamples >> directNamedFadeOutBuildsAndStartsImmediately [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	operation := element motion fadeOut.
	self assert: operation isRunning.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: operation isCompleted.
	self assert: element opacity equals: 0.0.
	^ operation
]

{ #category : 'examples - public API' }
CFMotionExamples >> directNamedFadeOutCancellationPreservesCurrentPresentation [
	<gtExample>
	| space element operation presentedOpacity |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	operation := element motion fadeOut.
	space pulse.
	space time wait: 90 milliSeconds.
	space pulse.
	presentedOpacity := element opacity.
	operation cancelPreservingCurrentPresentation.
	self assert: operation isCancelled.
	self assert: element opacity equals: presentedOpacity.
	^ operation
]

{ #category : 'examples - public API' }
CFMotionExamples >> namedFadeInConfigurationBlockStartsWhenItReturns [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.0.
	operation := element motion fadeIn: [ :builder |
		builder duration: 1 milliSeconds ].
	self assert: operation isRunning.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element opacity equals: 1.0.
	^ operation
]

{ #category : 'examples - public API' }
CFMotionExamples >> namedMotionRequiresAnAttachedElement [
	<gtExample>
	| element didFail |
	element := BlElement new.
	didFail := false.
	[ element motion fadeOut ] on: Error do: [ :anError | didFail := true ].
	self assert: didFail.
	^ element
]

{ #category : 'examples - public API' }
CFMotionExamples >> customMotionBuildThenStartRemainsExplicit [
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
CFMotionExamples >> directNamedRiseAndFadeInBuildsAndStartsImmediately [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	operation := element motion riseAndFadeIn.
	self assert: operation isRunning.
	self assert: operation tracks size equals: 2.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: operation isCompleted.
	self assert: element opacity equals: 1.0.
	^ operation
]

{ #category : 'examples - public API' }
CFMotionExamples >> directNamedFallAndFadeOutBuildsAndStartsImmediately [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	operation := element motion fallAndFadeOut.
	self assert: operation isRunning.
	self assert: operation tracks size equals: 2.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: operation isCompleted.
	self assert: element opacity equals: 0.0.
	^ operation
]

{ #category : 'examples - public API' }
CFMotionExamples >> directNamedRiseAndFadeInCanRetargetThroughItsReturnedMotion [
	<gtExample>
	| space element operation retargeted |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	operation := element motion riseAndFadeIn.
	space pulse.
	space time wait: 90 milliSeconds.
	space pulse.
	retargeted := operation
		retarget: {
			CFMotionPropertyTrack
				on: element
				property: CFMotionOpacityProperty uniqueInstance
				target: 0.0.
			CFMotionTranslationTrack on: element from: 0 @ 0 to: 0 @ 12 }
		duration: 1 second
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: retargeted == operation description: 'Retargeting must keep the named Motion instance'.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: operation isCompleted description: 'The retargeted named Motion must complete'.
	self assert: (element opacity closeTo: 0.0) description: 'The retargeted named Motion must reach its opacity target'.
	^ operation
]

{ #category : 'examples - public API' }
CFMotionExamples >> directNamedScaleAndFadeInBuildsAndStartsImmediately [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	operation := element motion scaleAndFadeIn.
	self assert: operation isRunning.
	self assert: operation tracks size equals: 2.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: operation isCompleted.
	self assert: element opacity equals: 1.0.
	^ operation
]

{ #category : 'examples - public API' }
CFMotionExamples >> directNamedScaleAndFadeOutBuildsAndStartsImmediately [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	operation := element motion scaleAndFadeOut.
	self assert: operation isRunning.
	self assert: operation tracks size equals: 2.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: operation isCompleted.
	self assert: element opacity equals: 0.0.
	^ operation
]

{ #category : 'examples - public API' }
CFMotionExamples >> directNamedScaleAndFadeInCanRetargetThroughItsReturnedMotion [
	<gtExample>
	| space element operation retargeted |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	element opacity: 0.0.
	operation := element motion scaleAndFadeIn.
	space pulse.
	space time wait: 90 milliSeconds.
	space pulse.
	retargeted := operation
		retarget: {
			CFMotionPropertyTrack
				on: element
				property: CFMotionOpacityProperty uniqueInstance
				target: 0.0.
			CFMotionScaleTrack on: element from: 1 @ 1 to: 0.8 @ 0.8 }
		duration: 1 second
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: retargeted == operation description: 'Retargeting must keep the named Motion instance'.
	space pulse.
	space time wait: 1 second.
	space pulse.
	self assert: operation isCompleted description: 'The retargeted named Motion must complete'.
	self assert: (element opacity closeTo: 0.0) description: 'The retargeted named Motion must reach its opacity target'.
	^ operation
]

{ #category : 'examples - composed motion' }
CFMotionExamples >> composedMotionCompletesAfterItsLastComponent [
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
CFMotionExamples >> cancellingAComposedMotionCancelsAndRestoresEveryComponent [
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
CFMotionExamples >> timelineDerivesItsEndAndPlacesTracksRelativeToIt [
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
CFMotionExamples >> timelinePlacesATrackAfterAnotherTrackEnds [
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
CFMotionExamples >> timelineExecutesFiniteTracksFromOneRootMotion [
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
CFMotionExamples >> appearUsingFadeInBuildsTheFadeMotion [
	<gtExample>
	| space element appearance |
	space := self spaceWithElement.
	element := BlElement new size: 120 @ 80; yourself.
	appearance := space root motion
		duration: 1 milliSeconds;
		appear: element using: CFMotionBuilder fadeIn.
	self assert: appearance motionBuilder class equals: CFMotionBuilder.
	self assert: appearance operation tracks first property == CFMotionOpacityProperty uniqueInstance.
	self finish: appearance operation in: space.
	self assert: appearance isCompleted.
	self assert: element opacity equals: 1.0.
	^ appearance
]

{ #category : 'examples - motions' }
CFMotionExamples >> disappearUsingFadeOutBuildsTheFadeMotion [
	<gtExample>
	| space element disappearance |
	space := self spaceWithElement.
	element := space root children first.
	disappearance := element motion
		duration: 1 milliSeconds;
		disappearUsing: CFMotionBuilder fadeOut.
	self assert: disappearance motionBuilder class equals: CFMotionBuilder.
	self assert: disappearance operation tracks first property == CFMotionOpacityProperty uniqueInstance.
	self finish: disappearance operation in: space.
	self assert: disappearance isCompleted.
	self assert: element hasParent not.
	^ disappearance
]

{ #category : 'examples - motions' }
CFMotionExamples >> scaleInBuilderBuildsAScaleMotion [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	operation := (CFMotionBuilder scaleIn
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: operation tracks first sourceScale equals: 0.8 @ 0.8.
	self finish: operation in: space.
	self assert: operation isCompleted.
	^ operation
]

{ #category : 'examples - motions' }
CFMotionExamples >> scaleOutBuilderBuildsAScaleMotion [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	operation := (CFMotionBuilder scaleOut
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: operation tracks first targetScale equals: 0.8 @ 0.8.
	self finish: operation in: space.
	self assert: operation isCompleted.
	^ operation
]

{ #category : 'examples - motions' }
CFMotionExamples >> crossFadeUsesOneSharedOperation [
	<gtExample>
	| space outgoing incoming operation |
	space := self spaceWithElement.
	outgoing := space root children first.
	incoming := BlElement new size: 120 @ 80; yourself.
	incoming opacity: 0.0.
	space root addChild: incoming.
	operation := (CFMotion
		coordinator: space cfMotionCoordinator
		tracks: {
			CFMotionPropertyTrack on: outgoing property: CFMotionOpacityProperty uniqueInstance target: 0.0.
			CFMotionPropertyTrack on: incoming property: CFMotionOpacityProperty uniqueInstance target: 1.0 })
		duration: 1 milliSeconds;
		easing: (BlDecelerateInterpolator factor: 1.4);
		start.
	self assert: operation isRunning.
	self assert: operation tracks size equals: 2.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: outgoing opacity equals: 0.0.
	self assert: incoming opacity equals: 1.0.
	^ operation
]

{ #category : 'examples - motions' }
CFMotionExamples >> crossFadeCancellationRestoresBothParticipants [
	<gtExample>
	| space outgoing incoming operation |
	space := self spaceWithElement.
	space time: BlTime simulated.
	outgoing := space root children first.
	incoming := BlElement new size: 120 @ 80; yourself.
	incoming opacity: 0.0.
	space root addChild: incoming.
	operation := (CFMotion
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
	self assert: operation isRunning.
	operation cancelAndRestore.
	self assert: operation isCancelled.
	self assert: outgoing opacity equals: 1.0.
	self assert: incoming opacity equals: 0.0.
	^ operation
]

{ #category : 'examples - motions' }
CFMotionExamples >> scaleInCompletesAndRestoresTheApplicationTransformation [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	operation := (CFMotionBuilder scaleIn
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: operation isRunning.
	self assert: operation tracks first presentation ownsCurrentTransformation.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element transformation == applicationTransformation.
	^ operation
]

{ #category : 'examples - motions' }
CFMotionExamples >> scaleInComposesWithRunningLayoutGeometry [
	<gtExample>
	| space element transaction scaleOperation |
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
	self assert: transaction operation isRunning.
	scaleOperation := (CFMotionBuilder scaleIn
		element: element;
		duration: 1 second;
		build)
		start.
	space time wait: 500 milliSeconds.
	space pulse.
	self assert: scaleOperation isRunning.
	self assert: transaction operation tracks first presentation ownsCurrentTransformation.
	self assert: scaleOperation tracks first presentation ownsCurrentTransformation.
	scaleOperation cancelAndRestore.
	self assert: scaleOperation isCancelled.
	self assert: transaction operation tracks first presentation ownsCurrentTransformation.
	space time wait: 1 second.
	space pulse.
	self assert: transaction operation isCompleted.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: transaction destinationSnapshots first bounds.
	^ { transaction. scaleOperation }
]

{ #category : 'examples - appearance' }
CFMotionExamples >> appearInsertsThenScalesAndFadesIn [
	<gtExample>
	| space element appearance |
	space := BlSpace new.
	element := BlElement new size: 120 @ 80; yourself.
	appearance := space root motion
		duration: 1 milliSeconds;
		appear: element.
	self assert: appearance isRunning.
	self assert: element parent == space root.
	self assert: element visibility isVisible.
	self assert: element opacity equals: 0.0.
	self assert: appearance operation tracks size equals: 2.
	self assert: appearance operation tracks second presentation ownsCurrentTransformation.
	self finish: appearance operation in: space.
	self assert: appearance isCompleted.
	self assert: element parent == space root.
	self assert: element opacity equals: 1.0.
	^ appearance
]

{ #category : 'examples - appearance' }
CFMotionExamples >> appearInsertsAtTheDeclaredIndexThenScalesAndFadesIn [
	<gtExample>
	| space first second inserted appearance |
	space := BlSpace new.
	first := BlElement new size: 120 @ 80; yourself.
	second := BlElement new size: 120 @ 80; yourself.
	inserted := BlElement new size: 120 @ 80; yourself.
	space root addChild: first.
	space root addChild: second.
	appearance := space root motion
		duration: 1 milliSeconds;
		appear: inserted at: 2.
	self assert: appearance isRunning.
	self assert: (space root children at: 1) == first.
	self assert: (space root children at: 2) == inserted.
	self assert: (space root children at: 3) == second.
	self finish: appearance operation in: space.
	self assert: appearance isCompleted.
	self assert: inserted opacity equals: 1.0.
	^ appearance
]

{ #category : 'examples - appearance' }
CFMotionExamples >> appearUsingRiseAndFadeInBuildsTheTranslationMotion [
	<gtExample>
	| space element appearance |
	space := BlSpace new.
	element := BlElement new size: 120 @ 80; yourself.
	appearance := space root motion
		duration: 1 milliSeconds;
		appear: element using: CFMotionBuilder riseAndFadeIn.
	self assert: (appearance operation tracks second isKindOf: CFMotionTranslationTrack).
	self finish: appearance operation in: space.
	self assert: appearance isCompleted.
	self assert: element opacity equals: 1.0.
	^ appearance
]

{ #category : 'examples - appearance' }
CFMotionExamples >> riseAndFadeInBuilderBuildsTheStandardTranslation [
	<gtExample>
	| space element appearance |
	space := BlSpace new.
	element := BlElement new size: 120 @ 80; yourself.
	appearance := space root motion
		duration: 1 milliSeconds;
		appear: element using: CFMotionBuilder riseAndFadeIn.
	self assert: appearance operation tracks second sourceTranslation equals: 0 @ 12.
	self finish: appearance operation in: space.
	self assert: appearance isCompleted.
	^ appearance
]

{ #category : 'examples - appearance' }
CFMotionExamples >> scaleAndFadeInBuilderBuildsTheStandardSourceScale [
	<gtExample>
	| space element appearance |
	space := BlSpace new.
	element := BlElement new size: 120 @ 80; yourself.
	appearance := space root motion
		duration: 1 milliSeconds;
		appear: element using: CFMotionBuilder scaleAndFadeIn.
	self assert: appearance operation tracks second sourceScale equals: 0.8 @ 0.8.
	self finish: appearance operation in: space.
	self assert: appearance isCompleted.
	^ appearance
]

{ #category : 'examples - motions' }
CFMotionExamples >> scaleAndFadeInCoordinatesOpacityAndScale [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	element
		opacity: 0.0;
		transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	operation := (CFMotionBuilder scaleAndFadeIn
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: operation tracks size equals: 2.
	self assert: operation tracks second presentation ownsCurrentTransformation.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element opacity equals: 1.0.
	self assert: element transformation == applicationTransformation.
	^ operation
]

{ #category : 'examples - motions' }
CFMotionExamples >> scaleAndFadeOutCoordinatesOpacityAndScale [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	operation := (CFMotionBuilder scaleAndFadeOut
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: operation tracks size equals: 2.
	self assert: operation tracks second presentation ownsCurrentTransformation.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element opacity equals: 0.0.
	self assert: element transformation == applicationTransformation.
	^ operation
]

{ #category : 'examples - motions' }
CFMotionExamples >> riseAndFadeInCoordinatesOpacityAndTranslation [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	element
		opacity: 0.0;
		transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	operation := (CFMotionBuilder riseAndFadeIn
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: operation tracks size equals: 2.
	self assert: operation tracks second presentation ownsCurrentTransformation.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element opacity equals: 1.0.
	self assert: element transformation == applicationTransformation.
	^ operation
]

{ #category : 'examples - motions' }
CFMotionExamples >> fallAndFadeOutCoordinatesOpacityAndTranslation [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	operation := (CFMotionBuilder fallAndFadeOut
		element: element;
		duration: 1 milliSeconds;
		build)
		start.
	self assert: operation tracks size equals: 2.
	self assert: operation tracks second presentation ownsCurrentTransformation.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element opacity equals: 0.0.
	self assert: element transformation == applicationTransformation.
	^ operation
]

{ #category : 'examples - appearance' }
CFMotionExamples >> disappearScalesAndFadesOutThenRemoves [
	<gtExample>
	| space element disappearance |
	space := self spaceWithElement.
	element := space root children first.
	disappearance := element motion
		duration: 1 milliSeconds;
		disappear.
	self assert: disappearance isRunning.
	self assert: element parent == space root.
	self assert: disappearance operation tracks size equals: 2.
	self finish: disappearance operation in: space.
	self assert: disappearance isCompleted.
	self assert: element hasParent not.
	^ disappearance
]

{ #category : 'examples - appearance' }
CFMotionExamples >> disappearUsingFallAndFadeOutBuildsTheTranslationMotion [
	<gtExample>
	| space element disappearance |
	space := self spaceWithElement.
	element := space root children first.
	disappearance := element motion
		duration: 1 milliSeconds;
		disappearUsing: CFMotionBuilder fallAndFadeOut.
	self assert: (disappearance operation tracks second isKindOf: CFMotionTranslationTrack).
	self finish: disappearance operation in: space.
	self assert: disappearance isCompleted.
	self assert: element hasParent not.
	^ disappearance
]

{ #category : 'examples - adoption' }
CFMotionExamples >> adoptionReplacesThePreviewAtItsDeclaredIndex [
	<gtExample>
	| space first preview last committed adoption |
	space := BlSpace new.
	first := BlElement new size: 120 @ 80; yourself.
	preview := BlElement new size: 120 @ 80; yourself.
	last := BlElement new size: 120 @ 80; yourself.
	committed := BlElement new size: 120 @ 80; yourself.
	space root addChildren: { first. preview. last }.
	adoption := space root motion
		duration: 1 milliSeconds;
		adopt: preview as: committed.
	self assert: adoption isAwaitingLayout.
	self assert: adoption previewIndex equals: 2.
	self assert: committed parent == space root.
	space pulse.
	self assert: adoption isRunning.
	self finish: adoption operation in: space.
	self assert: adoption isCompleted.
	self assert: preview hasParent not.
	self assert: committed parent == space root.
	self assert: (space root children at: 2) == committed.
	^ adoption
]

{ #category : 'examples - adoption' }
CFMotionExamples >> cancellingAdoptionRestoresThePreviewAndRemovesTheCommittedElement [
	<gtExample>
	| space preview committed adoption |
	space := self spaceWithElement.
	preview := space root children first.
	committed := BlElement new size: 120 @ 80; yourself.
	adoption := space root motion
		duration: 1 second;
		adopt: preview as: committed.
	adoption cancel.
	self assert: adoption isCancelled.
	self assert: preview parent == space root.
	self assert: committed hasParent not.
	self assert: preview opacity equals: 1.0.
	^ adoption
]

{ #category : 'examples - adoption' }
CFMotionExamples >> adoptionMovesAcrossParentsAndReleasesItsOverlay [
	<gtExample>
	| space source destination preview committed adoption geometryTrack |
	space := BlSpace new.
	source := BlElement new size: 240 @ 160; relocate: 20 @ 30; yourself.
	destination := BlElement new size: 240 @ 160; relocate: 260 @ 180; yourself.
	preview := BlElement new size: 120 @ 80; yourself.
	committed := BlElement new size: 120 @ 80; yourself.
	space root addChildren: { source. destination }.
	source addChild: preview.
	space pulse.
	adoption := destination motion
		duration: 1 milliSeconds;
		adopt: preview as: committed from: source.
	self assert: adoption isAwaitingLayout.
	self assert: adoption overlay isInstalled.
	self assert: preview parent == source.
	self assert: committed parent == destination.
	space pulse.
	self assert: adoption isRunning.
	geometryTrack := adoption operation tracks detect: [ :each | each isKindOf: CFMotionGeometryTrack ].
	self assert: geometryTrack sourceSnapshot == adoption sourceSnapshot.
	self assert: geometryTrack destinationSnapshot == adoption destinationSnapshot.
	self assert: geometryTrack startTranslation isZero not.
	self finish: adoption operation in: space.
	self assert: adoption isCompleted.
	self assert: preview hasParent not.
	self assert: committed parent == destination.
	self assert: adoption overlay isInstalled not.
	^ adoption
]

{ #category : 'examples - adoption' }
CFMotionExamples >> cancellingCrossParentAdoptionRestoresThePreviewAndReleasesItsOverlay [
	<gtExample>
	| space source destination preview committed adoption |
	space := BlSpace new.
	source := BlElement new size: 240 @ 160; yourself.
	destination := BlElement new size: 240 @ 160; yourself.
	preview := BlElement new size: 120 @ 80; yourself.
	committed := BlElement new size: 120 @ 80; yourself.
	space root addChildren: { source. destination }.
	source addChild: preview.
	space pulse.
	adoption := destination motion
		duration: 1 second;
		adopt: preview as: committed from: source.
	adoption cancel.
	self assert: adoption isCancelled.
	self assert: preview parent == source.
	self assert: preview opacity equals: 1.0.
	self assert: committed hasParent not.
	self assert: adoption overlay isInstalled not.
	^ adoption
]

{ #category : 'examples - aptitude' }
CFMotionExamples >> motionButtonAptitudeInstallsAndRemovesItsHandlers [
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
CFMotionExamples >> motionButtonAptitudeRetargetsWhilePressed [
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
CFMotionExamples >> motionButtonAptitudeReturnsToRestOnRelease [
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
CFMotionExamples >> motionButtonAptitudeHoldsTheCompressedPresentation [
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
CFMotionExamples >> motionButtonAptitudeReleasesTheHeldPresentation [
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

{ #category : 'examples - appearance' }
CFMotionExamples >> cancellingDisappearPreservesMembershipAndPresentation [
	<gtExample>
	| space element disappearance |
	space := self spaceWithElement.
	element := space root children first.
	disappearance := element motion
		duration: 1 second;
		disappear.
	element opacity: 0.4.
	disappearance cancel.
	self assert: disappearance isCancelled.
	self assert: element parent == space root.
	self assert: element opacity equals: 1.0.
	self assert: disappearance operation tracks second presentation isActive not.
	^ disappearance
]


{ #category : 'examples - retargeting' }
CFMotionExamples >> coordinatorRetargetKeepsTheOwningMotion [
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
CFMotionExamples >> coordinatorRetargetStartsAMotionForAnUnownedProperty [
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
CFMotionExamples >> opacityRetargetsFromCurrentPresentation [
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
CFMotionExamples >> opacityReplacementKeepsOneOwner [
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
CFMotionExamples >> opacityCancellationPreservesCurrentPresentation [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.2.
	operation := (element motion opacity: 1.0; build) start.
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
	operation := (element motion opacity: 0.2; build) start.
	key := CFMotionPropertyKey
		element: element
		property: CFMotionOpacityProperty uniqueInstance.
	operation cancelSettlingAtEnd.
	self assert: (space cfMotionCoordinator ownerOf: key) isNil.
	self assert: space cfMotionCoordinator activeMotions isEmpty.
	^ operation
]

{ #category : 'examples - inspection' }
CFMotionExamples >> opacityOperationIsInspectable [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	operation := (element motion opacity: 0.2; build) start.
	self assert: operation coordinator == space cfMotionCoordinator.
	self assert: operation tracks size equals: 1.
	self assert: operation trace entries isNotEmpty.
	^ operation
]

{ #category : 'examples - structural motion' }
CFMotionExamples >> overlayTracksItsReferenceAndCleansUp [
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
CFMotionExamples >> motionOverlayTracksANestedReferenceAndCleansUp [
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

{ #category : 'examples - transform ownership probe' }
CFMotionExamples >> transformPresentationsDoNotComposeWithoutASharedChannel [
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
CFMotionExamples >> transformPresentationsComposeThroughASharedChannel [
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
CFMotionExamples >> geometrySnapshotConvertsBoundsIntoAnotherParent [
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
	presentation transformOrigin: BlAffineTransformationTopLeftOrigin new.
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
	presentation transformOrigin: BlAffineTransformationTopLeftOrigin new.
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
	operation := CFMotion
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

{ #category : 'examples - vertical extent motion' }
CFMotionExamples >> verticalExtentMotionCompletesAtItsRequestedExtent [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	operation := (element motion
		duration: 1 milliSeconds;
		verticalExtent: 140;
		build) start.
	self assert: operation isRunning.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element extent y equals: 140.
	^ operation
]

{ #category : 'examples - vertical extent motion' }
CFMotionExamples >> verticalExtentMotionCancellationPreservesCurrentExtent [
	<gtExample>
	| space element operation presentedExtent |
	space := self spaceWithElement.
	space time: BlTime simulated.
	element := space root children first.
	operation := (element motion
		duration: 1 second;
		verticalExtent: 140;
		build) start.
	space pulse.
	space time wait: 500 milliSeconds.
	space pulse.
	presentedExtent := element extent.
	operation cancelPreservingCurrentPresentation.
	self assert: operation isCancelled.
	self assert: element extent equals: presentedExtent.
	^ operation
]

{ #category : 'examples - vertical extent motion' }
CFMotionExamples >> verticalExtentMotionCollapsesToItsRequestedExtent [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	element constraintsDo: [ :constraints |
		constraints vertical exact: 140 ].
	space pulse.
	operation := (element motion
		duration: 1 milliSeconds;
		verticalExtent: 40;
		build) start.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element extent y equals: 40.
	^ operation
]

{ #category : 'examples - vertical extent motion' }
CFMotionExamples >> verticalExtentMotionRetargetsTheCurrentOperation [
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
CFMotionExamples >> horizontalExtentMotionPreservesVerticalLayout [
	<gtExample>
	| space element originalHeight operation |
	space := self spaceWithElement.
	element := space root children first.
	originalHeight := element extent y.
	operation := (element motion
		duration: 1 milliSeconds;
		horizontalExtent: 180;
		build) start.
	self assert: operation isRunning.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element extent x equals: 180.
	self assert: element extent y equals: originalHeight.
	^ operation
]

{ #category : 'examples - extent motion' }
CFMotionExamples >> extentMotionCompletesAcrossBothAxes [
	<gtExample>
	| space element sourceExtent targetExtent operation |
	space := self spaceWithElement.
	element := space root children first.
	sourceExtent := element extent.
	targetExtent := 180 @ 140.
	operation := (element motion
		duration: 1 milliSeconds;
		extentFrom: sourceExtent to: targetExtent;
		build) start.
	self assert: operation isRunning.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element extent equals: targetExtent.
	^ operation
]

{ #category : 'examples - vertical extent motion' }
CFMotionExamples >> verticalExtentTrackReleasesItsExactConstraintAtCompletion [
	<gtExample>
	| space element track operation |
	space := self spaceWithElement.
	element := space root children first.
	track := (CFMotionExtentTrack
		on: element
		from: element extent x @ element extent y
		to: element extent x @ 140)
		fitContentAtDestination.
	operation := CFMotion
		coordinator: space cfMotionCoordinator
		tracks: { track }.
	operation duration: 1 milliSeconds.
	operation start.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element constraints vertical resizer class name equals: #BlLayoutFitContentResizer.
	^ operation
]

{ #category : 'examples - vertical extent motion' }
CFMotionExamples >> verticalExtentCoordinatesPreviewOpacityAndReleasesLayout [
	<gtExample>
	| space element preview extentTrack opacityTrack operation |
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
	operation := CFMotion
		coordinator: space cfMotionCoordinator
		tracks: { extentTrack. opacityTrack }.
	operation duration: 1 milliSeconds.
	operation start.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: preview opacity equals: 0.58.
	self assert: element constraints vertical resizer class name equals: #BlLayoutFitContentResizer.
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
	self assert: transaction phase == CFMotionState completed.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: transaction destinationSnapshots first bounds.
	^ transaction
]

{ #category : 'examples - layout convenience' }
CFMotionExamples >> layoutMotionConveniencesDescribeSingleElementGeometry [
	<gtExample>
	| space element relocation resize geometry |
	space := self spaceWithElement.
	element := space root children first.
	relocation := element motion
		duration: 1 milliSeconds;
		relocate: 60 @ 20.
	space pulse.
	self finish: relocation operation in: space.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: ((60 @ 20) extent: 120 @ 80).
	resize := element motion
		duration: 1 milliSeconds;
		resize: 240 @ 100.
	space pulse.
	self finish: resize operation in: space.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: ((60 @ 20) extent: 240 @ 100).
	geometry := element motion
		duration: 1 milliSeconds;
		geometry: ((120 @ 40) extent: 180 @ 60).
	space pulse.
	self finish: geometry operation in: space.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: ((120 @ 40) extent: 180 @ 60).
	^ { relocation. resize. geometry }
]

{ #category : 'examples - layout transaction' }
CFMotionExamples >> layoutTransactionInsertsAtTheDeclaredIndex [
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
	self finish: transaction operation in: space.
	self assert: transaction operation isCompleted.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionExamples >> layoutTransactionInsertsAndFadesInTheDeclaredElement [
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
	self assert: transaction operation tracks size equals: 2.
	self assert: inserted opacity equals: 0.0.
	self finish: transaction operation in: space.
	self assert: transaction operation isCompleted.
	self assert: inserted opacity equals: 1.0.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionExamples >> layoutTransactionRemovesTheDeclaredElement [
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
	self finish: transaction operation in: space.
	self assert: transaction operation isCompleted.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionExamples >> layoutTransactionExposesCompletedNextLayoutReadiness [
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
	self assert: transaction operation isRunning.
	self finish: transaction operation in: space.
	self assert: transaction operation isCompleted.
	^ transaction
]

{ #category : 'examples - readiness' }
CFMotionExamples >> nextLayoutReadinessCancellationRemovesItsObserver [
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
CFMotionExamples >> layoutTransactionMovesBetweenParentsThroughDeclaredCoordinateSpace [
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
	self assert: transaction operation isRunning.
	self assert: element parent == destination.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds equals: sourceBounds.
	self finish: transaction operation in: space.
	destinationBounds := (CFMotionGeometrySnapshot of: element in: space root) bounds.
	self assert: transaction operation isCompleted.
	self assert: destinationBounds equals: transaction destinationSnapshots first bounds.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionExamples >> layoutTransactionMovesBetweenParentsAtTheDeclaredIndex [
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
	self assert: transaction operation isRunning.
	self assert: element parent == destination.
	self assert: (destination children at: 1) == first.
	self assert: (destination children at: 2) == element.
	self assert: (destination children at: 3) == second.
	self finish: transaction operation in: space.
	self assert: transaction operation isCompleted.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionExamples >> cancellingCrossParentMoveKeepsDestinationMembershipAndPresentation [
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
	self assert: transaction operation isRunning.
	presentationBounds := (CFMotionGeometrySnapshot of: element in: space root) bounds.
	transaction cancel.
	self assert: transaction isCancelled.
	self assert: element parent == destination.
	self assertBounds: (CFMotionGeometrySnapshot of: element in: space root) bounds
		closeTo: presentationBounds.
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
CFMotionExamples >> layoutTransactionCancellationPreservesRunningGeometry [
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
	self assert: transaction operation isRunning.
	presentation := CFMotionGeometrySnapshot of: element in: space root.
	transaction cancel.
	self assert: transaction isCancelled.
	self assert: transaction operation isCancelled.
	self assert: transaction phase == CFMotionState cancelled.
	self assert: transaction operation tracks first presentation isActive not.
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
	operation := CFMotion
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
	self assert: space cfMotionCoordinator activeMotions size equals: 1.
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
	self assert: space cfMotionCoordinator activeMotions size equals: 1.
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

{ #category : 'examples - layout transaction' }
CFMotionExamples >> layoutTransactionUsesNestedContainerCoordinateSpace [
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
	self assert: transaction operation isRunning.
	self
		assertBounds: (CFMotionGeometrySnapshot of: element in: container) bounds
		closeTo: transaction sourceSnapshots first bounds.
	self finish: transaction operation in: space.
	self assert: transaction operation isCompleted.
	self assert: transaction destinationSnapshots first bounds equals: ((120 @ 90) extent: 180 @ 60).
	self assert: (CFMotionGeometrySnapshot of: element in: container) bounds
		equals: transaction destinationSnapshots first bounds.
	^ transaction
]

{ #category : 'examples - layout transaction' }
CFMotionExamples >> layoutTransactionUsesRootCoordinateSpaceAcrossScaledContainer [
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
	self assert: transaction operation isRunning.
	self
		assertBounds: (CFMotionGeometrySnapshot of: element in: space root) bounds
		closeTo: source bounds.
	self finish: transaction operation in: space.
	self assert: transaction operation isCompleted.
	self assert: (CFMotionGeometrySnapshot of: element in: space root) bounds
		equals: transaction destinationSnapshots first bounds.
	^ transaction
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

{ #category : 'examples - frame driver' }
CFMotionExamples >> coordinatorAdvancesActiveMotionsWithOneSharedFrame [
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
CFMotionExamples >> coordinatorFrameDriverUsesSpaceTime [
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
CFMotionExamples >> coordinatorFrameDriverIdlesWithoutActiveMotions [
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
CFMotionExamples >> coordinatorFrameDriverResetsElapsedTimeAfterInactivity [
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
CFMotionExamples >> motionAdvancesFromCoordinatorFramesWithoutABlocAnimation [
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
CFMotionExamples >> motionPauseAndResumePreservePlaybackPosition [
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
CFMotionExamples >> motionRetainsItsSourceTimeline [
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
CFMotionExamples >> timelineOwnsPlaybackPosition [
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
CFMotionExamples >> timelineEvaluatesOverlappingTracksAtOnePosition [
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
CFMotionExamples >> timelineClampsAtItsResolvedEndAndCompletesMotion [
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
CFMotionExamples >> timelineTrackEvaluatesBehaviourWithTimelineAndLocalTime [
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
CFMotionExamples >> coordinatorProvidesOneTransformChannelPerElement [
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
CFMotionExamples >> independentMotionsComposeThroughTheCoordinatorTransformChannel [
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
CFMotionExamples >> transformChannelPreservesStableRegistrationOrder [
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
CFMotionExamples >> indefiniteTimelineAdvancesUntilExplicitlyCancelled [
	<gtExample>
	| space timeline behaviour track motion firstEvaluation secondEvaluation |
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
	self assert: timeline isIndefinite.
	self assert: timeline duration isNil.
	self assert: timeline progress isNil.
	self assert: timeline isComplete not.
	self assert: motion isRunning.
	self assert: firstEvaluation timelineTime equals: 40 milliSeconds.
	self assert: firstEvaluation localTime equals: 40 milliSeconds.
	self assert: firstEvaluation hasProgress not.
	self assert: secondEvaluation timelineTime equals: 100 milliSeconds.
	self assert: secondEvaluation localTime equals: 100 milliSeconds.
	motion cancel.
	self assert: motion isCancelled.
	self assert: space cfMotionCoordinator hasActiveMotions not.
	^ track
]

{ #category : 'examples - indefinite behaviours' }
CFMotionExamples >> indefiniteTrackMayStartAfterFiniteTimelineContent [
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
