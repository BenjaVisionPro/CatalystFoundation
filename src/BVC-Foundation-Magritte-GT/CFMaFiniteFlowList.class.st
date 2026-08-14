"I am responsible for a finite Foundation flow list whose surrounding form owns scrolling."

Class {
	#name : 'CFMaFiniteFlowList',
	#superclass : 'BrFlowList',
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'initialization' }
CFMaFiniteFlowList >> initialize [
	super initialize.

	self
		aptitude: CFMaFiniteFlowListAptitude new;
		hMatchParent;
		vFitContent
]
