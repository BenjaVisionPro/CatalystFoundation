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
		'displacedElements',
		'dropCompletionToken',
		'previewVisible',
		'previewSlotElement',
		'previewNaturalExtent',
		'previewItemsElement',
		'previewAxis'
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
	dropCompletionToken := nil.
	activeTargetChoice := nil.
	activeInsertionIndex := nil.
	activePlacementCandidate := nil.
	dragAsset := nil.
	dragAssessment := nil.
	previewConfiguration := nil.
	previewVisible := false.
	animations stopAll.
	self resetDisplacedElements.
	self detachPlacementPreview
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> detachPlacementPreview [
	previewSlotElement ifNotNil: [ :anElement | anElement removeFromParent ].
	previewElement ifNotNil: [ :anElement | anElement removeFromParent ].
	previewSlotElement := nil.
	previewElement := nil.
	previewNaturalExtent := nil.
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
	^ BrFrame new
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
		yourself
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
			(each userData includesKey: #cfConfigurationEditorOwner) and: [
				(each userData at: #cfConfigurationEditorOwner) == aPlacement owner
					and: [ (each userData at: #cfConfigurationEditorDescription)
						accessor readSelector
							= aPlacement description accessor readSelector ] ] ]
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
	displacedElements := IdentitySet new.
	previewVisible := false.
	libraryVisible := true.
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
		addAssetDropHandler
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
	configuration ifNil: [ ^ self ].
	surface := self createConfigurationSurfaceElement.
	visitedConfigurations := IdentitySet new.
	visitedConfigurations add: configuration.
	nodeElement := CFConfigurationNodeElement
		configuration: configuration
		visited: visitedConfigurations
		selected: selectedConfiguration
		whenSelected: [ :aConfiguration |
			self selectConfiguration: aConfiguration ].
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
	configuration ifNil: [ ^ self clearPlacementPreview ].
	assessment := dragAsset == anAsset
		ifTrue: [ dragAssessment ]
		ifFalse: [
			dragAsset := anAsset.
			previewConfiguration := anAsset materialize.
			dragAssessment := planner assessAsset: anAsset in: configuration ].
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
CFConfigurationEditorElement >> hidePlacementPreview [
	activeTargetChoice := nil.
	activeInsertionIndex := nil.
	activePlacementCandidate := nil.
	previewVisible := false.
	animations stop: #dropPreviewPosition.
	self restoreDisplacedElements.
	self collapsePlacementPreview
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> showDropPreviewAt: aCandidate [
	| relation items insertionIndex wasVisible |
	wasVisible := previewVisible = true.
	previewElement ifNil: [ self createDropPreviewElement ].
	relation := self fieldElementForPlacement: aCandidate targetChoice placement.
	relation ifNil: [ ^ self hidePlacementPreview ].
	items := self relationItemsElementIn: relation.
	items ifNil: [ ^ self hidePlacementPreview ].
	insertionIndex := aCandidate insertionIndex
		min: items childrenCount + 1
		max: 1.
	self
		placePreviewSlotIn: items
		at: insertionIndex
		axis: aCandidate axis.
	self measurePreviewSlotInItsTarget.
	previewVisible := true.
	wasVisible ifFalse: [ self setPreviewSlotExtent: 0 ].
	self expandPlacementPreview.
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
	previewSlotElement := BrFrame new
		clipChildren: true;
		background: Color transparent;
		yourself.
	previewSlotElement addChild: previewElement
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
CFConfigurationEditorElement >> completeDropOfAsset: anAsset at: aPoint [
	| assessment candidate token |
	configuration ifNil: [ ^ self clearPlacementPreview ].
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
	self showDropPreviewAt: candidate.
	token := Object new.
	dropCompletionToken := token.
	self animatePreviewOpacityTo: 1 then: [
		dropCompletionToken == token ifTrue: [
			(CFConfigurationPlan
				asset: anAsset
				targetChoice: candidate targetChoice
				planner: planner) apply.
			dropCompletionToken := nil.
			self refreshConfigurationContent.
			self refreshConfigurationInspector ] ]
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> animatePreviewTo: aPoint [
	| start |
	start := previewElement userData at: #cfAnimatedPosition ifAbsent: [ previewElement position ].
	animations retarget: [ self pointAnimationFrom: start to: aPoint onStep: [ :each |
		previewElement relocate: each.
		previewElement userData at: #cfAnimatedPosition put: each ] ] named: #dropPreviewPosition
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> animateDisplacementsFor: aCandidate previewExtent: anExtent [
	"The preview slot participates in the target layout, so the layout itself
	 opens the insertion space. Existing children are not translated."
	self restoreDisplacedElements
]

{ #category : 'private - animations' }
CFConfigurationEditorElement >> animateElement: anElement translationTo: aPoint [
	| start name |
	start := anElement userData at: #cfAnimatedTranslation ifAbsent: [ 0 @ 0 ].
	start = aPoint ifTrue: [ ^ self ].
	aPoint ~= (0 @ 0) ifTrue: [ displacedElements add: anElement ].
	name := ('item-', anElement identityHash asString) asSymbol.
	animations retarget: [ self pointAnimationFrom: start to: aPoint onStep: [ :each |
		anElement transformDo: [ :builder | builder translateBy: each ].
		anElement userData at: #cfAnimatedTranslation put: each ] ] named: name
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
CFConfigurationEditorElement >> restoreDisplacedElements [
	| elements |
	elements := displacedElements asArray.
	displacedElements := IdentitySet new.
	elements do: [ :each | self animateElement: each translationTo: 0 @ 0 ]
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> placePreviewSlotIn: anItemsElement at: anIndex axis: anAxis [
	| currentIndex targetIndex |
	previewAxis := anAxis.
	previewItemsElement == anItemsElement
		ifTrue: [
			currentIndex := anItemsElement childIndexOf: previewSlotElement.
			targetIndex := anIndex min: anItemsElement childrenCount.
			currentIndex = targetIndex ifFalse: [
				previewSlotElement removeFromParent.
				anItemsElement addChild: previewSlotElement at: targetIndex ] ]
		ifFalse: [
			previewSlotElement removeFromParent.
			previewItemsElement := anItemsElement.
			anItemsElement addChild: previewSlotElement at: anIndex ].
	previewAxis = #horizontal
		ifTrue: [
			previewElement hFitContent; vMatchParent ]
		ifFalse: [
			previewElement hMatchParent; vFitContent ]
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> measurePreviewSlotInItsTarget [
	previewSlotElement ifNil: [ ^ self ].
	previewAxis = #horizontal
		ifTrue: [
			previewSlotElement hFitContent; vMatchParent ]
		ifFalse: [
			previewSlotElement hMatchParent; vFitContent ].
	previewItemsElement forceLayout.
	previewNaturalExtent := previewSlotElement extent
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> setPreviewSlotExtent: aNumber [
	previewSlotElement ifNil: [ ^ self ].
	previewAxis = #horizontal
		ifTrue: [
			previewSlotElement hExact: aNumber.
			previewSlotElement vMatchParent ]
		ifFalse: [
			previewSlotElement hMatchParent.
			previewSlotElement vExact: aNumber ]
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> previewSlotTargetExtent [
	^ previewAxis = #horizontal
		ifTrue: [ previewNaturalExtent x ]
		ifFalse: [ previewNaturalExtent y ]
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> expandPlacementPreview [
	| start target animation |
	previewSlotElement ifNil: [ ^ self ].
	target := self previewSlotTargetExtent.
	start := previewAxis = #horizontal
		ifTrue: [ previewSlotElement width ]
		ifFalse: [ previewSlotElement height ].
	start = target ifTrue: [ ^ self ].
	animation := BlNumberTransition new
		from: start;
		to: target;
		duration: 140 milliSeconds;
		easing: (BlDecelerateInterpolator factor: 1);
		onStepDo: [ :each | self setPreviewSlotExtent: each ];
		yourself.
	animations retarget: [ animation ] named: #dropPreviewExtent
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> collapsePlacementPreview [
	| start animation element |
	previewSlotElement ifNil: [ ^ self fadeDropPreviewOut ].
	element := previewSlotElement.
	start := previewAxis = #horizontal
		ifTrue: [ element width ]
		ifFalse: [ element height ].
	self fadeDropPreviewOut.
	animation := BlNumberTransition new
		from: start;
		to: 0;
		duration: 120 milliSeconds;
		easing: (BlDecelerateInterpolator factor: 1);
		onStepDo: [ :each | self setPreviewSlotExtent: each ];
		yourself.
	animation onFinishedDo: [
		(previewSlotElement == element and: [ previewVisible ~= true ])
			ifTrue: [ self detachPlacementPreview ] ].
	animations retarget: [ animation ] named: #dropPreviewExtent
]

{ #category : 'private - previewing' }
CFConfigurationEditorElement >> resetDisplacedElements [
	displacedElements asArray do: [ :each |
		each transformDo: [ :builder | builder translateBy: 0 @ 0 ].
		each userData at: #cfAnimatedTranslation put: 0 @ 0 ].
	displacedElements := IdentitySet new
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
CFConfigurationEditorElement >> relationItemsElementIn: aRelationElement [
	^ aRelationElement
		allChildrenBreadthFirstDetect: [ :each |
			(each userData at: #cfConfigurationEditorRelationItems ifAbsent: [ false ]) ]
		ifFound: [ :each | each ]
		ifNone: [ nil ]
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

{ #category : 'hooks - scene graph' }
CFConfigurationEditorElement >> onRemovedFromSceneGraph [
	super onRemovedFromSceneGraph.
	animations ifNotNil: [ animations stopAll ]
]
