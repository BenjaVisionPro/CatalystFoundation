"I present one configured Atelier palette as a vertical draggable source of materialized candidate objects and, when explicitly configured for capture, as a destination for existing composition objects.

I am designed to float over an Atelier work surface. My header moves the palette itself; dragging an item still materializes that palette item exactly once and starts the ordinary Atelier object drag. My visual surface uses Foundation's existing glass aptitude."
Class {
	#name : 'CFAtelierPaletteElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'palette',
		'itemsElement',
		'activeCaptureDragItem',
		'draggingPalette',
		'dragStartPointer',
		'dragStartPosition'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'initialization' }
CFAtelierPaletteElement >> initialize [
	| header |
	super initialize.
	draggingPalette := false.
	self configureAppearance.
	header := self newHeaderElement.
	self installMoveInteractionOn: header.
	self addChild: header.
	itemsElement := self newItemsElement.
	self addChild: itemsElement.
	self installCaptureDrop
]

{ #category : 'private - building' }
CFAtelierPaletteElement >> configureAppearance [
	self
		hFitContent;
		vFitContent;
		padding: (BlInsets all: 10);
		cellSpacing: 8;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 12);
		border: (BlBorder paint: (Color white alpha: 0.16) width: 1);
		addAptitude: CFGlassSurfaceAptitude new
]

