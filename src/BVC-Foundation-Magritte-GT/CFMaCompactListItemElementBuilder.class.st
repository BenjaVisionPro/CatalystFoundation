Class {
	#name : 'CFMaCompactListItemElementBuilder',
	#superclass : 'CFMaElementBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'elements' }
CFMaCompactListItemElementBuilder >> addFieldElement: aFieldElement using: aDescription [
	self form
		addFieldElement: aFieldElement
		using: aDescription.
	^ aFieldElement
]
