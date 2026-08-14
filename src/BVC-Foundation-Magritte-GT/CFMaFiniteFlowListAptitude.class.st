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
	super initialize.

	"BrFlowListAptitude installs its list through an internal match-parent
	 scrollable. Foundation relation grids are finite content inside a form whose
	 outer element owns scrolling, so replace only that installation change while
	 retaining Brick's normal aptitude state and listener initialization."
	self changes changes removeAll.
	self
		addChangeAddChildAs: #(content list)
		with: [ self listElement ]
]
