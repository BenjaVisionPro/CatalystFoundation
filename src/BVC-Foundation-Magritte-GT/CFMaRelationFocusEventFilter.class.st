"I am responsible for establishing a Foundation relation as the focus context when primary pointer interaction begins anywhere in its subtree. I do not consume the event; descendants remain responsible for their own focus and interaction."

Class {
	#name : 'CFMaRelationFocusEventFilter',
	#superclass : 'BlCustomEventHandler',
	#category : 'BVC-Foundation-Magritte-GT-Support',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Support'
}

{ #category : 'api - event managing' }
CFMaRelationFocusEventFilter >> eventsToHandle [
	^ { BlMouseDownEvent }
]

{ #category : 'api - event managing' }
CFMaRelationFocusEventFilter >> mouseDownEvent: anEvent [
	anEvent primaryButtonPressed ifTrue: [
		anEvent currentTarget requestFocus ]
]