{ #category : 'private - building' }
CFAtelierPaletteElement >> newHeaderElement [
	^ BrLabel new
		hFitContent;
		vFitContent;
		padding: (BlInsets top: 2 left: 2 bottom: 4 right: 2);
		aptitude: BrGlamorousLabelAptitude new;
		text: 'Palette';
		yourself
]

{ #category : 'private - building' }
CFAtelierPaletteElement >> newItemsElement [
	^ BrVerticalPane new
		hFitContent;
		vFitContent;
		cellSpacing: 4;
		yourself
]

{ #category : 'private - interaction' }
CFAtelierPaletteElement >> installMoveInteractionOn: aDragSurfaceElement [
	aDragSurfaceElement addEventFilter: (BlEventHandler
		on: BlDragStartEvent
		do: [ :anEvent |
			(self shouldBeginMoveForDragStartEvent: anEvent) ifTrue: [
				draggingPalette := true.
				dragStartPointer := anEvent position.
				dragStartPosition := self position.
				anEvent consumed: true ] ]).
	aDragSurfaceElement addEventHandler: (BlEventHandler
		on: BlDragEvent
		do: [ :anEvent |
			draggingPalette ifTrue: [
				self relocateWithinParent: dragStartPosition + (anEvent position - dragStartPointer).
				anEvent consumed: true ] ]).
	aDragSurfaceElement addEventHandler: (BlEventHandler
		on: BlDragEndEvent
		do: [ :anEvent |
			draggingPalette ifTrue: [
				draggingPalette := false.
				anEvent consumed: true ] ])
]

{ #category : 'private - interaction' }
CFAtelierPaletteElement >> shouldBeginMoveForDragStartEvent: anEvent [
	^ true
]

{ #category : 'private - interaction' }
CFAtelierPaletteElement >> relocateWithinParent: aPoint [
	| parentExtent maximumX maximumY |
	self parent ifNil: [ ^ self relocate: aPoint ].
	parentExtent := self parent extent.
	maximumX := (parentExtent x - self extent x) max: 0.
	maximumY := (parentExtent y - self extent y) max: 0.
	self relocate: ((aPoint x max: 0) min: maximumX) @ ((aPoint y max: 0) min: maximumY)
]

{ #category : 'accessing' }
CFAtelierPaletteElement >> palette [
	^ palette
]

{ #category : 'accessing' }
CFAtelierPaletteElement >> palette: anAtelierPalette [
	palette := anAtelierPalette.
	self refresh
]

{ #category : 'updating' }
CFAtelierPaletteElement >> refresh [
	itemsElement ifNil: [ ^ self ].
	itemsElement removeChildren.
	palette ifNil: [ ^ self ].
	palette items do: [ :anItem |
		itemsElement addChild: (self newItemElementFor: anItem) ]
]

{ #category : 'private - building' }
CFAtelierPaletteElement >> newItemElementFor: anItem [
	| aRow |
	aRow := anItem icon
		ifNil: [
			BrLabel new
				hMatchParent;
				vFitContent;
				padding: (BlInsets top: 7 left: 8 bottom: 7 right: 8);
				aptitude: BrGlamorousLabelAptitude new;
				text: anItem label;
				yourself ]
		ifNotNil: [ :anIconStencil |
			BlElement new
				extent: 36 @ 36;
				layout: BlFrameLayout new;
				addChild: (anIconStencil asStencil asElement
					constraintsDo: [ :c |
						c frame horizontal alignCenter.
						c frame vertical alignCenter ];
					yourself);
				addAptitude: (BrGlamorousWithExplicitTooltipAptitude text: anItem label);
				yourself ].
	^ self configureItemElement: aRow for: anItem
]

{ #category : 'private - building' }
CFAtelierPaletteElement >> configureItemElement: anElement for: anItem [
	anElement userData
		at: #atelierPaletteSource put: true;
		at: #atelierPaletteItem put: anItem.
	anElement addEventHandler: (BlDragHandler new
		liftItem: [ :aSourceElement |
			self dragItemFor: anItem sourceElement: aSourceElement ];
		yourself).
	^ anElement
]

{ #category : 'interaction' }
CFAtelierPaletteElement >> dragItemFor: anItem sourceElement: aSourceElement [
	| aCandidate |
	aCandidate := anItem materialize.
	^ BlDragItem new
		sourceElement: aSourceElement;
		domainObject: aCandidate;
		stencil: [ :aDragItem |
			anItem icon
				ifNil: [
					BrLabel new
						fitContent;
						padding: (BlInsets all: 7);
						aptitude: BrGlamorousLabelAptitude new;
						text: anItem label;
						yourself ]
				ifNotNil: [ :anIconStencil |
					BlElement new
						extent: 36 @ 36;
						layout: BlFrameLayout new;
						addChild: (anIconStencil asStencil asElement
							constraintsDo: [ :c |
								c frame horizontal alignCenter.
								c frame vertical alignCenter ];
							yourself);
						yourself ] ];
		yourself
]

{ #category : 'private - installing' }
CFAtelierPaletteElement >> installCaptureDrop [
	self addEventHandler: (BlDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea |
			self acceptsCaptureDragItem: aDragItem ];
		whenDragLeftDo: [ :anEvent | activeCaptureDragItem := nil ];
		whenDroppedDo: [ :anEvent | self captureDropEvent: anEvent ];
		yourself)
]

{ #category : 'testing' }
CFAtelierPaletteElement >> acceptsCaptureDragItem: aDragItem [
	| aContext isApplicable |
	palette ifNil: [ ^ false ].
	palette canCapture ifFalse: [ ^ false ].
	aContext := self sourceContextForDragItem: aDragItem.
	aContext ifNil: [ ^ false ].
	isApplicable := self
		sourceContext: aContext
		containsObject: aDragItem domainObject.
	isApplicable ifTrue: [ activeCaptureDragItem := aDragItem ].
	^ isApplicable
]

{ #category : 'private - accessing' }
CFAtelierPaletteElement >> sourceContextForDragItem: aDragItem [
	| aSourceElement |
	aSourceElement := aDragItem sourceElement.
	aSourceElement ifNil: [ ^ nil ].
	^ aSourceElement userData
		at: #atelierRelationDragContext
		ifAbsent: [ nil ]
]

{ #category : 'private - testing' }
CFAtelierPaletteElement >> sourceContext: aContext containsObject: anObject [
	| aValue |
	aValue := aContext memento readUsing: aContext description.
	aContext description isMultiple ifTrue: [
		aValue ifNil: [ ^ false ].
		^ (aValue identityIndexOf: anObject ifAbsent: [ 0 ]) > 0 ].
	^ aValue == anObject
]

{ #category : 'capturing' }
CFAtelierPaletteElement >> captureDragItem: aDragItem [
	(self acceptsCaptureDragItem: aDragItem) ifFalse: [ ^ nil ].
	^ self captureActiveDragItem
]

{ #category : 'private - interaction' }
CFAtelierPaletteElement >> captureDropEvent: anEvent [
	anEvent domainObjects size = 1 ifFalse: [
		activeCaptureDragItem := nil.
		^ self ].
	^ self captureActiveDragItem
]

{ #category : 'private - capturing' }
CFAtelierPaletteElement >> captureActiveDragItem [
	| aDragItem aContext anItem |
	aDragItem := activeCaptureDragItem.
	activeCaptureDragItem := nil.
	aDragItem ifNil: [ ^ nil ].
	aContext := self sourceContextForDragItem: aDragItem.
	aContext ifNil: [ ^ nil ].
	(self sourceContext: aContext containsObject: aDragItem domainObject)
		ifFalse: [ ^ nil ].
	anItem := palette capture: aDragItem domainObject.
	anItem ifNotNil: [ self refresh ].
	^ anItem
]
