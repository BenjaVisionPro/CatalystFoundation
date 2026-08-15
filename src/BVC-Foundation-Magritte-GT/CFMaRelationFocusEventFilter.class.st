"I am responsible for making a Foundation relation the focus owner when a click enters its subtree. Descendants remain free to take final focus through their own behaviour."

Class {
	#name : 'CFMaRelationFocusEventFilter',
	#superclass : 'BlCustomEventHandler',
	#category : 'BVC-Foundation-Magritte-GT-Support',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Support'
}

{ #category : 'api - event managing' }
CFMaRelationFocusEventFilter >> eventsToHandle [
	^ { BlClickEvent }
]

{ #category : 'api - event managing' }
CFMaRelationFocusEventFilter >> clickEvent: anEvent [
	anEvent currentTarget requestFocus
]
