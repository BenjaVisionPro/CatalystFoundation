Class {
	#name : 'CFConfigurationEditorElement',
	#superclass : 'BrFrame',
	#instVars : [
		'configuration',
		'configurationContentElement',
		'activeTargetChoice',
		'library',
		'librarySidebarElement',
		'planner',
		'previewElement',
		'selectedConfiguration',
		'inspectorElement',
		'libraryVisible',
		'libraryToggleButton',
		'dragAsset',
		'dragAssessment',
		'activeInsertionIndex',
		'placementProvider',
		'placementHysteresis',
		'animations',
		'activePlacementCandidate',
		'previewConfiguration',
		'dropCompletionToken',
		'previewVisible',
		'previewItemsElement',
		'previewAxis',
		'configurationSurfaceElement',
		'hoverExpandedConfigurationNode',
		'configurationsToExpandAfterRefresh'
	],
	#category : 'BVC-Foundation-Config-UI-ConfigurationEditor',
	#package : 'BVC-Foundation-Config-UI-ConfigurationEditor'
}

{ #category : 'private - building' }
CFConfigurationEditorElement >> addAssetDropHandler [
	self addEventHandler: (BlDropHandler new
		acceptDomainObjectsSuchThat: [ :anObject |
			anObject isKindOf: CFConfigurationAsset ];
		whenDragOverDo: [ :anEvent |
			anEvent items size = 1 ifTrue: [
				self
					showPlacementPreviewFor: anEvent items first domainObject
					at: anEvent position ] ];
		whenDragLeftDo: [ :anEvent | self hidePlacementPreview ];
		whenDroppedDo: [ :anEvent |
			anEvent domainObjects size = 1
				ifTrue: [ self completeDropOfAsset: anEvent domainObjects first at: anEvent position ]
				ifFalse: [ self clearPlacementPreview ] ];
		yourself)
]

{ #category : 'private - applying' }
CFConfigurationEditorElement >> applyAsset: anAsset at: aPoint [
	| assessment candidate |
	configuration ifNil: [ ^ nil ].
	(self isPointOverVisibleLibrarySidebar: aPoint) ifTrue: [ ^ nil ].
	assessment := planner assessAsset: anAsset in: configuration.
	candidate := self placementCandidateIn: assessment at: aPoint keeping: activePlacementCandidate.
	candidate ifNil: [ ^ assessment ].
	candidate targetChoice placement insertionIndex: candidate insertionIndex.
	self clearPlacementPreview.
	(CFConfigurationPlan
		asset: anAsset
		targetChoice: candidate targetChoice
		planner: planner) apply.
	self refreshConfigurationContent.
	self refreshConfigurationInspector.
	^ assessment
]

{ #category : 'private - applying' }
CFConfigurationEditorElement >> applyAssetWhenPlacementIsUnambiguous: anAsset [
	| assessment |
	configuration ifNil: [ ^ nil ].
	assessment := planner assessAsset: anAsset in: configuration.
	assessment hasSingleTargetChoice ifFalse: [ ^ assessment ].
	(CFConfigurationPlan
		asset: anAsset
		targetChoice: assessment targetChoices first
		planner: planner) apply.
	self refreshConfigurationContent.
	self refreshConfigurationInspector.
	^ assessment
]

{ #category : 'accessing' }
CFConfigurationEditorElement >> configuration [
	^ configuration
]

{ #category : 'accessing' }
CFConfigurationEditorElement >> configuration: aConfiguration [
	configuration := aConfiguration.
	selectedConfiguration := nil.
	self hideConfigurationInspector.
	self refreshConfigurationContent
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> clearPlacementPreview [
	self collapseHoverExpandedConfigurationForm.
	dropCompletionToken := nil.
	activeTargetChoice := nil.
	activeInsertionIndex := nil.
	activePlacementCandidate := nil.
	dragAsset := nil.
	dragAssessment := nil.
	previewConfiguration := nil.
	previewVisible := false.
	animations stopAll.
	self detachPlacementPreview
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> detachPlacementPreview [
	previewElement ifNotNil: [ :anElement | anElement removeFromParent ].
	previewElement := nil.
	previewItemsElement := nil.
	previewAxis := nil.
	previewVisible := false
]

{ #category : 'private - building' }
CFConfigurationEditorElement >> createConfigurationContentElement [
	configurationContentElement := BrFrame new
		matchParent;
		layout: BlFrameLayout new;
		background: (Color r: 0.93 g: 0.95 b: 0.98 alpha: 0.82);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 14);
		border: (BlBorder paint: (Color black alpha: 0.14) width: 1);
		yourself.
	^ configurationContentElement
]

{ #category : 'private - building' }
CFConfigurationEditorElement >> createConfigurationSurfaceElement [
	configurationSurfaceElement := BrFrame new
		hExact: self configurationSurfaceWidth;
		vFitContent;
		layout: BlFrameLayout new;
		margin: (BlInsets top: 34 left: 0 bottom: 34 right: 0);
		padding: (BlInsets all: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 16);
		background: (Color white alpha: 0.96);
		border: (BlBorder paint: (Color black alpha: 0.14) width: 1);
		aptitude: BrShadowAptitude new beLarge;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		yourself.
	^ configurationSurfaceElement
]


{ #category : 'private - building' }
CFConfigurationEditorElement >> createEmptyConfigurationSurfaceElement [
	configurationSurfaceElement := BrFrame new
		hExact: self configurationSurfaceWidth;
		vFitContent;
		layout: BlFrameLayout new;
		margin: (BlInsets top: 34 left: 0 bottom: 34 right: 0);
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		yourself.
	^ configurationSurfaceElement
]


{ #category : 'private - building' }
CFConfigurationEditorElement >> createEmptyConfigurationElement [
	| emptyElement |

	emptyElement := BrFrame new
		hMatchParent;
		vExact: 180;
		layout: BlFrameLayout new;
		yourself.
	emptyElement userData at: #cfConfigurationEditorEmptyState put: true.
	^ emptyElement
]

{ #category : 'private - geometry' }
CFConfigurationEditorElement >> configurationSurfaceWidth [
	^ 580
]

{ #category : 'private - building' }
CFConfigurationEditorElement >> createLibrarySidebar [
	librarySidebarElement := CFConfigurationLibrarySidebarElement new
		library: library;
		whenAssetActivatedDo: [ :anAsset |
			self applyAssetWhenPlacementIsUnambiguous: anAsset ];
		margin: (BlInsets all: 12);
		constraintsDo: [ :c |
			c frame horizontal alignLeft.
			c frame vertical alignTop ];
		yourself.
	^ librarySidebarElement
]

{ #category : 'private - building' }
CFConfigurationEditorElement >> createLibraryToggleButton [
	| label |
	libraryToggleButton := BrButton new
		hExact: 34;
		vExact: 34;
		layout: BlFrameLayout new;
		geometry: BlCircleGeometry new;
		background: (Color white alpha: 0.92);
		border: (BlBorder paint: (Color black alpha: 0.12) width: 1);
		aptitude: BrShadowAptitude new;
		action: [ :anElement | self toggleLibrarySidebar ];
		margin: (BlInsets top: 16 left: 316 bottom: 0 right: 0);
		constraintsDo: [ :c |
			c frame horizontal alignLeft.
			c frame vertical alignTop ];
		yourself.
	label := BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFont;
			fontSize: 16;
			foreground: (Color black alpha: 0.70);
			yourself);
		text: '☰';
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		yourself.
	libraryToggleButton addChild: label.
	^ libraryToggleButton
]

{ #category : 'private - building' }
CFConfigurationEditorElement >> createInspectorElementFor: aConfiguration [
	| content editorElement |
	inspectorElement := BrFrame new
		hExact: self inspectorWidth;
		vMatchParent;
		layout: BlFrameLayout new;
		padding: (BlInsets all: 1);
		margin: (BlInsets all: 12);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 13);
		background: (Color white alpha: 0.96);
		border: (BlBorder paint: (Color black alpha: 0.16) width: 1);
		aptitude: BrShadowAptitude new beLarge;
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignTop ];
		yourself.
	content := BrFrame new
		matchParent;
		layout: BlFrameLayout new;
		yourself.
	editorElement := aConfiguration asGtMagritteViewModel asElement
		margin: (BlInsets all: 8);
		yourself.
	content addChild: editorElement.
	inspectorElement
		addChild: content;
		addChild: self createInspectorCloseButton.
	^ inspectorElement
]

{ #category : 'private - building' }
CFConfigurationEditorElement >> createInspectorCloseButton [
	| button label |
	button := BrButton new
		hExact: 28;
		vExact: 28;
		layout: BlFrameLayout new;
		geometry: BlCircleGeometry new;
		background: (Color black alpha: 0.08);
		border: BlBorder empty;
		action: [ :anElement | self hideConfigurationInspector ];
		margin: (BlInsets top: 10 left: 0 bottom: 0 right: 10);
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignTop ];
		yourself.
	label := BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFont;
			fontSize: 16;
			foreground: (Color black alpha: 0.65);
			yourself);
		text: '×';
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		yourself.
	button addChild: label.
	^ button
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> fieldElementForPlacement: aPlacement [
	^ configurationContentElement
		allChildrenBreadthFirstDetect: [ :each |
			(each isKindOf: CFConfigurationRelationElement) and: [
				each memento model == aPlacement memento model
					and: [ each description = aPlacement description ] ] ]
		ifFound: [ :each | each ]
		ifNone: [ nil ]
]

{ #category : 'private - building' }
CFConfigurationEditorElement >> hideConfigurationInspector [
	inspectorElement ifNotNil: [ :anElement | anElement removeFromParent ].
	inspectorElement := nil
]

{ #category : 'private - tools' }
CFConfigurationEditorElement >> hideLibrarySidebar [
	libraryVisible := false.
	librarySidebarElement ifNotNil: [ :anElement |
		anElement visibility: BlVisibility gone ]
]

{ #category : 'private - building' }
CFConfigurationEditorElement >> createPlacementProvider [
	^ CFLinearConfigurationPlacementProvider new
]

{ #category : 'initialization' }
CFConfigurationEditorElement >> initialize [
	super initialize.
	library := CFConfigurationLibrary discovered.
	planner := CFConfigurationPlanner new.
	placementProvider := self createPlacementProvider.
	placementHysteresis := CFConfigurationPlacementHysteresis new.
	animations := CFAnimationCoordinator on: self.
	previewVisible := false.
	libraryVisible := true.
	configurationsToExpandAfterRefresh := IdentitySet new.
	self
		matchParent;
		layout: BlFrameLayout new;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 14);
		background: Color transparent;
		border: BlBorder empty.
	self
		addChild: self createConfigurationContentElement;
		addChild: self createLibrarySidebar;
		addChild: self createLibraryToggleButton;
		addAssetDropHandler.
	self refreshConfigurationContent
]

{ #category : 'private - geometry' }
CFConfigurationEditorElement >> inspectorWidth [
	^ 360
]

{ #category : 'accessing' }
CFConfigurationEditorElement >> library [
	^ library
]

{ #category : 'accessing' }
CFConfigurationEditorElement >> library: aConfigurationLibrary [
	library := aConfigurationLibrary.
	librarySidebarElement ifNotNil: [ :anElement | anElement library: library ]
]

{ #category : 'accessing' }
CFConfigurationEditorElement >> librarySidebarElement [
	^ librarySidebarElement
]

{ #category : 'updating' }
CFConfigurationEditorElement >> refreshConfigurationContent [
	| surface nodeElement visitedConfigurations |
	self clearPlacementPreview.
	configurationContentElement ifNil: [ ^ self ].
	configurationContentElement removeChildren.
	surface := configuration
		ifNil: [ self createEmptyConfigurationSurfaceElement ]
		ifNotNil: [ self createConfigurationSurfaceElement ].
	configuration ifNil: [
		surface addChild: self createEmptyConfigurationElement.
		configurationContentElement addChild: surface.
		^ self ].
	visitedConfigurations := IdentitySet new.
	visitedConfigurations add: configuration.
	nodeElement := CFConfigurationNodeElement
		configuration: configuration
		visited: visitedConfigurations
		expandedConfigurations: configurationsToExpandAfterRefresh copy
		selected: selectedConfiguration
		whenSelected: [ :aConfiguration |
			self selectConfiguration: aConfiguration ].
	configurationsToExpandAfterRefresh removeAll.
	nodeElement constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	surface addChild: nodeElement.
	configurationContentElement addChild: surface
]

{ #category : 'updating' }
CFConfigurationEditorElement >> refreshConfigurationInspector [
	selectedConfiguration ifNil: [ ^ self hideConfigurationInspector ].
	self showConfigurationInspectorFor: selectedConfiguration
]

{ #category : 'private - tools' }
CFConfigurationEditorElement >> showLibrarySidebar [
	libraryVisible := true.
	librarySidebarElement ifNotNil: [ :anElement |
		anElement visibility: BlVisibility visible ]
]

{ #category : 'private - selection' }
CFConfigurationEditorElement >> selectConfiguration: aConfiguration [
	selectedConfiguration := aConfiguration.
	self refreshConfigurationContent.
	self showConfigurationInspectorFor: aConfiguration
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> showPlacementPreviewFor: anAsset at: aPoint [
	| assessment candidate |
	(self isPointOverVisibleLibrarySidebar: aPoint)
		ifTrue: [ ^ self hidePlacementPreview ].
	configuration ifNil: [ ^ self showRootPlacementPreviewFor: anAsset at: aPoint ].
	assessment := dragAsset == anAsset
		ifTrue: [ dragAssessment ]
		ifFalse: [
			dragAsset := anAsset.
			previewConfiguration := anAsset materialize.
			dragAssessment := planner assessAsset: anAsset in: configuration ].
	(self expandCollapsedConfigurationFormAt: aPoint for: assessment asset: anAsset)
		ifTrue: [ ^ self ].
	candidate := self placementCandidateIn: assessment at: aPoint keeping: activePlacementCandidate.
	candidate ifNil: [ ^ self hidePlacementPreview ].
	(candidate samePlacementAs: activePlacementCandidate) ifTrue: [ ^ self ].
	activePlacementCandidate := candidate.
	activeTargetChoice := candidate targetChoice.
	activeInsertionIndex := candidate insertionIndex.
	candidate targetChoice placement insertionIndex: candidate insertionIndex.
	self showDropPreviewAt: candidate
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> showRootPlacementPreviewFor: anAsset at: aPoint [
	(self isPointOverConfigurationContent: aPoint)
		ifFalse: [ ^ self hidePlacementPreview ].
	dragAsset == anAsset ifFalse: [
		self detachPlacementPreview.
		dragAsset := anAsset.
		dragAssessment := nil.
		previewConfiguration := anAsset materialize ].
	previewElement ifNil: [ self createDropPreviewElement ].
	previewElement parent == configurationSurfaceElement ifFalse: [
		previewElement removeFromParent.
		previewElement
			hMatchParent;
			vFitContent;
			constraintsDo: [ :c |
				c accountByLayout.
				c frame horizontal alignCenter.
				c frame vertical alignCenter ].
		configurationSurfaceElement addChild: previewElement ].
	previewItemsElement := nil.
	previewAxis := nil.
	previewVisible := true.
	self fadeDropPreviewIn
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> hidePlacementPreview [
	| previewBounds preview beforeGeometry affectedItems |
	self collapseHoverExpandedConfigurationForm.
	activeTargetChoice := nil.
	activeInsertionIndex := nil.
	activePlacementCandidate := nil.
	previewVisible := false.
	previewElement ifNil: [ ^ self ].
	affectedItems := IdentitySet new.
	previewItemsElement ifNotNil: [ affectedItems add: previewItemsElement ].
	beforeGeometry := self capturePresentedGeometryInItems: affectedItems.
	previewBounds := self boundsOf: previewElement inLocalCoordinatesOf: self.
	animations stop: #placementLayout.
	self clearPlacementTransformsInItems: affectedItems.
	preview := previewElement.
	previewElement removeFromParent.
	previewItemsElement := nil.
	self addChild: previewElement.
	previewElement
		hExact: previewBounds width;
		vExact: previewBounds height;
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: previewBounds origin.
	self postponePlacementAnimationFrom: beforeGeometry inItems: affectedItems.
	self animatePreviewOpacityTo: 0 then: [
		(previewElement == preview and: [ previewVisible ~= true ])
			ifTrue: [ self detachPlacementPreview ] ]
]
{ #category : 'private - previewing' }
CFConfigurationEditorElement >> showDropPreviewAt: aCandidate [
	| relation items insertionIndex beforeGeometry affectedItems |
	previewElement ifNil: [ self createDropPreviewElement ].
	relation := self fieldElementForPlacement: aCandidate targetChoice placement.
	relation ifNil: [ ^ self hidePlacementPreview ].
	items := self relationItemsElementIn: relation.
	items ifNil: [ ^ self hidePlacementPreview ].
	insertionIndex := aCandidate insertionIndex max: 1.
	affectedItems := IdentitySet new.
	previewItemsElement ifNotNil: [ affectedItems add: previewItemsElement ].
	affectedItems add: items.
	beforeGeometry := self capturePresentedGeometryInItems: affectedItems.
	animations stop: #placementLayout.
	self clearPlacementTransformsInItems: affectedItems.
	previewItemsElement := items.
	previewAxis := aCandidate axis.
	self measurePreviewForCurrentTarget.
	self placePreviewIn: items at: insertionIndex axis: previewAxis.
	previewVisible := true.
	self postponePlacementAnimationFrom: beforeGeometry inItems: affectedItems.
	self fadeDropPreviewIn
]
{ #category : 'private - previewing' }
CFConfigurationEditorElement >> createDropPreviewElement [
	| visited |
	visited := IdentitySet new.
	visited add: previewConfiguration.
	previewElement := CFConfigurationNodeElement
		configuration: previewConfiguration
		visited: visited
		selected: nil
		whenSelected: [ :ignored | ].
	previewElement
		opacity: 0;
		preventMouseEvents.
	previewElement userData at: #cfConfigurationEditorPlacementPreview put: true
]
{ #category : 'private - previewing' }
CFConfigurationEditorElement >> fadeDropPreviewIn [
	previewElement ifNil: [ ^ self ].
	self animatePreviewOpacityTo: 0.58 then: nil
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> fadeDropPreviewOut [
	| element |
	previewElement ifNil: [ ^ self ].
	element := previewElement.
	self animatePreviewOpacityTo: 0 then: [
		(previewElement == element and: [ previewVisible ~= true ])
			ifTrue: [ self detachPlacementPreview ] ]
]


{ #category : 'private - animations' }
CFConfigurationEditorElement >> capturePresentedGeometryInItems: ignoredItemElements [
	| geometry |
	geometry := IdentityDictionary new.
	self placementAnimationElements do: [ :each |
		geometry at: each put: (self boundsOf: each inLocalCoordinatesOf: self) ].
	^ geometry
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> clearPlacementTransformsInItems: ignoredItemElements [
	self placementAnimationElements do: [ :each |
		each transformation: BlElementLocalTransformation new ]
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> postponePlacementAnimationFrom: beforeGeometry inItems: ignoredItemElements [
	self spaceDo: [ :aSpace |
		aSpace universe postpone: [
			self animatePlacementFrom: beforeGeometry inItems: ignoredItemElements ] ]
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> animatePlacementFrom: beforeGeometry inItems: ignoredItemElements [
	| elements globalDeltas transitions animation |
	elements := self placementAnimationElements.
	globalDeltas := IdentityDictionary new.
	elements do: [ :each |
		beforeGeometry
			at: each
			ifPresent: [ :oldBounds |
				| newBounds delta |
				newBounds := self boundsOf: each inLocalCoordinatesOf: self.
				delta := oldBounds origin - newBounds origin.
				delta isZero ifFalse: [ globalDeltas at: each put: delta ] ] ].

	transitions := OrderedCollection new.
	globalDeltas keysAndValuesDo: [ :each :globalDelta |
		| ancestor ancestorDelta localDelta |
		ancestor := self nearestAnimatedConfigurationAncestorOf: each in: globalDeltas.
		ancestorDelta := ancestor
			ifNil: [ 0 @ 0 ]
			ifNotNil: [ globalDeltas at: ancestor ].
		localDelta := globalDelta - ancestorDelta.
		localDelta isZero ifFalse: [ transitions add: each -> localDelta ] ].

	transitions ifEmpty: [ ^ self ].
	self applyPlacementTransitions: transitions progress: 0.0.
	animation := BlNumberTransition new
		from: 0.0;
		to: 1.0;
		duration: 180 milliSeconds;
		easing: (BlDecelerateInterpolator factor: 1.4);
		onStepDo: [ :progress | self applyPlacementTransitions: transitions progress: progress ];
		yourself.
	animation onFinishedDo: [ self clearPlacementTransitionElements: transitions ].
	animations play: animation named: #placementLayout
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> placementAnimationElements [
	| result |
	result := OrderedCollection new.
	configurationContentElement ifNotNil: [
		self
			collectConfigurationNodeElementsFrom: configurationContentElement
			into: result ].
	previewElement ifNotNil: [
		(result includes: previewElement) ifFalse: [ result add: previewElement ] ].
	^ result
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> collectConfigurationNodeElementsFrom: anElement into: aCollection [
	(anElement isKindOf: CFConfigurationNodeElement) ifTrue: [
		aCollection add: anElement ].
	anElement children do: [ :each |
		self collectConfigurationNodeElementsFrom: each into: aCollection ]
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> nearestAnimatedConfigurationAncestorOf: anElement in: globalDeltas [
	| ancestor |
	ancestor := anElement parent.
	[ ancestor notNil ] whileTrue: [
		((ancestor isKindOf: CFConfigurationNodeElement)
			and: [ globalDeltas includesKey: ancestor ]) ifTrue: [ ^ ancestor ].
		ancestor := ancestor parent ].
	^ nil
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> applyPlacementTransitions: transitions progress: progress [
	transitions do: [ :association |
		| remaining |
		remaining := association value * (1.0 - progress).
		association key transformDo: [ :builder | builder translateBy: remaining ] ]
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> clearPlacementTransitionElements: transitions [
	transitions do: [ :association |
		association key transformation: BlElementLocalTransformation new ]
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> animatePreviewOpacityTo: targetOpacity then: completionBlock [
	| element start animation |
	previewElement ifNil: [ ^ completionBlock ifNotNil: [ completionBlock value ] ].
	element := previewElement.
	start := element opacity.
	start = targetOpacity ifTrue: [ ^ completionBlock ifNotNil: [ completionBlock value ] ].
	animation := BlNumberTransition new
		from: start;
		to: targetOpacity;
		duration: 100 milliSeconds;
		easing: (BlDecelerateInterpolator factor: 1);
		onStepDo: [ :each | element opacity: each ];
		yourself.
	completionBlock ifNotNil: [
		animation onFinishedDo: [
			previewElement == element ifTrue: [ completionBlock value ] ] ].
	animations retarget: [ animation ] named: #dropPreviewOpacity
]

{ #category : 'private - dropping' }
CFConfigurationEditorElement >> completeRootDropOfAsset: anAsset at: aPoint [
	| token rootConfiguration |
	(self isPointOverVisibleLibrarySidebar: aPoint) ifTrue: [ ^ self clearPlacementPreview ].
	(self isPointOverConfigurationContent: aPoint) ifFalse: [ ^ self clearPlacementPreview ].
	dragAsset == anAsset ifFalse: [
		dragAsset := anAsset.
		dragAssessment := nil.
		previewConfiguration := anAsset materialize ].
	self showRootPlacementPreviewFor: anAsset at: aPoint.
	rootConfiguration := previewConfiguration.
	rootConfiguration initializeInContext: (CFConfigurationContext
		memento: nil
		description: nil
		operationKind: #initializeRoot
		insertionIndex: nil).
	token := Object new.
	dropCompletionToken := token.
	self animatePreviewOpacityTo: 1 then: [
		dropCompletionToken == token ifTrue: [
			configuration := rootConfiguration.
			selectedConfiguration := nil.
			self adoptRootPlacementPreviewAs: rootConfiguration.
			self refreshConfigurationInspector ] ]
]

{ #category : 'private - dropping' }
CFConfigurationEditorElement >> completeDropOfAsset: anAsset at: aPoint [
	| assessment candidate token committedConfiguration |
	configuration ifNil: [ ^ self completeRootDropOfAsset: anAsset at: aPoint ].
	(self isPointOverVisibleLibrarySidebar: aPoint)
		ifTrue: [ ^ self clearPlacementPreview ].
	assessment := dragAsset == anAsset
		ifTrue: [ dragAssessment ]
		ifFalse: [ planner assessAsset: anAsset in: configuration ].
	candidate := self placementCandidateIn: assessment at: aPoint keeping: activePlacementCandidate.
	candidate ifNil: [ ^ self clearPlacementPreview ].
	dragAsset == anAsset ifFalse: [
		dragAsset := anAsset.
		dragAssessment := assessment.
		previewConfiguration := anAsset materialize ].
	activePlacementCandidate := candidate.
	activeTargetChoice := candidate targetChoice.
	activeInsertionIndex := candidate insertionIndex.
	candidate targetChoice placement insertionIndex: candidate insertionIndex.
	self preserveHoverExpandedConfigurationForm.
	self showDropPreviewAt: candidate.
	token := Object new.
	dropCompletionToken := token.
	self animatePreviewOpacityTo: 1 then: [
		dropCompletionToken == token ifTrue: [
			committedConfiguration := (CFConfigurationPlan
				asset: anAsset
				targetChoice: candidate targetChoice
				planner: planner)
				applyConfiguration: previewConfiguration.
			self adoptPlacementPreviewAs: committedConfiguration.
			self refreshConfigurationInspector ] ]
]



{ #category : 'private - dropping' }
CFConfigurationEditorElement >> adoptPlacementPreviewAs: aConfiguration [
	| adoptedElement |
	adoptedElement := previewElement.
	adoptedElement ifNil: [ ^ self ].
	adoptedElement userData
		removeKey: #cfConfigurationEditorPlacementPreview
		ifAbsent: [ ].
	adoptedElement
		commitPreviewWithConfiguration: aConfiguration
		selected: selectedConfiguration
		whenSelected: [ :aSelectedConfiguration |
			self selectConfiguration: aSelectedConfiguration ];
		opacity: 1.
	self clearAdoptedPlacementPreviewState
]

{ #category : 'private - dropping' }
CFConfigurationEditorElement >> adoptRootPlacementPreviewAs: aConfiguration [
	| adoptedElement |
	adoptedElement := previewElement.
	adoptedElement ifNil: [ ^ self ].
	configurationSurfaceElement children copy do: [ :each |
		each == adoptedElement ifFalse: [ each removeFromParent ] ].
	adoptedElement userData
		removeKey: #cfConfigurationEditorPlacementPreview
		ifAbsent: [ ].
	adoptedElement
		commitPreviewWithConfiguration: aConfiguration
		selected: selectedConfiguration
		whenSelected: [ :aSelectedConfiguration |
			self selectConfiguration: aSelectedConfiguration ];
		opacity: 1.
	self clearAdoptedPlacementPreviewState
]

{ #category : 'private - dropping' }
CFConfigurationEditorElement >> clearAdoptedPlacementPreviewState [
	dropCompletionToken := nil.
	activeTargetChoice := nil.
	activeInsertionIndex := nil.
	activePlacementCandidate := nil.
	dragAsset := nil.
	dragAssessment := nil.
	previewConfiguration := nil.
	previewVisible := false.
	previewElement := nil.
	previewItemsElement := nil.
	previewAxis := nil
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> pointAnimationFrom: startPoint to: targetPoint onStep: aBlock [
	| animation |
	animation := BlNumberTransition new
		from: 0.0;
		to: 1.0;
		duration: 140 milliSeconds;
		easing: (BlDecelerateInterpolator factor: 1);
		onStepDo: [ :progress |
			aBlock value: ((startPoint x + ((targetPoint x - startPoint x) * progress))
				@ (startPoint y + ((targetPoint y - startPoint y) * progress))) ];
		yourself.
	animation onFinishedDo: [ aBlock value: targetPoint ].
	^ animation
]



{ #category : 'private - previewing' }
CFConfigurationEditorElement >> placePreviewIn: anItemsElement at: anIndex axis: anAxis [
	| rawIndex |
	previewAxis := anAxis.
	previewElement removeFromParent.
	previewElement constraintsDo: [ :c | c accountByLayout ].
	previewItemsElement := anItemsElement.
	rawIndex := self
		rawChildIndexForCommittedInsertionIndex: anIndex
		in: anItemsElement.
	anItemsElement addChild: previewElement at: rawIndex
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> rawChildIndexForCommittedInsertionIndex: anIndex in: anItemsElement [
	| committedCount rawIndex |
	committedCount := 0.
	rawIndex := 1.
	anItemsElement children do: [ :each |
		(each userData at: #cfConfigurationEditorPlacementPreview ifAbsent: [ false ])
			ifFalse: [
				committedCount := committedCount + 1.
				committedCount = anIndex ifTrue: [ ^ rawIndex ] ].
		rawIndex := rawIndex + 1 ].
	^ anItemsElement childrenCount + 1
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> measurePreviewForCurrentTarget [
	| targetWidth |
	previewElement ifNil: [ ^ self ].
	targetWidth := self previewTargetWidth.
	targetWidth <= 0 ifTrue: [
		self error: 'The configuration preview target hierarchy must have a positive width before preview layout.' ].
	previewAxis = #horizontal
		ifTrue: [ previewElement hExact: targetWidth ]
		ifFalse: [ previewElement hMatchParent ].
	previewElement vFitContent
]


{ #category : 'private - previewing' }
CFConfigurationEditorElement >> previewTargetWidth [
	| element width |
	element := previewItemsElement.
	[ element notNil ] whileTrue: [
		width := element extent x.
		width > 0 ifTrue: [ ^ width ].
		element == self ifTrue: [ ^ 0 ].
		element := element parent ].
	^ 0
]

{ #category : 'private - building' }
CFConfigurationEditorElement >> showConfigurationInspectorFor: aConfiguration [
	self hideConfigurationInspector.
	self addChild: (self createInspectorElementFor: aConfiguration)
]

{ #category : 'private - tools' }
CFConfigurationEditorElement >> toggleLibrarySidebar [
	libraryVisible
		ifTrue: [ self hideLibrarySidebar ]
		ifFalse: [ self showLibrarySidebar ]
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> boundsOf: anElement inLocalCoordinatesOf: aReferenceElement [
	| origin corner |
	origin := aReferenceElement
		globalPointToLocal: (anElement localPointToGlobal: 0 @ 0).
	corner := aReferenceElement
		globalPointToLocal: (anElement localPointToGlobal: anElement extent).
	^ origin corner: corner
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> forcePreviewLayout [
	configurationContentElement forceLayout.
	self forceLayout
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> forcePreviewLayoutInItems: itemElements [
	configurationContentElement forceLayout.
	self forceLayout.
	itemElements do: [ :items |
		items ifNotNil: [
			items parent ifNotNil: [ :parent | parent forceLayout ].
			items forceLayout ] ]
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> relationItemsElementIn: aRelationElement [
	^ aRelationElement relationItemsElement
]

{ #category : 'private - geometry' }
CFConfigurationEditorElement >> isPointOverConfigurationContent: aPoint [
	configurationContentElement ifNil: [ ^ false ].
	^ ((configurationContentElement bounds inParent: self) asRectangle containsPoint: aPoint)
]

{ #category : 'private - geometry' }
CFConfigurationEditorElement >> isPointOverVisibleLibrarySidebar: aPoint [
	libraryVisible ifFalse: [ ^ false ].
	librarySidebarElement ifNil: [ ^ false ].
	^ ((librarySidebarElement bounds inParent: self) asRectangle containsPoint: aPoint)
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> placementCandidateIn: anAssessment at: aPoint keeping: aCandidate [
	^ placementHysteresis
		chooseFrom: (placementProvider candidatesFor: anAssessment in: self)
		at: aPoint
		keeping: aCandidate
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> targetChoiceIn: anAssessment at: aPoint [
	| candidate |
	candidate := self placementCandidateIn: anAssessment at: aPoint keeping: nil.
	candidate ifNil: [ ^ nil ].
	candidate targetChoice placement insertionIndex: candidate insertionIndex.
	^ candidate targetChoice
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> expandCollapsedConfigurationFormAt: aPoint for: anAssessment asset: anAsset [
	| node |
	node := self collapsedConfigurationNodeAt: aPoint for: anAssessment.
	node ifNil: [ ^ false ].
	hoverExpandedConfigurationNode == node ifFalse: [
		self collapseHoverExpandedConfigurationForm.
		hoverExpandedConfigurationNode := node ].
	node beExpanded.
	self spaceDo: [ :aSpace |
		aSpace universe postpone: [
			dragAsset == anAsset
				ifTrue: [ self showPlacementPreviewFor: anAsset at: aPoint ] ] ].
	^ true
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> collapseHoverExpandedConfigurationForm [
	Transcript
		show: '[CFFormExpansion] collapseHover caller=';
		show: thisContext sender selector printString;
		show: ' node=';
		show: (hoverExpandedConfigurationNode
			ifNil: [ 'nil' ]
			ifNotNil: [ :aNode | aNode identityHash printString ]);
		show: ' configuration=';
		show: (hoverExpandedConfigurationNode
			ifNil: [ 'nil' ]
			ifNotNil: [ :aNode | aNode configuration identityHash printString ]);
		cr.
	hoverExpandedConfigurationNode ifNotNil: [ :aNode |
		aNode parent ifNotNil: [ aNode beCollapsed ] ].
	hoverExpandedConfigurationNode := nil
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> preserveHoverExpandedConfigurationForm [
	Transcript
		show: '[CFFormExpansion] preserveHover caller=';
		show: thisContext sender selector printString;
		show: ' node=';
		show: (hoverExpandedConfigurationNode
			ifNil: [ 'nil' ]
			ifNotNil: [ :aNode | aNode identityHash printString ]);
		show: ' configuration=';
		show: (hoverExpandedConfigurationNode
			ifNil: [ 'nil' ]
			ifNotNil: [ :aNode | aNode configuration identityHash printString ]);
		cr.
	hoverExpandedConfigurationNode := nil
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> expandConfigurationFormFor: aConfiguration [
	| nodes node |
	nodes := OrderedCollection new.
	configurationContentElement ifNotNil: [
		self collectConfigurationNodeElementsFrom: configurationContentElement into: nodes ].
	node := nodes
		detect: [ :each | each configuration == aConfiguration ]
		ifNone: [ nil ].
	node ifNotNil: [ node beExpanded ]
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> expandConfigurationFormForAfterLayout: aConfiguration [
	self spaceDo: [ :aSpace |
		aSpace universe postpone: [ self expandConfigurationFormFor: aConfiguration ] ]
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> collapsedConfigurationNodeAt: aPoint for: anAssessment [
	| nodes |
	nodes := OrderedCollection new.
	configurationContentElement ifNotNil: [
		self
			collectConfigurationNodeElementsFrom: configurationContentElement
			into: nodes ].
	^ nodes
		detect: [ :each |
			each formElement notNil
				and: [ each isExpanded not
				and: [ (self assessment: anAssessment hasPlacementForConfiguration: each configuration)
				and: [ (self boundsOf: each formElement headerElement inLocalCoordinatesOf: self)
					containsPoint: aPoint ] ] ] ]
		ifNone: [ nil ]
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> assessment: anAssessment hasPlacementForConfiguration: aConfiguration [
	^ anAssessment targetChoices anySatisfy: [ :each |
		each placement memento model == aConfiguration ]
]

{ #category : 'hooks - scene graph' }
CFConfigurationEditorElement >> onRemovedFromSceneGraph [
	super onRemovedFromSceneGraph.
	animations ifNotNil: [ animations stopAll ]
]
