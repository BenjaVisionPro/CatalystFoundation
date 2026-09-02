"I add Atelier palette replacement interaction to a to-one relation element produced by an existing Foundation presentation.

I do not render the relation. The presentation supplies its existing row, description and memento through the relation-element configuration seam. A palette candidate replaces the current staged value through CFAtelierReplace; nil is a valid expected current value, so the same operation also fills an empty to-one relation. I accept only explicitly marked Atelier palette drag sources."
Class {
	#name : 'CFAtelierToOneDropTarget',
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
CFAtelierToOneDropTarget class >> installOn: anElement memento: aMemento description: aDescription [
	^ self new
		element: anElement;
		memento: aMemento;
		description: aDescription;
		install;
		yourself
]

{ #category : 'instance creation' }
CFAtelierToOneDropTarget class >> memento: aMemento description: aDescription [
	^ self new
		memento: aMemento;
		description: aDescription;
		yourself
]

{ #category : 'installing' }
CFAtelierToOneDropTarget >> install [
	description isMultiple ifTrue: [ ^ self ].

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
CFAtelierToOneDropTarget >> acceptsDragItem: aDragItem [
	| aSourceElement |
	aSourceElement := aDragItem sourceElement.
	aSourceElement ifNil: [ ^ false ].
	(aSourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	^ (self assessmentForCandidate: aDragItem domainObject) isApplicable
]

{ #category : 'assessing' }
CFAtelierToOneDropTarget >> assessmentForCandidate: aCandidate [
	^ (self operationForCandidate: aCandidate) assess
]

{ #category : 'applying' }
CFAtelierToOneDropTarget >> applyCandidate: aCandidate [
	^ (self operationForCandidate: aCandidate) apply
]

{ #category : 'private - operations' }
CFAtelierToOneDropTarget >> operationForCandidate: aCandidate [
	^ CFAtelierReplace
		object: (memento readUsing: description)
		with: aCandidate
		memento: memento
		description: description
]

{ #category : 'private - interaction' }
CFAtelierToOneDropTarget >> updateForEvent: anEvent [
	anEvent domainObjects size = 1 ifFalse: [ ^ self hideIndicator ].
	(self assessmentForCandidate: anEvent domainObjects first) isApplicable
		ifTrue: [ self showIndicator ]
		ifFalse: [ self hideIndicator ]
]

{ #category : 'private - interaction' }
CFAtelierToOneDropTarget >> dropEvent: anEvent [
	| anAssessment |
	self hideIndicator.
	anEvent domainObjects size = 1 ifFalse: [ ^ self ].
	anAssessment := self applyCandidate: anEvent domainObjects first.
	^ anAssessment
]

{ #category : 'private - appearance' }
CFAtelierToOneDropTarget >> newDropIndicator [
	^ BlElement new
		background: Color transparent;
		border: (BlBorder paint: (element theme interaction focusedBorderColor blocResolveColorForTheme: element theme) width: 2);
		visibility: BlVisibility hidden;
		zIndex: 101;
		constraintsDo: [ :c |
			c ignoreByLayout.
			c horizontal matchParent.
			c vertical matchParent ];
		yourself
]

{ #category : 'private - appearance' }
CFAtelierToOneDropTarget >> showIndicator [
	dropIndicator visibility: BlVisibility visible
]

{ #category : 'private - appearance' }
CFAtelierToOneDropTarget >> hideIndicator [
	dropIndicator ifNotNil: [ dropIndicator visibility: BlVisibility hidden ]
]

{ #category : 'accessing' }
CFAtelierToOneDropTarget >> element: anElement [ element := anElement ]
{ #category : 'accessing' }
CFAtelierToOneDropTarget >> memento: aMemento [ memento := aMemento ]
{ #category : 'accessing' }
CFAtelierToOneDropTarget >> description: aDescription [ description := aDescription ]
