"I select Foundation's ordinary object-identity list representation for a relation. I carry no renderer-specific state."

Class {
	#name : 'CFMaListConfiguration',
	#superclass : 'CFMaFieldRepresentationConfiguration',
	#instVars : [
		'allowsMultipleSelection'
	],
	#category : 'BVC-Foundation-Magritte-Core-Field',
	#package : 'BVC-Foundation-Magritte-Core',
	#tag : 'Field'
}

{ #category : 'initialization' }
CFMaListConfiguration >> initialize [
	super initialize.
	allowsMultipleSelection := true
]

{ #category : 'accessing' }
CFMaListConfiguration >> allowsMultipleSelection [
	^ allowsMultipleSelection
]

{ #category : 'configuration - selection' }
CFMaListConfiguration >> beSingleSelection [
	allowsMultipleSelection := false
]

{ #category : 'configuration - selection' }
CFMaListConfiguration >> beMultipleSelection [
	allowsMultipleSelection := true
]

