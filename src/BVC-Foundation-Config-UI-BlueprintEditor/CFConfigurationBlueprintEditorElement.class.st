Class {
	#name : 'CFConfigurationBlueprintEditorElement',
	#superclass : 'BrFrame',
	#instVars : [
		'blueprintConfiguration',
		'blueprintContentElement',
		'library',
		'librarySidebarElement',
		'planner'
	],
	#category : 'BVC-Foundation-Config-UI-BlueprintEditor',
	#package : 'BVC-Foundation-Config-UI-BlueprintEditor'
}

{ #category : 'private - building' }
CFConfigurationBlueprintEditorElement >> addAssetDropHandler [
	self addEventHandler: (BlDropHandler new
		acceptDomainObjectsSuchThat: [ :anObject |
			anObject isKindOf: CFConfigurationAsset ];
		whenDroppedDo: [ :anEvent |
			anEvent domainObjects do: [ :each |
				self applyAssetWhenPlacementIsUnambiguous: each ] ];
		yourself)
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

{ #category : 'private - building' }
CFConfigurationBlueprintEditorElement >> createBlueprintContentElement [
	blueprintContentElement := BrFrame new
		matchParent;
		layout: BlFrameLayout new;
		background: (Color veryVeryLightGray alpha: 0.82);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 14);
		border: (BlBorder paint: (Color black alpha: 0.14) width: 1);
		yourself.
	^ blueprintContentElement
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
	blueprintContentElement ifNil: [ ^ self ].
	blueprintContentElement removeChildren.
	blueprintConfiguration ifNil: [ ^ self ].
	blueprintContentElement addChild: (blueprintConfiguration asGtMagritteViewModel asElement
		margin: (BlInsets all: 18);
		yourself)
]
