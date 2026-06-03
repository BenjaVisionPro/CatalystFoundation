Class {
	#name : 'CFMaCompactListItemElementBuilder',
	#superclass : 'CFMaElementBuilder',
	#instVars : [
		'fieldIndex'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'elements' }
CFMaCompactListItemElementBuilder >> addFieldElement: aFieldElement using: aDescription [
	fieldIndex := fieldIndex + 1.
	self form
		addFieldElement: aFieldElement
		at: fieldIndex
		using: aDescription.
	^ aFieldElement
]

{ #category : 'initialization' }
CFMaCompactListItemElementBuilder >> initialize [
	super initialize.
	fieldIndex := 0
]
