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
	| wasAlreadySelected hasInteractiveTarget |
	wasAlreadySelected := listWidget selectedIndices
		anySatisfy: [ :eachIndex | eachIndex = itemIndex ].

	hasInteractiveTarget := CFMaFocusUtility
		hasFocusableElementFrom: anEvent target
		before: anEvent currentTarget.

	listWidget selectOne: itemIndex dueTo: anEvent.
	hasInteractiveTarget
		ifFalse: [ self focusRelationSurfaceFrom: anEvent currentTarget ].

	(wasAlreadySelected and: [ hasInteractiveTarget not ])
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


{ #category : 'private - focus' }
CFMaFiniteListItemSelectionHandler >> focusRelationSurfaceFrom: anElement [
	| aCurrentElement |
	aCurrentElement := anElement.

	[ aCurrentElement isNotNil ] whileTrue: [
		(aCurrentElement isKindOf: CFMaRelationSurfaceElement)
			ifTrue: [
				aCurrentElement requestFocus.
				^ aCurrentElement ].
		aCurrentElement := aCurrentElement parent ].

	^ nil
]
