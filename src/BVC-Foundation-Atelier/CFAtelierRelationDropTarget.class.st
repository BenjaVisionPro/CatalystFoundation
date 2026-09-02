"I add Atelier palette insertion interaction to one relation item element produced by an existing Foundation presentation.

I do not render the relation item. The presentation supplies the row, object, description and memento through its relation-item configuration seam. I accept only drag items whose source was explicitly marked as an Atelier palette source, so the Foundation Detail presentation's existing same-relation reorder interaction remains independent.

For this first direct-composition surface I install on ordered to-many rows. The pointer half of the row determines insertion immediately before or after the target object, and CFAtelierInsert performs assessment and mandatory fresh reassessment before the memento write."
Class {
	#name : 'CFAtelierRelationDropTarget',
	#superclass : 'Object',
	#instVars : [
		'element',
		'targetObject',
		'memento',
		'description',
		'dropIndicator'
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
	| aSourceElement |
	aSourceElement := aDragItem sourceElement.
	aSourceElement ifNil: [ ^ false ].
	(aSourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	^ (self assessmentForCandidate: aDragItem domainObject after: false) isApplicable
		or: [ (self assessmentForCandidate: aDragItem domainObject after: true) isApplicable ]
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
	isAfter := self eventIsAfterTarget: anEvent.
	anAssessment := self
		assessmentForCandidate: anEvent domainObjects first
		after: isAfter.
	anAssessment isApplicable
		ifTrue: [ self showIndicatorAfter: isAfter ]
		ifFalse: [ self hideIndicator ]
]

{ #category : 'private - interaction' }
CFAtelierRelationDropTarget >> dropEvent: anEvent [
	| anAssessment |
	self hideIndicator.
	anEvent domainObjects size = 1 ifFalse: [ ^ self ].
	anAssessment := self
		applyCandidate: anEvent domainObjects first
		after: (self eventIsAfterTarget: anEvent).
	^ anAssessment
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
