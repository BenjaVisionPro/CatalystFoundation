"
GT-only assessed configuration library preview inside Atelier. Borrows the existing root Magritte editing context, projects staged values for planner assessment, and animates proposed relation structure with Motion. Never stages or applies a copied placement. Owns only transient preview elements and their Motion lifecycle.
"
Class {
	#name : 'CFConfigurationPlacementPreviewElement',
	#superclass : 'CFAtelierPaletteElement',
	#instVars : [
		'editingContext',
		'assessment',
		'projectedConfiguration',
		'destinationElement',
		'structureElement',
		'motionTransaction',
		'previewElement'
	],
	#category : 'BVC-Foundation-Config-UI-Core',
	#package : 'BVC-Foundation-Config-UI-Core'
}

{ #category : 'accessing' }
CFConfigurationPlacementPreviewElement >> assessment [
	^ assessment
]

{ #category : 'preview' }
CFConfigurationPlacementPreviewElement >> cancelPreview [
	motionTransaction ifNotNil: [ motionTransaction cancel ].
	motionTransaction := nil.
	previewElement := nil.
	assessment := nil.
	projectedConfiguration := nil.
	structureElement ifNotNil: [ structureElement removeChildren ].
	destinationElement ifNotNil: [
		destinationElement text: 'Hover a library candidate: preview only (Apply unavailable)' ]
]

{ #category : 'building' }
CFConfigurationPlacementPreviewElement >> configureItemElement: anElement for: anItem [
	"Deliberately no drag handler: the library entries are preview-only until
	copy-to-live placement mapping exists. Click reassesses rather than applies."
	anElement userData at: #configurationPreviewItem put: anItem.
	anElement
		when: BlMouseEnterEvent do: [ :event | self previewItem: anItem ];
		when: BlClickEvent do: [ :event | self previewItem: anItem ];
		when: BlMouseLeaveEvent do: [ :event | self cancelPreview ].
	^ anElement
]

{ #category : 'accessing' }
CFConfigurationPlacementPreviewElement >> editingContext [
	^ editingContext
]

{ #category : 'accessing' }
CFConfigurationPlacementPreviewElement >> editingContext: aMemento [
	editingContext == aMemento ifTrue: [ ^ self ].
	self cancelPreview.
	editingContext := aMemento
]

{ #category : 'initialization' }
CFConfigurationPlacementPreviewElement >> initialize [
	super initialize.
	destinationElement := BrLabel new
		aptitude: BrGlamorousLabelAptitude new;
		text: 'Hover a library candidate: preview only (Apply unavailable)';
		yourself.
	"A non-zero preview viewport avoids singular geometry when a cancelled
	layout motion retains its presentation, including an initially empty relation."
	structureElement := BrVerticalPane new hExact: 300; vExact: 160; yourself.
	self addChild: destinationElement; addChild: structureElement.
	self when: BlElementRemovedFromSceneGraphEvent do: [ :event | self cancelPreview ]
]

{ #category : 'accessing' }
CFConfigurationPlacementPreviewElement >> motionTransaction [
	^ motionTransaction
]

{ #category : 'building' }
CFConfigurationPlacementPreviewElement >> newConfigurationCardFor: aConfiguration [
	^ BrLabel new
		fitContent;
		padding: (BlInsets all: 8);
		aptitude: BrGlamorousLabelAptitude new;
		text: aConfiguration class name;
		background: Color veryLightGray;
		yourself
]

{ #category : 'preview' }
CFConfigurationPlacementPreviewElement >> previewItem: anItem [
	| choice placement currentValue values asset |
	self cancelPreview.
	(editingContext isNil or: [ self isAttachedToSceneGraph not ]) ifTrue: [ ^ self ].
	asset := anItem materialize.
	projectedConfiguration := CFConfigurationGraphCopier new copyEditingContext: editingContext.
	assessment := CFConfigurationPlanner new assessAsset: asset in: projectedConfiguration.
	assessment targetChoices ifEmpty: [
		destinationElement text: 'No valid placement (planner rejected candidate). Apply unavailable'.
		^ self ].
	choice := assessment targetChoices first.
	placement := choice placement.
	currentValue := placement memento readUsing: placement description.
	values := placement isAddition
		ifTrue: [ currentValue ifNil: [ #() ] ]
		ifFalse: [ currentValue ifNil: [ #() ] ifNotNil: [ { currentValue } ] ].
	destinationElement text: placement operationKind asString, ' in ',
		placement memento model class name, ' / ', placement description label asString,
		' (first assessed destination; preview only)'.
	previewElement := BrLabel new
		fitContent;
		padding: (BlInsets all: 8);
		aptitude: BrGlamorousLabelAptitude new;
		text: asset label;
		background: Color lightGreen;
		yourself.
	motionTransaction := (structureElement motion duration: 180 milliSeconds; layout)
		affecting: { structureElement };
		fadeIn: previewElement;
		mutate: [
			placement isAddition ifTrue: [
				values do: [ :configuration |
					structureElement addChild: (self newConfigurationCardFor: configuration) ] ].
			structureElement addChild: previewElement at: (placement insertionIndex
				ifNil: [ structureElement children size + 1 ]).
			structureElement vExact: 160 + (structureElement children size * 40) ];
		play.
	^ assessment
]

{ #category : 'accessing' }
CFConfigurationPlacementPreviewElement >> projectedConfiguration [
	^ projectedConfiguration
]

{ #category : 'accessing' }
CFConfigurationPlacementPreviewElement >> structureElement [
	^ structureElement
]
