"I add Atelier composition interaction to the relation-level element of a to-many relation.

For ordered relations I am the empty-list target: palette insertion and cross-relation move use position one, then populated relations defer to item-row targets. For unordered relations there is no positional item target, so I remain the relation-level target whether empty or populated; insertion and move append without inventing order. I do not render the relation."
Class {
	#name : 'CFAtelierRelationDropSurface',
	#superclass : 'Object',
	#instVars : [
		'element',
		'memento',
		'description',
		'dropIndicator',
		'activeDragItem'
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
	| anAssessment |
	(description isOrdered and: [ (self currentItems ifNil: [ #() ]) isEmpty not ]) ifTrue: [ ^ false ].
	anAssessment := (self isPaletteDragItem: aDragItem)
		ifTrue: [ self assessmentForCandidate: aDragItem domainObject ]
		ifFalse: [ self moveAssessmentForDragItem: aDragItem ].
	anAssessment isApplicable ifTrue: [ activeDragItem := aDragItem ].
	^ anAssessment isApplicable
]

{ #category : 'private - testing' }
CFAtelierRelationDropSurface >> isPaletteDragItem: aDragItem [
	| aSourceElement |
	aSourceElement := aDragItem sourceElement.
	aSourceElement ifNil: [ ^ false ].
	^ aSourceElement userData includesKey: #atelierPaletteSource
]

{ #category : 'private - accessing' }
CFAtelierRelationDropSurface >> sourceContextForDragItem: aDragItem [
	| aSourceElement |
	aSourceElement := aDragItem sourceElement.
	aSourceElement ifNil: [ ^ nil ].
	^ aSourceElement userData at: #atelierRelationDragContext ifAbsent: [ nil ]
]

{ #category : 'assessing' }
CFAtelierRelationDropSurface >> moveAssessmentForDragItem: aDragItem [
	| anOperation |
	anOperation := self moveOperationForDragItem: aDragItem.
	anOperation ifNil: [
		^ CFAtelierMoveAssessment
			sourceItems: nil
			destinationItems: self currentItems
			rejectedBecause: 'The drag item has no Atelier relation source context.' ].
	^ anOperation assess
]

{ #category : 'private - operations' }
CFAtelierRelationDropSurface >> moveOperationForDragItem: aDragItem [
	| aSourceContext |
	aSourceContext := self sourceContextForDragItem: aDragItem.
	aSourceContext ifNil: [ ^ nil ].
	^ CFAtelierMove
		object: aDragItem domainObject
		sourceMemento: aSourceContext memento
		sourceDescription: aSourceContext description
		destinationMemento: memento
		destinationDescription: description
		destinationIndex: (description isOrdered ifTrue: [ 1 ] ifFalse: [ nil ])
]

{ #category : 'assessing' }
CFAtelierRelationDropSurface >> assessmentForCandidate: aCandidate [
	(description isOrdered and: [ (self currentItems ifNil: [ #() ]) isEmpty not ]) ifTrue: [
		^ CFAtelierInsertAssessment object: aCandidate items: self currentItems rejectedBecause: 'The ordered relation already has item insertion targets.' ].
	^ (self operationForCandidate: aCandidate) assess
]

{ #category : 'applying' }
CFAtelierRelationDropSurface >> applyCandidate: aCandidate [
	(description isOrdered and: [ (self currentItems ifNil: [ #() ]) isEmpty not ]) ifTrue: [
		^ CFAtelierInsertAssessment object: aCandidate items: self currentItems rejectedBecause: 'The ordered relation already has item insertion targets.' ].
	^ (self operationForCandidate: aCandidate) apply
]

{ #category : 'private - operations' }
CFAtelierRelationDropSurface >> operationForCandidate: aCandidate [
	^ description isOrdered
		ifTrue: [ CFAtelierInsert object: aCandidate memento: memento description: description at: 1 ]
		ifFalse: [ CFAtelierInsert object: aCandidate memento: memento description: description ]
]

{ #category : 'private - accessing' }
CFAtelierRelationDropSurface >> currentItems [
	^ memento readUsing: description
]

{ #category : 'private - interaction' }
CFAtelierRelationDropSurface >> updateForEvent: anEvent [
	| anAssessment |
	anEvent domainObjects size = 1 ifFalse: [ ^ self hideIndicator ].
	activeDragItem ifNil: [ ^ self hideIndicator ].
	anAssessment := (self isPaletteDragItem: activeDragItem)
		ifTrue: [ self assessmentForCandidate: activeDragItem domainObject ]
		ifFalse: [ self moveAssessmentForDragItem: activeDragItem ].
	anAssessment isApplicable
		ifTrue: [ self showIndicator ]
		ifFalse: [ self hideIndicator ]
]

{ #category : 'private - interaction' }
CFAtelierRelationDropSurface >> dropEvent: anEvent [
	| anOperation |
	self hideIndicator.
	anEvent domainObjects size = 1 ifFalse: [ ^ self ].
	activeDragItem ifNil: [ ^ self ].
	(self isPaletteDragItem: activeDragItem) ifTrue: [
		^ self applyCandidate: activeDragItem domainObject ].
	anOperation := self moveOperationForDragItem: activeDragItem.
	anOperation ifNil: [ ^ self moveAssessmentForDragItem: activeDragItem ].
	^ anOperation apply
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
