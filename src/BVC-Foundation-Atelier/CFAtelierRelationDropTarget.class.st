"I add Atelier composition interaction to one ordered to-many relation item row produced by an existing Foundation presentation.

Palette drags use CFAtelierInsert. Existing relation-item drags from a different relation use CFAtelierMove. A drag from the same relation remains Foundation Detail's existing reorder interaction because CFAtelierMove rejects identical source and destination contexts. I add interaction to the rendered row; I do not render it."
Class {
	#name : 'CFAtelierRelationDropTarget',
	#superclass : 'Object',
	#instVars : [
		'element',
		'targetObject',
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
CFAtelierRelationDropTarget class >> installOn: anElement targetObject: anObject memento: aMemento description: aDescription [
	^ self new
		element: anElement;
		targetObject: anObject;
		memento: aMemento;
		description: aDescription;
		installSourceContext;
		install;
		yourself
]

{ #category : 'instance creation' }
CFAtelierRelationDropTarget class >> targetObject: anObject memento: aMemento description: aDescription [
	^ self new
		targetObject: anObject;
		memento: aMemento;
		description: aDescription;
		yourself
]

{ #category : 'installing' }
CFAtelierRelationDropTarget >> install [
	description isMultiple ifFalse: [ ^ self ].
	description isOrdered ifFalse: [ ^ self ].

	dropIndicator := self newDropIndicator.
	element addChild: dropIndicator.
	element addEventHandler: (BlDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea |
			self acceptsDragItem: aDragItem ];
		whenDragEnteredDo: [ :anEvent | self updateForEvent: anEvent ];
		whenDragOverDo: [ :anEvent | self updateForEvent: anEvent ];
		whenDragLeftDo: [ :anEvent | self hideIndicator ];
		whenDroppedDo: [ :anEvent | self dropEvent: anEvent ];
		yourself)
]

{ #category : 'testing' }
CFAtelierRelationDropTarget >> acceptsDragItem: aDragItem [
	| isApplicable |
	isApplicable := (self isPaletteDragItem: aDragItem)
		ifTrue: [ (self assessmentForCandidate: aDragItem domainObject after: false) isApplicable
			or: [ (self assessmentForCandidate: aDragItem domainObject after: true) isApplicable ] ]
		ifFalse: [ (self moveAssessmentForDragItem: aDragItem after: false) isApplicable
			or: [ (self moveAssessmentForDragItem: aDragItem after: true) isApplicable ] ].
	isApplicable ifTrue: [ activeDragItem := aDragItem ].
	^ isApplicable
]

{ #category : 'private - interaction' }
CFAtelierRelationDropTarget >> installSourceContext [
	element userData
		at: #atelierRelationDragContext
		put: (CFAtelierRelationDragContext memento: memento description: description)
]

{ #category : 'private - testing' }
CFAtelierRelationDropTarget >> isPaletteDragItem: aDragItem [
	| aSourceElement |
	aSourceElement := aDragItem sourceElement.
	aSourceElement ifNil: [ ^ false ].
	^ aSourceElement userData includesKey: #atelierPaletteSource
]

{ #category : 'private - accessing' }
CFAtelierRelationDropTarget >> sourceContextForDragItem: aDragItem [
	| aSourceElement |
	aSourceElement := aDragItem sourceElement.
	aSourceElement ifNil: [ ^ nil ].
	^ aSourceElement userData at: #atelierRelationDragContext ifAbsent: [ nil ]
]

{ #category : 'assessing' }
CFAtelierRelationDropTarget >> moveAssessmentForDragItem: aDragItem after: aBoolean [
	| anOperation |
	anOperation := self moveOperationForDragItem: aDragItem after: aBoolean.
	anOperation ifNil: [
		^ CFAtelierMoveAssessment
			sourceItems: nil
			destinationItems: (memento readUsing: description)
			rejectedBecause: 'The drag item has no Atelier relation source context.' ].
	^ anOperation assess
]

{ #category : 'private - operations' }
CFAtelierRelationDropTarget >> moveOperationForDragItem: aDragItem after: aBoolean [
	| aSourceContext anIndex |
	aSourceContext := self sourceContextForDragItem: aDragItem.
	aSourceContext ifNil: [ ^ nil ].
	anIndex := self insertionIndexAfter: aBoolean.
	anIndex ifNil: [ ^ nil ].
	^ CFAtelierMove
		object: aDragItem domainObject
		sourceMemento: aSourceContext memento
		sourceDescription: aSourceContext description
		destinationMemento: memento
		destinationDescription: description
		destinationIndex: anIndex
]

{ #category : 'assessing' }
CFAtelierRelationDropTarget >> assessmentForCandidate: aCandidate after: aBoolean [
	^ (self operationForCandidate: aCandidate after: aBoolean) assess
]

{ #category : 'applying' }
CFAtelierRelationDropTarget >> applyCandidate: aCandidate after: aBoolean [
	^ (self operationForCandidate: aCandidate after: aBoolean) apply
]

{ #category : 'private - operations' }
CFAtelierRelationDropTarget >> operationForCandidate: aCandidate after: aBoolean [
	| anIndex |
	anIndex := self insertionIndexAfter: aBoolean.
	anIndex ifNil: [
		^ CFAtelierInsert
			object: aCandidate
			memento: memento
			description: description
			at: 0 ].
	^ CFAtelierInsert
		object: aCandidate
		memento: memento
		description: description
		at: anIndex
]

{ #category : 'private - operations' }
CFAtelierRelationDropTarget >> insertionIndexAfter: aBoolean [
	| theItems anIndex |
	theItems := memento readUsing: description.
	theItems ifNil: [ ^ nil ].
	anIndex := theItems identityIndexOf: targetObject ifAbsent: [ ^ nil ].
	^ aBoolean
		ifTrue: [ anIndex + 1 ]
		ifFalse: [ anIndex ]
]

{ #category : 'private - interaction' }
CFAtelierRelationDropTarget >> eventIsAfterTarget: anEvent [
	^ anEvent position y >= element bounds inLocal center y
]

{ #category : 'private - interaction' }
CFAtelierRelationDropTarget >> updateForEvent: anEvent [
	| anAssessment isAfter |
	anEvent domainObjects size = 1 ifFalse: [ ^ self hideIndicator ].
	activeDragItem ifNil: [ ^ self hideIndicator ].
	isAfter := self eventIsAfterTarget: anEvent.
	anAssessment := (self isPaletteDragItem: activeDragItem)
		ifTrue: [ self assessmentForCandidate: activeDragItem domainObject after: isAfter ]
		ifFalse: [ self moveAssessmentForDragItem: activeDragItem after: isAfter ].
	anAssessment isApplicable
		ifTrue: [ self showIndicatorAfter: isAfter ]
		ifFalse: [ self hideIndicator ]
]
{ #category : 'private - interaction' }
CFAtelierRelationDropTarget >> dropEvent: anEvent [
	| anOperation isAfter |
	self hideIndicator.
	anEvent domainObjects size = 1 ifFalse: [ ^ self ].
	activeDragItem ifNil: [ ^ self ].
	isAfter := self eventIsAfterTarget: anEvent.
	(self isPaletteDragItem: activeDragItem) ifTrue: [
		^ self applyCandidate: activeDragItem domainObject after: isAfter ].
	anOperation := self moveOperationForDragItem: activeDragItem after: isAfter.
	anOperation ifNil: [ ^ self moveAssessmentForDragItem: activeDragItem after: isAfter ].
	^ anOperation apply
]
{ #category : 'private - appearance' }
CFAtelierRelationDropTarget >> newDropIndicator [
	^ BlElement new
		background: (element theme interaction focusedBorderColor blocResolveColorForTheme: element theme);
		visibility: BlVisibility hidden;
		zIndex: 101;
		constraintsDo: [ :c |
			c ignoreByLayout.
			c horizontal matchParent.
			c vertical exact: 2.
			c ignored horizontal alignCenter.
			c ignored vertical alignTop ];
		yourself
]

{ #category : 'private - appearance' }
CFAtelierRelationDropTarget >> showIndicatorAfter: aBoolean [
	dropIndicator constraintsDo: [ :c |
		aBoolean
			ifTrue: [ c ignored vertical alignBottom ]
			ifFalse: [ c ignored vertical alignTop ] ].
	dropIndicator visibility: BlVisibility visible
]

{ #category : 'private - appearance' }
CFAtelierRelationDropTarget >> hideIndicator [
	dropIndicator ifNotNil: [ dropIndicator visibility: BlVisibility hidden ]
]

{ #category : 'accessing' }
CFAtelierRelationDropTarget >> element: anElement [ element := anElement ]
{ #category : 'accessing' }
CFAtelierRelationDropTarget >> targetObject: anObject [ targetObject := anObject ]
{ #category : 'accessing' }
CFAtelierRelationDropTarget >> memento: aMemento [ memento := aMemento ]
{ #category : 'accessing' }
CFAtelierRelationDropTarget >> description: aDescription [ description := aDescription ]
