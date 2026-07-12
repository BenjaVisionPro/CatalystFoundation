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
		'libraryToggleButton'
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
		whenDragLeftDo: [ :anEvent | self clearPlacementPreview ];
		whenDroppedDo: [ :anEvent |
			anEvent domainObjects do: [ :each |
				self applyAsset: each at: anEvent position ].
			self clearPlacementPreview ];
		yourself)
]

{ #category : 'private - applying' }
CFConfigurationEditorElement >> applyAsset: anAsset at: aPoint [
	| assessment targetChoice |
	configuration ifNil: [ ^ nil ].
	assessment := planner assessAsset: anAsset in: configuration.
	targetChoice := self targetChoiceIn: assessment at: aPoint.
	targetChoice ifNil: [ ^ assessment ].
	(CFConfigurationPlan
		asset: anAsset
		targetChoice: targetChoice
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
	activeTargetChoice := nil.
	previewElement ifNotNil: [ :anElement |
		anElement removeFromParent ].
	previewElement := nil
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
CFConfigurationEditorElement >> createPlacementPreviewFor: aTargetChoice asset: anAsset bounds: aRectangle [
	| preview compactPresentation |
	preview := BrFrame new
		hExact: aRectangle width;
		vExact: aRectangle height;
		layout: BlFrameLayout new;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		background: (Color r: 0.15 g: 0.5 b: 0.95 alpha: 0.10);
		border: (BlBorder paint: (Color r: 0.2 g: 0.58 b: 1.0 alpha: 0.9) width: 2);
		preventMouseEvents;
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: aRectangle origin;
		yourself.
	aTargetChoice placement isAddition ifTrue: [
		compactPresentation := CFCompactObjectStencil new
			object: anAsset;
			create.
		compactPresentation
			hMatchParent;
			vFitContent;
			padding: (BlInsets top: 7 left: 10 bottom: 7 right: 10);
			geometry: (BlRoundedRectangleGeometry cornerRadius: 7);
			background: (Color r: 0.12 g: 0.42 b: 0.85 alpha: 0.30);
			border: (BlBorder paint: (Color white alpha: 0.20) width: 1);
			constraintsDo: [ :c |
				c frame horizontal alignCenter.
				c frame vertical alignBottom ];
			yourself.
		preview addChild: compactPresentation ].
	^ preview
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

{ #category : 'initialization' }
CFConfigurationEditorElement >> initialize [
	super initialize.
	library := CFConfigurationLibrary discovered.
	planner := CFConfigurationPlanner new.
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
	| assessment targetChoice fieldElement targetBounds |
	configuration ifNil: [ ^ self clearPlacementPreview ].
	assessment := planner assessAsset: anAsset in: configuration.
	targetChoice := self targetChoiceIn: assessment at: aPoint.
	(activeTargetChoice notNil and: [
		targetChoice notNil and: [
			activeTargetChoice placement matches: targetChoice placement ] ]) ifTrue: [ ^ self ].
	self clearPlacementPreview.
	targetChoice ifNil: [ ^ self ].
	activeTargetChoice := targetChoice.
	(targetChoice placement isAddition and: [
		self installAdditionPreviewFor: targetChoice asset: anAsset ]) ifTrue: [ ^ self ].
	fieldElement := self fieldElementForPlacement: targetChoice placement.
	fieldElement ifNil: [ ^ self ].
	targetBounds := (fieldElement bounds inParent: self) asRectangle.
	previewElement := self
		createPlacementPreviewFor: targetChoice
		asset: anAsset
		bounds: targetBounds.
	self addChild: previewElement
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
CFConfigurationEditorElement >> installAdditionPreviewFor: aTargetChoice asset: anAsset [
	| relationElement itemsElement compactPresentation |
	relationElement := self fieldElementForPlacement: aTargetChoice placement.
	relationElement ifNil: [ ^ false ].
	itemsElement := relationElement
		allChildrenBreadthFirstDetect: [ :each |
			(each userData at: #cfConfigurationEditorRelationItems ifAbsent: [ false ]) ]
		ifFound: [ :each | each ]
		ifNone: [ ^ false ].
	compactPresentation := CFCompactObjectStencil new
		object: anAsset;
		create.
	compactPresentation
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 8 left: 10 bottom: 8 right: 10);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		background: (Color r: 0.12 g: 0.42 b: 0.85 alpha: 0.30);
		border: (BlBorder paint: (Color r: 0.2 g: 0.58 b: 1.0 alpha: 0.9) width: 1);
		yourself.
	itemsElement addChild: compactPresentation.
	previewElement := compactPresentation.
	^ true
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> targetChoiceIn: anAssessment at: aPoint [
	| candidates |
	candidates := anAssessment targetChoices select: [ :each |
		(self fieldElementForPlacement: each placement) notNil ].
	candidates ifEmpty: [ ^ nil ].
	^ candidates
		inject: candidates first
		into: [ :closest :each |
			(self targetChoice: each isCloserTo: aPoint than: closest)
				ifTrue: [ each ]
				ifFalse: [ closest ] ]
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> targetChoice: aTargetChoice isCloserTo: aPoint than: anotherTargetChoice [
	| bounds otherBounds distance otherDistance |
	bounds := ((self fieldElementForPlacement: aTargetChoice placement)
		bounds inParent: self) asRectangle.
	otherBounds := ((self fieldElementForPlacement: anotherTargetChoice placement)
		bounds inParent: self) asRectangle.
	distance := self distanceSquaredFrom: aPoint to: bounds.
	otherDistance := self distanceSquaredFrom: aPoint to: otherBounds.
	distance = otherDistance ifFalse: [ ^ distance < otherDistance ].
	^ (self distanceSquaredFrom: aPoint toPoint: bounds center)
		< (self distanceSquaredFrom: aPoint toPoint: otherBounds center)
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> distanceSquaredFrom: aPoint toPoint: anotherPoint [
	^ (aPoint x - anotherPoint x) squared
		+ (aPoint y - anotherPoint y) squared
]

{ #category : 'private - planning' }
CFConfigurationEditorElement >> distanceSquaredFrom: aPoint to: aRectangle [
	| horizontalDistance verticalDistance |
	horizontalDistance := aPoint x < aRectangle left
		ifTrue: [ aRectangle left - aPoint x ]
		ifFalse: [
			aPoint x > aRectangle right
				ifTrue: [ aPoint x - aRectangle right ]
				ifFalse: [ 0 ] ].
	verticalDistance := aPoint y < aRectangle top
		ifTrue: [ aRectangle top - aPoint y ]
		ifFalse: [
			aPoint y > aRectangle bottom
				ifTrue: [ aPoint y - aRectangle bottom ]
				ifFalse: [ 0 ] ].
	^ horizontalDistance squared + verticalDistance squared
]
