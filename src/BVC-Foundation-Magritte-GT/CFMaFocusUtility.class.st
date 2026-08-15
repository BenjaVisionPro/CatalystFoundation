"I am responsible for answering which Foundation element already owns focus for a bubbled interaction."

Class {
	#name : 'CFMaFocusUtility',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Support',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Support'
}

{ #category : 'testing' }
CFMaFocusUtility class >> hasFocusableElementFrom: anElement before: anAncestor [
	| aCurrentElement |
	aCurrentElement := anElement.

	[ aCurrentElement isNotNil and: [ aCurrentElement ~~ anAncestor ] ] whileTrue: [
		aCurrentElement isFocusable ifTrue: [ ^ true ].
		aCurrentElement := aCurrentElement parent ].

	^ false
]
