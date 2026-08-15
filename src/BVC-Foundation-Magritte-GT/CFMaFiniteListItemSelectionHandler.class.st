"I am responsible for applying standard Foundation relation selection to a finite flow-list item without stealing focus from interactive descendants. A repeat click activates the selected object through Phlow, matching ordinary relation lists."

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
	| wasAlreadySelected hasFocusedTarget |
	wasAlreadySelected := listWidget selectedIndices
		anySatisfy: [ :eachIndex | eachIndex = itemIndex ].

	listWidget selectOne: itemIndex dueTo: anEvent.

	hasFocusedTarget := CFMaFocusUtility
		hasFocusedElementFrom: anEvent target
		before: anEvent currentTarget.
	hasFocusedTarget
		ifFalse: [ listWidget requestFocus ].

	(wasAlreadySelected and: [ hasFocusedTarget not ])
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


