"I am responsible for applying standard Foundation relation selection to a finite flow-list item without stealing focus from interactive descendants."

Class {
	#name : 'CFMaFiniteListItemSelectionHandler',
	#superclass : 'BlBasicEventHandler',
	#instVars : [
		'listWidget',
		'itemIndex'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing' }
CFMaFiniteListItemSelectionHandler >> itemIndex: anInteger [
	itemIndex := anInteger
]

{ #category : 'accessing' }
CFMaFiniteListItemSelectionHandler >> listWidget: aListWidget [
	listWidget := aListWidget
]

{ #category : 'api - event managing' }
CFMaFiniteListItemSelectionHandler >> eventClass [
	^ BlClickEvent
]

{ #category : 'api - event managing' }
CFMaFiniteListItemSelectionHandler >> handleEvent: anEvent [
	listWidget selectOne: itemIndex dueTo: anEvent.

	(CFMaFocusUtility
		hasFocusableElementFrom: anEvent target
		before: anEvent currentTarget)
		ifFalse: [ listWidget requestFocus ]
]

{ #category : 'api - event managing' }
CFMaFiniteListItemSelectionHandler >> wantsEvent: anEvent [
	^ anEvent class == self eventClass
		or: [ anEvent class inheritsFrom: self eventClass ]
]
