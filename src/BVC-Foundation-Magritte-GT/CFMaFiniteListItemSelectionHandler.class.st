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
	| wasAlreadySelected hasInteractiveTarget |
	hasInteractiveTarget := CFMaFocusUtility
		hasFocusableElementFrom: anEvent target
		before: anEvent currentTarget.

	hasInteractiveTarget ifTrue: [
		"The descendant already had first opportunity to handle the click. Select
		 the enclosing item but preserve descendant focus and stop the enclosing
		 list/relation from subsequently stealing it."
		listWidget selectOne: itemIndex dueTo: anEvent.
		anEvent consumed: true.
		^ self ].

	wasAlreadySelected := listWidget selectedIndices
		anySatisfy: [ :eachIndex | eachIndex = itemIndex ].

	"Match BrListClickToSelectHandler: focus precedes the synchronous
	 BrSelectionChanged notification, and the row owns the click."
	anEvent consumed: true.
	listWidget requestFocus.
	listWidget selectOne: itemIndex dueTo: anEvent.

	wasAlreadySelected ifTrue: [ self activateCurrentSelection ]
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
