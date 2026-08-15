"I am responsible for giving a Foundation relation focus when a pointer click begins anywhere within its bounds. Descendants remain responsible for their own subsequent focus behaviour."

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
	"Capture runs before descendants. This guarantees the relation receives focus even
	 when a descendant later consumes the click. A descendant that naturally requests
	 focus afterwards becomes the final focus owner, while the relation retains
	 focus-within through Bloc's bubbling focus events."
	anEvent currentTarget requestFocus
]

{ #category : 'api - event managing' }
CFMaRelationFocusEventFilter >> wantsEvent: anEvent [
	^ anEvent class == self eventClass
		or: [ anEvent class inheritsFrom: self eventClass ]
]
