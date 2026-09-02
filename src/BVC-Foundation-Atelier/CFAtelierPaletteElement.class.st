"I present one configured Atelier palette as a draggable source of materialized candidate objects and, when its palette is explicitly configured for capture, as a destination for existing composition objects.

Source drags materialize a palette item exactly once and put that candidate object on the ordinary Bloc drag item. Target interaction can then assess that same identity through an Atelier operation.

Capture is deliberately palette policy. I only recognize an existing Atelier relation drag, verify that its source still contains the dragged identity, and ask the palette to capture that object. The palette's configured capture block decides whether that means identity, copy, serialized definition, factory data or another representation."
Class {
	#name : 'CFAtelierPaletteElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'palette',
		'itemsElement',
		'activeCaptureDragItem'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'initialization' }
CFAtelierPaletteElement >> initialize [
	super initialize.
	self
		hExact: 220;
		vFitContent;
		padding: (BlInsets all: 10);
		cellSpacing: 8.
	self addChild: (BrLabel new
		fitContent;
		aptitude: BrGlamorousLabelAptitude new;
		text: 'Palette';
		yourself).
	itemsElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 4;
		yourself.
	self addChild: itemsElement.
	self installCaptureDrop
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
	aRow := BrLabel new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 7 left: 8 bottom: 7 right: 8);
		aptitude: BrGlamorousLabelAptitude new;
		text: anItem label;
		yourself.
	aRow userData at: #atelierPaletteSource put: true.
	aRow addEventHandler: (BlDragHandler new
		liftItem: [ :aSourceElement |
			self dragItemFor: anItem sourceElement: aSourceElement ];
		yourself).
	^ aRow
]

{ #category : 'interaction' }
CFAtelierPaletteElement >> dragItemFor: anItem sourceElement: aSourceElement [
	| aCandidate |
	aCandidate := anItem materialize.
	^ BlDragItem new
		sourceElement: aSourceElement;
		domainObject: aCandidate;
		stencil: [ :aDragItem |
			BrLabel new
				fitContent;
				padding: (BlInsets all: 7);
				aptitude: BrGlamorousLabelAptitude new;
				text: anItem label;
				yourself ];
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
