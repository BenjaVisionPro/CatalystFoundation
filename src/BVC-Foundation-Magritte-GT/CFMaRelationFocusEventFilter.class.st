"I am responsible for making a Foundation relation the active focus context whenever a click begins anywhere inside it, while allowing the clicked descendant to take final focus afterwards."

Class {
	#name : 'CFMaRelationFocusEventFilter',
	#superclass : 'BlBasicEventHandler',
	#category : 'BVC-Foundation-Magritte-GT-Support',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Support'
}

{ #category : 'api - event managing' }
CFMaRelationFocusEventFilter >> eventClass [
	^ BlClickEvent
]

{ #category : 'api - event managing' }
CFMaRelationFocusEventFilter >> handleEvent: anEvent [
	anEvent currentTarget requestFocus
]

{ #category : 'api - event managing' }
CFMaRelationFocusEventFilter >> wantsEvent: anEvent [
	^ anEvent class == self eventClass
		or: [ anEvent class inheritsFrom: self eventClass ]
]
