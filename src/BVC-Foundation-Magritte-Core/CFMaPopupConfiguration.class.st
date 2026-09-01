"I select a popup representation for a Foundation field. My values are presentation choices; the underlying Magritte description remains responsible for domain semantics and validation."

Class {
	#name : 'CFMaPopupConfiguration',
	#superclass : 'CFMaFieldRepresentationConfiguration',
	#instVars : [
		'values',
		'displayBlock'
	],
	#category : 'BVC-Foundation-Magritte-Core-Field',
	#package : 'BVC-Foundation-Magritte-Core',
	#tag : 'Field'
}

{ #category : 'initialization' }
CFMaPopupConfiguration >> initialize [
	super initialize.
	values := #().
	displayBlock := nil
]

{ #category : 'accessing' }
CFMaPopupConfiguration >> values [
	^ values
]

{ #category : 'accessing' }
CFMaPopupConfiguration >> values: aCollection [
	values := aCollection asArray
]


{ #category : 'accessing' }
CFMaPopupConfiguration >> displayBlock [
	^ displayBlock
]

{ #category : 'accessing' }
CFMaPopupConfiguration >> displayBlock: aBlock [
	displayBlock := aBlock
]
