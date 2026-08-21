"I select a popup representation for a Foundation field. My values are presentation choices; the underlying Magritte description remains responsible for domain semantics and validation."

Class {
	#name : 'CFMaPopupConfiguration',
	#superclass : 'Object',
	#instVars : [
		'values'
	],
	#category : 'BVC-Foundation-Magritte-Core-Field',
	#package : 'BVC-Foundation-Magritte-Core',
	#tag : 'Field'
}

{ #category : 'initialization' }
CFMaPopupConfiguration >> initialize [
	super initialize.
	values := #()
]

{ #category : 'accessing' }
CFMaPopupConfiguration >> values [
	^ values
]

{ #category : 'accessing' }
CFMaPopupConfiguration >> values: aCollection [
	values := aCollection asArray
]
