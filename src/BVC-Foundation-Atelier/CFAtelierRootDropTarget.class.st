"I accept a palette-supplied object as the root object of an otherwise empty Atelier.

Root adoption changes the editor context, not a model relation, so I deliberately do not manufacture a Magritte mutation operation. I only accept palette drags whose supplied object can actually be edited through Magritte, and hand the exact materialized identity to my adoption block."
Class {
	#name : 'CFAtelierRootDropTarget',
	#superclass : 'Object',
	#instVars : [
		'element',
		'adoptBlock',
		'dropIndicator',
		'activeDragItem'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'instance creation' }
CFAtelierRootDropTarget class >> installOn: anElement adopt: aBlock [
	^ self new
		element: anElement;
		adoptBlock: aBlock;
		install;
		yourself
]

{ #category : 'installing' }
CFAtelierRootDropTarget >> install [
	dropIndicator := self newDropIndicator.
	element addChild: dropIndicator.
	element addEventHandler: (BlDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea | self acceptsDragItem: aDragItem ];
		whenDragEnteredDo: [ :anEvent | self updateForEvent: anEvent ];
		whenDragOverDo: [ :anEvent | self updateForEvent: anEvent ];
		whenDragLeftDo: [ :anEvent | self hideIndicator ];
		whenDroppedDo: [ :anEvent | self dropEvent: anEvent ];
		yourself)
]

{ #category : 'testing' }
CFAtelierRootDropTarget >> acceptsDragItem: aDragItem [
	(self isPaletteDragItem: aDragItem) ifFalse: [ ^ false ].
	(self acceptsCandidate: aDragItem domainObject) ifFalse: [ ^ false ].
	activeDragItem := aDragItem.
	^ true
]

{ #category : 'testing' }
CFAtelierRootDropTarget >> acceptsCandidate: anObject [
	^ anObject notNil and: [ anObject hasMagritteDescription ]
]

{ #category : 'private - testing' }
CFAtelierRootDropTarget >> isPaletteDragItem: aDragItem [
	| aSourceElement |
	aSourceElement := aDragItem sourceElement.
	aSourceElement ifNil: [ ^ false ].
	^ aSourceElement userData includesKey: #atelierPaletteSource
]

{ #category : 'private - interaction' }
CFAtelierRootDropTarget >> updateForEvent: anEvent [
	(anEvent domainObjects size = 1 and: [ activeDragItem notNil ])
		ifTrue: [ self showIndicator ]
		ifFalse: [ self hideIndicator ]
]

{ #category : 'private - interaction' }
CFAtelierRootDropTarget >> dropEvent: anEvent [
	| aCandidate |
	self hideIndicator.
	anEvent domainObjects size = 1 ifFalse: [ ^ self ].
	activeDragItem ifNil: [ ^ self ].
	aCandidate := activeDragItem domainObject.
	(self acceptsCandidate: aCandidate) ifFalse: [ ^ self ].
	adoptBlock value: aCandidate
]

{ #category : 'private - appearance' }
CFAtelierRootDropTarget >> newDropIndicator [
	^ BlElement new
		background: (element theme interaction focusedBorderColor blocResolveColorForTheme: element theme);
		visibility: BlVisibility hidden;
		zIndex: 101;
		constraintsDo: [ :c |
			c ignoreByLayout.
			c horizontal matchParent.
			c vertical exact: 2.
			c ignored horizontal alignCenter.
			c ignored vertical alignBottom ];
		yourself
]

{ #category : 'private - appearance' }
CFAtelierRootDropTarget >> showIndicator [ dropIndicator visibility: BlVisibility visible ]

{ #category : 'private - appearance' }
CFAtelierRootDropTarget >> hideIndicator [ dropIndicator ifNotNil: [ dropIndicator visibility: BlVisibility hidden ] ]

{ #category : 'accessing' }
CFAtelierRootDropTarget >> element: anElement [ element := anElement ]

{ #category : 'accessing' }
CFAtelierRootDropTarget >> adoptBlock: aBlock [ adoptBlock := aBlock ]
