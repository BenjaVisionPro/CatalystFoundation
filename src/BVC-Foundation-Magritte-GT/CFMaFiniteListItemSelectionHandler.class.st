"I am responsible for applying Brick-compatible selection and focus behaviour to a finite Foundation relation item."

Class {
	#name : 'CFMaFiniteListItemSelectionHandler',
	#superclass : 'BlBasicEventHandler',
	#instVars : [
		'listWidget',
		'itemIndex',
		'transformation'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaFiniteListItemSelectionHandler >> initialize [
	super initialize.
	transformation := GtPhlowSendTransformation default
]

{ #category : 'accessing' }
CFMaFiniteListItemSelectionHandler >> itemIndex: anInteger [
	itemIndex := anInteger
]

{ #category : 'accessing' }
CFMaFiniteListItemSelectionHandler >> listWidget: aListWidget [
	listWidget := aListWidget
]

{ #category : 'accessing' }
CFMaFiniteListItemSelectionHandler >> transformation: aTransformation [
	transformation := aTransformation asPhlowSendTransformation
]

{ #category : 'api - event managing' }
CFMaFiniteListItemSelectionHandler >> eventClass [
	^ BlClickEvent
]

{ #category : 'api - event managing' }
CFMaFiniteListItemSelectionHandler >> handleEvent: anEvent [
	| wasAlreadySelected itemHasFocus |
	wasAlreadySelected := listWidget selectedIndices
		anySatisfy: [ :eachIndex | eachIndex = itemIndex ].

	"By the time a bubbling handler runs, embedded controls and embedded form
	 roots have already had the opportunity to claim focus. Use the actual focus
	 state, not whether some descendant happens to be focusable."
	itemHasFocus := anEvent currentTarget hasFocus.

	anEvent consumed: true.
	itemHasFocus
		ifFalse: [ listWidget requestFocus ].
	listWidget selectOne: itemIndex dueTo: anEvent.

	(wasAlreadySelected and: [ itemHasFocus not ])
		ifTrue: [ self activateCurrentSelection ]
]

{ #category : 'private - activation' }
CFMaFiniteListItemSelectionHandler >> activateCurrentSelection [
	| theIndices selectedObject |
	theIndices := listWidget selectedIndices.
	theIndices isEmpty ifTrue: [ ^ self ].

	selectedObject := listWidget selectionCallback value: theIndices.
	transformation
		select: selectedObject
		indices: theIndices
		from: listWidget
		shouldShowSpace: false
]

{ #category : 'api - event managing' }
CFMaFiniteListItemSelectionHandler >> wantsEvent: anEvent [
	^ anEvent class == self eventClass
		or: [ anEvent class inheritsFrom: self eventClass ]
]
