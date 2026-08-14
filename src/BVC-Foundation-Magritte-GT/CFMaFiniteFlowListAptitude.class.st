"I am responsible for presenting a BrFlowList as finite content so its parent can own scrolling."

Class {
	#name : 'CFMaFiniteFlowListAptitude',
	#superclass : 'BrFlowListAptitude',
	#category : 'BVC-Foundation-Magritte-GT-Aptitudes',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Aptitudes'
}

{ #category : 'initialization' }
CFMaFiniteFlowListAptitude >> initialize [
	BrAptitude initialize.

	items := #().
	itemElements := #().
	selection := BlSelection empty.

	listElement := BlElement new.
	listElement
		layout: BlFlowLayout horizontal;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ].

	self itemStencilBuilder: BrSimpleListRowStencilBuilder new.

	self
		addChangeAddChildAs: #(content list)
		with: [ listElement ]
]
