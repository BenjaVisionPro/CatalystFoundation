"I add Atelier palette insertion interaction to a relation-level element produced by an existing Foundation presentation.

I exist for the structural case in which an ordered to-many relation has no item row to act as an insertion target. I therefore accept palette candidates only while the current staged relation is empty and insert at the first position through CFAtelierInsert.

I do not render the relation and I do not compete with item-row insertion or Foundation's reorder interaction."
Class {
	#name : 'CFAtelierRelationDropSurface',
	#superclass : 'Object',
	#instVars : [
		'element',
		'memento',
		'description',
		'dropIndicator'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'instance creation' }
CFAtelierRelationDropSurface class >> installOn: anElement memento: aMemento description: aDescription [
	^ self new
		element: anElement;
		memento: aMemento;
		description: aDescription;
		install;
		yourself
]

{ #category : 'instance creation' }
CFAtelierRelationDropSurface class >> memento: aMemento description: aDescription [
	^ self new memento: aMemento; description: aDescription; yourself
]

{ #category : 'installing' }
CFAtelierRelationDropSurface >> install [
	description isMultiple ifFalse: [ ^ self ].
	description isOrdered ifFalse: [ ^ self ].
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
CFAtelierRelationDropSurface >> acceptsDragItem: aDragItem [
	| aSourceElement |
	aSourceElement := aDragItem sourceElement.
	aSourceElement ifNil: [ ^ false ].
	(aSourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	^ (self assessmentForCandidate: aDragItem domainObject) isApplicable
]

{ #category : 'assessing' }
CFAtelierRelationDropSurface >> assessmentForCandidate: aCandidate [
	(self currentItems ifNil: [ #() ]) isEmpty ifFalse: [
		^ CFAtelierInsertAssessment object: aCandidate items: self currentItems rejectedBecause: 'The relation already has item insertion targets.' ].
	^ (self operationForCandidate: aCandidate) assess
]

{ #category : 'applying' }
CFAtelierRelationDropSurface >> applyCandidate: aCandidate [
	(self currentItems ifNil: [ #() ]) isEmpty ifFalse: [
		^ CFAtelierInsertAssessment object: aCandidate items: self currentItems rejectedBecause: 'The relation already has item insertion targets.' ].
	^ (self operationForCandidate: aCandidate) apply
]

{ #category : 'private - operations' }
CFAtelierRelationDropSurface >> operationForCandidate: aCandidate [
	^ CFAtelierInsert object: aCandidate memento: memento description: description at: 1
]

{ #category : 'private - accessing' }
CFAtelierRelationDropSurface >> currentItems [
	^ memento readUsing: description
]

{ #category : 'private - interaction' }
CFAtelierRelationDropSurface >> updateForEvent: anEvent [
	anEvent domainObjects size = 1 ifFalse: [ ^ self hideIndicator ].
	(self assessmentForCandidate: anEvent domainObjects first) isApplicable
		ifTrue: [ self showIndicator ]
		ifFalse: [ self hideIndicator ]
]

{ #category : 'private - interaction' }
CFAtelierRelationDropSurface >> dropEvent: anEvent [
	self hideIndicator.
	anEvent domainObjects size = 1 ifFalse: [ ^ self ].
	^ self applyCandidate: anEvent domainObjects first
]

{ #category : 'private - appearance' }
CFAtelierRelationDropSurface >> newDropIndicator [
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
CFAtelierRelationDropSurface >> showIndicator [ dropIndicator visibility: BlVisibility visible ]
{ #category : 'private - appearance' }
CFAtelierRelationDropSurface >> hideIndicator [ dropIndicator ifNotNil: [ dropIndicator visibility: BlVisibility hidden ] ]
{ #category : 'accessing' }
CFAtelierRelationDropSurface >> element: anElement [ element := anElement ]
{ #category : 'accessing' }
CFAtelierRelationDropSurface >> memento: aMemento [ memento := aMemento ]
{ #category : 'accessing' }
CFAtelierRelationDropSurface >> description: aDescription [ description := aDescription ]
