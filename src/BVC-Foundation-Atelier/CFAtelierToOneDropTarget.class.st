"I add Atelier composition interaction to a to-one relation element produced by an existing Foundation presentation.

Palette candidates replace or fill the current value through CFAtelierReplace. Existing relation objects carry CFAtelierRelationDragContext and move into an empty to-one destination through CFAtelierMove. The to-one relation element is also an Atelier drag source while it contains an object, so that object can move to another relation or to the Atelier remove target.

I do not render the relation. The Foundation presentation supplies its existing relation element, description and memento through the relation-element configuration seam."
Class {
	#name : 'CFAtelierToOneDropTarget',
	#superclass : 'Object',
	#instVars : [
		'element',
		'memento',
		'description',
		'dropIndicator',
		'activeDragItem',
		'replaceOperationBlock',
		'moveOperationBlock'
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
	self installSourceContext.
	self installDragSource.
	dropIndicator := self newDropIndicator.
	element addChild: dropIndicator.
	element addEventHandler: (BlDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea | self acceptsDragItem: aDragItem ];
		whenDragEnteredDo: [ :anEvent | self updateForEvent: anEvent ];
		whenDragOverDo: [ :anEvent | self updateForEvent: anEvent ];
		whenDragLeftDo: [ :anEvent | self clearActiveDrag ];
		whenDroppedDo: [ :anEvent | self dropEvent: anEvent ];
		yourself)
]

{ #category : 'private - installing' }
CFAtelierToOneDropTarget >> installSourceContext [
	element userData
		at: #atelierRelationDragContext
		put: (CFAtelierRelationDragContext memento: memento description: description)
]

{ #category : 'private - installing' }
CFAtelierToOneDropTarget >> installDragSource [
	element addEventHandler: (BlDragHandler new
		liftItem: [ :aSourceElement | self dragItemsFrom: aSourceElement ];
		yourself)
]

{ #category : 'private - interaction' }
CFAtelierToOneDropTarget >> dragItemsFrom: aSourceElement [
	| anObject |
	anObject := memento readUsing: description.
	anObject ifNil: [ ^ #() ].
	^ { BlDragItem new
		sourceElement: aSourceElement;
		domainObject: anObject;
		stencil: [ :aDragItem |
			BrLabel new
				fitContent;
				padding: (BlInsets all: 7);
				aptitude: BrGlamorousLabelAptitude new;
				text: aDragItem domainObject printString;
				yourself ];
		yourself }
]

{ #category : 'testing' }
CFAtelierToOneDropTarget >> acceptsDragItem: aDragItem [
	| anAssessment |
	anAssessment := (self isPaletteDragItem: aDragItem)
		ifTrue: [ self assessmentForCandidate: aDragItem domainObject ]
		ifFalse: [ self moveAssessmentForDragItem: aDragItem ].
	anAssessment ifNil: [ ^ false ].
	anAssessment isApplicable ifFalse: [ ^ false ].
	activeDragItem := aDragItem.
	^ true
]

{ #category : 'private - testing' }
CFAtelierToOneDropTarget >> isPaletteDragItem: aDragItem [
	| aSourceElement |
	aSourceElement := aDragItem sourceElement.
	aSourceElement ifNil: [ ^ false ].
	^ aSourceElement userData includesKey: #atelierPaletteSource
]

{ #category : 'private - accessing' }
CFAtelierToOneDropTarget >> sourceContextForDragItem: aDragItem [
	| aSourceElement |
	aSourceElement := aDragItem sourceElement.
	aSourceElement ifNil: [ ^ nil ].
	^ aSourceElement userData
		at: #atelierRelationDragContext
		ifAbsent: [ nil ]
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
	| aCurrentObject |
	aCurrentObject := memento readUsing: description.
	replaceOperationBlock ifNotNil: [
		^ replaceOperationBlock value: aCandidate value: aCurrentObject value: memento value: description ].
	^ CFAtelierReplace
		object: aCurrentObject
		with: aCandidate
		memento: memento
		description: description
]

{ #category : 'assessing' }
CFAtelierToOneDropTarget >> moveAssessmentForDragItem: aDragItem [
	| anOperation |
	anOperation := self moveOperationForDragItem: aDragItem.
	anOperation ifNil: [ ^ nil ].
	^ anOperation assess
]

{ #category : 'private - operations' }
CFAtelierToOneDropTarget >> moveOperationForDragItem: aDragItem [
	| aSourceContext aDestinationContext |
	aSourceContext := self sourceContextForDragItem: aDragItem.
	aSourceContext ifNil: [ ^ nil ].
	moveOperationBlock ifNotNil: [
		aDestinationContext := CFAtelierRelationDragContext memento: memento description: description.
		^ moveOperationBlock
			value: aDragItem domainObject
			value: aSourceContext
			value: aDestinationContext
			value: nil ].
	^ CFAtelierMove
		object: aDragItem domainObject
		sourceMemento: aSourceContext memento
		sourceDescription: aSourceContext description
		destinationMemento: memento
		destinationDescription: description
		destinationIndex: nil
]

{ #category : 'private - interaction' }
CFAtelierToOneDropTarget >> updateForEvent: anEvent [
	activeDragItem ifNil: [ ^ self hideIndicator ].
	(self isPaletteDragItem: activeDragItem)
		ifTrue: [
			(self assessmentForCandidate: activeDragItem domainObject) isApplicable
				ifTrue: [ self showIndicator ]
				ifFalse: [ self hideIndicator ] ]
		ifFalse: [
			| anAssessment |
			anAssessment := self moveAssessmentForDragItem: activeDragItem.
			(anAssessment notNil and: [ anAssessment isApplicable ])
				ifTrue: [ self showIndicator ]
				ifFalse: [ self hideIndicator ] ]
]

{ #category : 'private - interaction' }
CFAtelierToOneDropTarget >> dropEvent: anEvent [
	| aDragItem anAssessment |
	self hideIndicator.
	anEvent domainObjects size = 1 ifFalse: [ ^ self clearActiveDrag ].
	aDragItem := activeDragItem.
	activeDragItem := nil.
	aDragItem ifNil: [ ^ self ].
	(self isPaletteDragItem: aDragItem)
		ifTrue: [ anAssessment := self applyCandidate: aDragItem domainObject ]
		ifFalse: [
			| anOperation |
			anOperation := self moveOperationForDragItem: aDragItem.
			anOperation ifNil: [ ^ self ].
			anAssessment := anOperation apply ].
	^ anAssessment
]

{ #category : 'private - interaction' }
CFAtelierToOneDropTarget >> clearActiveDrag [
	activeDragItem := nil.
	self hideIndicator
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

{ #category : 'configuration' }
CFAtelierToOneDropTarget >> replaceOperationFor: aBlock [ replaceOperationBlock := aBlock ]

{ #category : 'configuration' }
CFAtelierToOneDropTarget >> moveOperationFor: aBlock [ moveOperationBlock := aBlock ]
