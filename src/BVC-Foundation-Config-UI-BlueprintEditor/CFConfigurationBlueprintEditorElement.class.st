Class {
	#name : 'CFConfigurationBlueprintEditorElement',
	#superclass : 'BrFrame',
	#instVars : [
		'blueprintConfiguration',
		'blueprintContentElement',
		'activeTargetChoice',
		'library',
		'librarySidebarElement',
		'planner',
		'previewElement',
		'previewListElement',
		'previewListItems'
	],
	#category : 'BVC-Foundation-Config-UI-BlueprintEditor',
	#package : 'BVC-Foundation-Config-UI-BlueprintEditor'
}

{ #category : 'private - building' }
CFConfigurationBlueprintEditorElement >> addAssetDropHandler [
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
CFConfigurationBlueprintEditorElement >> applyAsset: anAsset at: aPoint [
	| assessment targetChoice |
	blueprintConfiguration ifNil: [ ^ nil ].
	assessment := planner assessAsset: anAsset in: blueprintConfiguration.
	targetChoice := self targetChoiceIn: assessment at: aPoint.
	targetChoice ifNil: [ ^ assessment ].
	(CFConfigurationPlan
		asset: anAsset
		targetChoice: targetChoice
		planner: planner) apply.
	self refreshBlueprintContent.
	^ assessment
]

{ #category : 'private - applying' }
CFConfigurationBlueprintEditorElement >> applyAssetWhenPlacementIsUnambiguous: anAsset [
	| assessment |
	blueprintConfiguration ifNil: [ ^ nil ].
	assessment := planner assessAsset: anAsset in: blueprintConfiguration.
	assessment hasSingleTargetChoice ifFalse: [ ^ assessment ].
	(CFConfigurationPlan
		asset: anAsset
		targetChoice: assessment targetChoices first
		planner: planner) apply.
	self refreshBlueprintContent.
	^ assessment
]

{ #category : 'accessing' }
CFConfigurationBlueprintEditorElement >> blueprintConfiguration [
	^ blueprintConfiguration
]

{ #category : 'accessing' }
CFConfigurationBlueprintEditorElement >> blueprintConfiguration: aConfiguration [
	blueprintConfiguration := aConfiguration.
	self refreshBlueprintContent
]

{ #category : 'private - previewing' }
CFConfigurationBlueprintEditorElement >> clearPlacementPreview [
	activeTargetChoice := nil.
	previewListElement ifNotNil: [ :aListElement |
		previewListItems ifNotNil: [ :theItems | aListElement items: theItems ] ].
	previewListElement := nil.
	previewListItems := nil.
	previewElement ifNotNil: [ :anElement |
		anElement removeFromParent ].
	previewElement := nil
]

{ #category : 'private - building' }
CFConfigurationBlueprintEditorElement >> createBlueprintContentElement [
	blueprintContentElement := BrFrame new
		matchParent;
		layout: BlFrameLayout new;
		background: (Color r: 0.93 g: 0.95 b: 0.98 alpha: 0.82);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 14);
		border: (BlBorder paint: (Color black alpha: 0.14) width: 1);
		yourself.
	^ blueprintContentElement
]

{ #category : 'private - building' }
CFConfigurationBlueprintEditorElement >> createBlueprintSurfaceElement [
	^ BrFrame new
		hExact: self blueprintSurfaceWidth;
		vMatchParent;
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
CFConfigurationBlueprintEditorElement >> blueprintSurfaceWidth [
	^ 580
]

{ #category : 'private - building' }
CFConfigurationBlueprintEditorElement >> createLibrarySidebar [
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

{ #category : 'private - previewing' }
CFConfigurationBlueprintEditorElement >> createPlacementPreviewFor: aTargetChoice asset: anAsset bounds: aRectangle [
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
CFConfigurationBlueprintEditorElement >> fieldElementForPlacement: aPlacement [
	| formHost |
	formHost := self formHostForConfiguration: aPlacement owner.
	formHost ifNil: [ ^ nil ].
	^ formHost
		allChildrenBreadthFirstDetect: [ :each |
			(each id isKindOf: GtMagritteFieldElementId) and: [
				each id description accessor readSelector
					= aPlacement description accessor readSelector ] ]
		ifFound: [ :each | each ]
		ifNone: [ nil ]
]

{ #category : 'private - previewing' }
CFConfigurationBlueprintEditorElement >> formHostForConfiguration: aConfiguration [
	| mementoSymbol |
	mementoSymbol := GtMagritteViewModel gtMementoSymbol.
	^ blueprintContentElement
		allChildrenBreadthFirstDetect: [ :each |
			(each userData includesKey: mementoSymbol) and: [
				(each userData at: mementoSymbol) model == aConfiguration ] ]
		ifFound: [ :each | each ]
		ifNone: [ nil ]
]

{ #category : 'initialization' }
CFConfigurationBlueprintEditorElement >> initialize [
	super initialize.
	library := CFConfigurationLibrary discovered.
	planner := CFConfigurationPlanner new.
	self
		matchParent;
		layout: BlFrameLayout new;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 14);
		background: Color transparent;
		border: BlBorder empty.
	self
		addChild: self createBlueprintContentElement;
		addChild: self createLibrarySidebar;
		addAssetDropHandler
]

{ #category : 'accessing' }
CFConfigurationBlueprintEditorElement >> library [
	^ library
]

{ #category : 'accessing' }
CFConfigurationBlueprintEditorElement >> library: aConfigurationLibrary [
	library := aConfigurationLibrary.
	librarySidebarElement ifNotNil: [ :anElement | anElement library: library ]
]

{ #category : 'accessing' }
CFConfigurationBlueprintEditorElement >> librarySidebarElement [
	^ librarySidebarElement
]

{ #category : 'updating' }
CFConfigurationBlueprintEditorElement >> refreshBlueprintContent [
	| surface editorElement |
	self clearPlacementPreview.
	blueprintContentElement ifNil: [ ^ self ].
	blueprintContentElement removeChildren.
	blueprintConfiguration ifNil: [ ^ self ].
	surface := self createBlueprintSurfaceElement.
	editorElement := blueprintConfiguration asGtMagritteViewModel asElement
		margin: (BlInsets all: 10);
		yourself.
	surface addChild: editorElement.
	blueprintContentElement addChild: surface
]

{ #category : 'private - previewing' }
CFConfigurationBlueprintEditorElement >> relationListForPlacement: aPlacement [
	| fieldElement |
	fieldElement := self fieldElementForPlacement: aPlacement.
	fieldElement ifNil: [ ^ nil ].
	^ fieldElement
		allChildrenBreadthFirstDetect: [ :each | each isKindOf: BrSimpleList ]
		ifFound: [ :each | each ]
		ifNone: [ nil ]
]

{ #category : 'private - previewing' }
CFConfigurationBlueprintEditorElement >> showPlacementPreviewFor: anAsset at: aPoint [
	| assessment targetChoice fieldElement targetBounds |
	blueprintConfiguration ifNil: [ ^ self clearPlacementPreview ].
	assessment := planner assessAsset: anAsset in: blueprintConfiguration.
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

{ #category : 'private - previewing' }
CFConfigurationBlueprintEditorElement >> installAdditionPreviewFor: aTargetChoice asset: anAsset [
	| listElement previewConfiguration previewViewModel memento formHost |
	listElement := self relationListForPlacement: aTargetChoice placement.
	listElement ifNil: [ ^ false ].
	formHost := self formHostForConfiguration: aTargetChoice placement owner.
	memento := formHost userData at: GtMagritteViewModel gtMementoSymbol.
	previewConfiguration := anAsset materialize.
	previewViewModel := aTargetChoice placement description blocItemViewModelStencil
		model: previewConfiguration;
		description: aTargetChoice placement description;
		memento: memento;
		build.
	previewListElement := listElement.
	previewListItems := listElement items.
	listElement items: (previewListItems copyWith: previewViewModel).
	^ true
]

{ #category : 'private - planning' }
CFConfigurationBlueprintEditorElement >> targetChoiceIn: anAssessment at: aPoint [
	| targetChoices matches |
	targetChoices := anAssessment targetChoices.
	targetChoices size = 1 ifTrue: [ ^ targetChoices first ].
	matches := targetChoices select: [ :each |
		| fieldElement |
		fieldElement := self fieldElementForPlacement: each placement.
		fieldElement notNil and: [
			((fieldElement bounds inParent: self) asRectangle)
				containsPoint: aPoint ] ].
	^ matches size = 1 ifTrue: [ matches first ] ifFalse: [ nil ]
]
