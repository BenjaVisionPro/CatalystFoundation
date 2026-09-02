"I am an Atelier-owned drop surface for explicitly removing an existing object from its source Magritte relation.

I accept only drags that carry CFAtelierRelationDragContext. Assessment and application are delegated to CFAtelierRemove, so stale source state and relation validation are handled by the ordinary Atelier operation lifecycle. I do not decide wider domain removal semantics."
Class {
	#name : 'CFAtelierRemoveDropTarget',
	#superclass : 'BrLabel',
	#instVars : [
		'activeDragItem'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'initialization' }
CFAtelierRemoveDropTarget >> initialize [
	super initialize.
	self
		hExact: 96;
		vFitContent;
		padding: (BlInsets top: 7 left: 10 bottom: 7 right: 10);
		aptitude: BrGlamorousLabelAptitude new;
		text: 'Remove'.
	self addEventHandler: (BlDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea | self acceptsDragItem: aDragItem ];
		whenDragEnteredDo: [ :anEvent | self updateAppearance ];
		whenDragOverDo: [ :anEvent | self updateAppearance ];
		whenDragLeftDo: [ :anEvent | self clearActiveDrag ];
		whenDroppedDo: [ :anEvent | self dropEvent: anEvent ];
		yourself)
]

{ #category : 'testing' }
CFAtelierRemoveDropTarget >> acceptsDragItem: aDragItem [
	| anOperation |
	anOperation := self operationForDragItem: aDragItem.
	anOperation ifNil: [ ^ false ].
	(anOperation assess isApplicable) ifFalse: [ ^ false ].
	activeDragItem := aDragItem.
	^ true
]

{ #category : 'assessing' }
CFAtelierRemoveDropTarget >> assessmentForDragItem: aDragItem [
	| anOperation |
	anOperation := self operationForDragItem: aDragItem.
	anOperation ifNil: [ ^ nil ].
	^ anOperation assess
]

{ #category : 'applying' }
CFAtelierRemoveDropTarget >> applyDragItem: aDragItem [
	| anOperation |
	anOperation := self operationForDragItem: aDragItem.
	anOperation ifNil: [ ^ nil ].
	^ anOperation apply
]

{ #category : 'private - operations' }
CFAtelierRemoveDropTarget >> operationForDragItem: aDragItem [
	| aContext |
	aContext := self sourceContextForDragItem: aDragItem.
	aContext ifNil: [ ^ nil ].
	^ CFAtelierRemove
		object: aDragItem domainObject
		memento: aContext memento
		description: aContext description
]

{ #category : 'private - accessing' }
CFAtelierRemoveDropTarget >> sourceContextForDragItem: aDragItem [
	| aSourceElement |
	aSourceElement := aDragItem sourceElement.
	aSourceElement ifNil: [ ^ nil ].
	^ aSourceElement userData
		at: #atelierRelationDragContext
		ifAbsent: [ nil ]
]

{ #category : 'private - interaction' }
CFAtelierRemoveDropTarget >> dropEvent: anEvent [
	| aDragItem |
	anEvent domainObjects size = 1 ifFalse: [ ^ self clearActiveDrag ].
	aDragItem := activeDragItem.
	self clearActiveDrag.
	aDragItem ifNil: [ ^ self ].
	^ self applyDragItem: aDragItem
]

{ #category : 'private - appearance' }
CFAtelierRemoveDropTarget >> updateAppearance [
	self border: (BlBorder
		paint: (self theme interaction focusedBorderColor blocResolveColorForTheme: self theme)
		width: 2)
]

{ #category : 'private - interaction' }
CFAtelierRemoveDropTarget >> clearActiveDrag [
	activeDragItem := nil.
	self border: BlBorder empty
]
