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

{ #category : 'examples - property motion' }
CFMotionExamples >> scaleCompletesAtThePresentedValue [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	applicationTransformation := element transformation.
	operation := element motion
		duration: 1 milliSeconds;
		scale: 0.5 @ 0.8.
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
	scaleOperation := element motion
		duration: 1 milliSeconds;
		scale: 0.5 @ 0.8.
	self finish: scaleOperation in: space.
	scaleTransformation := element transformation.
	translationOperation := element motion
		duration: 1 milliSeconds;
		translation: 40 @ 20.
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
	first := element motion
		duration: 1 second;
		scale: 0.5 @ 0.8.
	second := element motion
		duration: 1 second;
		scale: 0.8 @ 0.6.
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
	operation := element motion
		duration: 1 milliSeconds;
		rotation: 30.
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
	scaleOperation := element motion
		duration: 1 milliSeconds;
		scale: 0.5 @ 0.8.
	self finish: scaleOperation in: space.
	scaleTransformation := element transformation.
	rotationOperation := element motion
		duration: 1 milliSeconds;
		rotation: 30.
	self finish: rotationOperation in: space.
	self assert: rotationOperation isCompleted.
	self assert: element transformation matrix ~= scaleTransformation matrix.
	^ rotationOperation
]

{ #category : 'examples - effects' }
CFMotionExamples >> fadeInCompletesThroughTheSharedOpacityOperation [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.0.
	operation := element motion
		duration: 1 milliSeconds;
		fadeIn.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: operation tracks first property == CFOpacityMotionProperty uniqueInstance.
	self assert: element opacity equals: 1.0.
	^ operation
]

{ #category : 'examples - effects' }
CFMotionExamples >> fadeOutRetargetsToFadeInThroughTheSharedOpacityOperation [
	<gtExample>
	| space element first second |
	space := self spaceWithElement.
	element := space root children first.
	first := element motion
		duration: 1 second;
		fadeOut.
	element opacity: 0.4.
	second := element motion
		duration: 1 second;
		fadeIn.
	self assert: first == second.
	self assert: second isRunning.
	self assert: second tracks first startValue equals: 0.4.
	self assert: second tracks first targetValue equals: 1.0.
	^ second
]

{ #category : 'examples - effects' }
CFMotionExamples >> appearUsingFadeInSelectsTheFadeRecipe [
	<gtExample>
	| space element appearance |
	space := self spaceWithElement.
	element := BlElement new size: 120 @ 80; yourself.
	appearance := space root motion
		duration: 1 milliSeconds;
		appear: element using: CFMotionEffects fadeIn.
	self assert: appearance effect name equals: #fadeIn.
	self assert: appearance operation tracks first property == CFOpacityMotionProperty uniqueInstance.
	self finish: appearance operation in: space.
	self assert: appearance isCompleted.
	self assert: element opacity equals: 1.0.
	^ appearance
]

{ #category : 'examples - effects' }
CFMotionExamples >> disappearUsingFadeOutSelectsTheFadeRecipe [
	<gtExample>
	| space element disappearance |
	space := self spaceWithElement.
	element := space root children first.
	disappearance := element motion
		duration: 1 milliSeconds;
		disappearUsing: CFMotionEffects fadeOut.
	self assert: disappearance effect name equals: #fadeOut.
	self assert: disappearance operation tracks first property == CFOpacityMotionProperty uniqueInstance.
	self finish: disappearance operation in: space.
	self assert: disappearance isCompleted.
	self assert: element hasParent not.
	^ disappearance
]

{ #category : 'examples - effects' }
CFMotionExamples >> crossFadeUsesOneSharedOperation [
	<gtExample>
	| space outgoing incoming operation |
	space := self spaceWithElement.
	outgoing := space root children first.
	incoming := BlElement new size: 120 @ 80; yourself.
	incoming opacity: 0.0.
	space root addChild: incoming.
	operation := CFMotionEffects
		crossFadeFrom: outgoing
		to: incoming
		duration: 1 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: operation isRunning.
	self assert: operation tracks size equals: 2.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: outgoing opacity equals: 0.0.
	self assert: incoming opacity equals: 1.0.
	^ operation
]

{ #category : 'examples - effects' }
CFMotionExamples >> crossFadeCancellationRestoresBothParticipants [
	<gtExample>
	| space outgoing incoming operation |
	space := self spaceWithElement.
	space time: BlTime simulated.
	outgoing := space root children first.
	incoming := BlElement new size: 120 @ 80; yourself.
	incoming opacity: 0.0.
	space root addChild: incoming.
	operation := CFMotionEffects
		crossFadeFrom: outgoing
		to: incoming
		duration: 1 second
		easing: (BlDecelerateInterpolator factor: 1.4).
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

{ #category : 'examples - effects' }
CFMotionExamples >> scaleInCompletesAndRestoresTheApplicationTransformation [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	operation := CFMotionEffects
		scaleIn: element
		from: 0.5 @ 0.8
		duration: 1 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: operation isRunning.
	self assert: operation tracks first presentation ownsCurrentTransformation.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element transformation == applicationTransformation.
	^ operation
]

{ #category : 'examples - effects' }
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
	scaleOperation := element motion
		duration: 1 second;
		scaleIn.
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
CFMotionExamples >> appearUsingRiseAndFadeInSelectsTheTranslationRecipe [
	<gtExample>
	| space element appearance |
	space := BlSpace new.
	element := BlElement new size: 120 @ 80; yourself.
	appearance := space root motion
		duration: 1 milliSeconds;
		appear: element using: CFMotionEffects riseAndFadeIn.
	self assert: (appearance operation tracks second isKindOf: CFMotionTranslationTrack).
	self finish: appearance operation in: space.
	self assert: appearance isCompleted.
	self assert: element opacity equals: 1.0.
	^ appearance
]

{ #category : 'examples - appearance' }
CFMotionExamples >> configurableRiseAndFadeInRecipeOverridesTheBuilderDuration [
	<gtExample>
	| space element appearance recipe |
	space := BlSpace new.
	element := BlElement new size: 120 @ 80; yourself.
	recipe := CFMotionEffects riseAndFadeIn
		distance: 24;
		duration: 1 milliSeconds;
		yourself.
	appearance := space root motion
		duration: 1 second;
		appear: element using: recipe.
	self assert: appearance operation tracks second sourceTranslation equals: 0 @ 24.
	self finish: appearance operation in: space.
	self assert: appearance isCompleted.
	^ appearance
]

{ #category : 'examples - appearance' }
CFMotionExamples >> configurableScaleAndFadeInRecipeSelectsItsSourceScale [
	<gtExample>
	| space element appearance recipe |
	space := BlSpace new.
	element := BlElement new size: 120 @ 80; yourself.
	recipe := CFMotionEffects scaleAndFadeIn
		scale: 0.5 @ 0.6;
		duration: 1 milliSeconds;
		yourself.
	appearance := space root motion
		appear: element using: recipe.
	self assert: appearance operation tracks second sourceScale equals: 0.5 @ 0.6.
	self finish: appearance operation in: space.
	self assert: appearance isCompleted.
	^ appearance
]

{ #category : 'examples - effects' }
CFMotionExamples >> scaleAndFadeInCoordinatesOpacityAndScale [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	element
		opacity: 0.0;
		transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	operation := CFMotionEffects
		scaleAndFadeIn: element
		from: 0.5 @ 0.8
		duration: 1 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: operation tracks size equals: 2.
	self assert: operation tracks second presentation ownsCurrentTransformation.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element opacity equals: 1.0.
	self assert: element transformation == applicationTransformation.
	^ operation
]

{ #category : 'examples - effects' }
CFMotionExamples >> scaleAndFadeOutCoordinatesOpacityAndScale [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	operation := CFMotionEffects
		scaleAndFadeOut: element
		to: 0.5 @ 0.8
		duration: 1 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: operation tracks size equals: 2.
	self assert: operation tracks second presentation ownsCurrentTransformation.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element opacity equals: 0.0.
	self assert: element transformation == applicationTransformation.
	^ operation
]

{ #category : 'examples - effects' }
CFMotionExamples >> riseAndFadeInCoordinatesOpacityAndTranslation [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	element
		opacity: 0.0;
		transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	operation := CFMotionEffects
		riseAndFadeIn: element
		distance: 24
		duration: 1 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4).
	self assert: operation tracks size equals: 2.
	self assert: operation tracks second presentation ownsCurrentTransformation.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element opacity equals: 1.0.
	self assert: element transformation == applicationTransformation.
	^ operation
]

{ #category : 'examples - effects' }
CFMotionExamples >> fallAndFadeOutCoordinatesOpacityAndTranslation [
	<gtExample>
	| space element applicationTransformation operation |
	space := self spaceWithElement.
	element := space root children first.
	element transformDo: [ :aBuilder | aBuilder translateBy: 20 @ 0 ].
	applicationTransformation := element transformation.
	operation := CFMotionEffects
		fallAndFadeOut: element
		distance: 24
		duration: 1 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4).
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
CFMotionExamples >> disappearUsingFallAndFadeOutSelectsTheTranslationRecipe [
	<gtExample>
	| space element disappearance |
	space := self spaceWithElement.
	element := space root children first.
	disappearance := element motion
		duration: 1 milliSeconds;
		disappearUsing: CFMotionEffects fallAndFadeOut.
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
	self assert: adoption isRunning.
	self assert: adoption previewIndex equals: 2.
	self assert: committed parent == space root.
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
		duration: 1 milliSeconds;
		adopt: preview as: committed from: source.
	self assert: adoption isRunning.
	self assert: adoption overlay isInstalled.
	self assert: preview parent == source.
	self assert: committed parent == destination.
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
CFMotionExamples >> motionAptitudeInstallsAndRemovesItsHandlers [
	<gtExample>
	| space element aptitude |
	space := self spaceWithElement.
	element := space root children first.
	aptitude := CFMotionAptitude new
		hoveredEffect: CFMotionEffects riseAndFadeIn;
		unhoveredEffect: CFMotionEffects fallAndFadeOut;
		yourself.
	element addAptitude: aptitude.
	self assert: aptitude isAttachedToWidget.
	self assert: aptitude hasInstalledHandlers.
	element removeAptitude: aptitude.
	self assert: aptitude isAttachedToWidget not.
	self assert: aptitude hasInstalledHandlers not.
	^ aptitude
]

{ #category : 'examples - aptitude' }
CFMotionExamples >> motionAptitudeCancelsThePreviousInteractionEffect [
	<gtExample>
	| space element aptitude enterOperation leaveOperation |
	space := self spaceWithElement.
	element := space root children first.
	aptitude := CFMotionAptitude new
		hoveredEffect: CFMotionEffects riseAndFadeIn;
		unhoveredEffect: CFMotionEffects fallAndFadeOut;
		yourself.
	element addAptitude: aptitude.
	element dispatchEvent: BlMouseEnterEvent new.
	enterOperation := aptitude activeOperation.
	self assert: enterOperation isRunning.
	element dispatchEvent: BlMouseLeaveEvent new.
	leaveOperation := aptitude activeOperation.
	self assert: enterOperation isCancelled.
	self assert: leaveOperation isRunning.
	element removeAptitude: aptitude.
	self assert: leaveOperation isCancelled.
	^ aptitude
]

{ #category : 'examples - aptitude' }
CFMotionExamples >> motionAptitudeRunsThePressedAndReleasedEffects [
	<gtExample>
	| space element aptitude pressed released |
	space := self spaceWithElement.
	element := space root children first.
	aptitude := CFMotionAptitude new
		pressedEffect: CFMotionEffects compress;
		releasedEffect: CFMotionEffects springBack;
		yourself.
	element addAptitude: aptitude.
	element dispatchEvent: BlMouseDownEvent new.
	pressed := aptitude activeOperation.
	self assert: pressed isRunning.
	element dispatchEvent: BlMouseUpEvent new.
	released := aptitude activeOperation.
	self assert: pressed isCancelled.
	self assert: released isCompleted.
	element removeAptitude: aptitude.
	self assert: released isCompleted.
	^ aptitude
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
	self assert: transaction phase == CFMotionOperationState cancelled.
	self assert: transaction operation tracks first presentation isActive not.
	self assert: space cfMotionCoordinator activeOperations isEmpty.
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
