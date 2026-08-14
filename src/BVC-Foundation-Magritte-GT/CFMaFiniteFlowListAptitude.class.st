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

	"BrFlowListAptitude creates the flow content and installs it inside its own
	 match-parent scrollable. Foundation relation grids are finite content inside
	 a form whose outer element owns scrolling. Keep Brick's normal flow-list
	 state, stencil, selection and listeners, but replace only that composition
	 before the aptitude is installed."
	scrollableElement removeChild: listElement.
	self changes changes removeAll.
	self
		addChangeAddChildAs: #(content list)
		with: [ listElement ]
]


{ #category : 'accessing' }
CFMaFiniteFlowListAptitude >> contentElement [
	^ listElement
]

{ #category : 'updating' }
CFMaFiniteFlowListAptitude >> updateList [
	super updateList.
	widget ifNotNil: [ widget updateResponsiveItemWidths ]
]


{ #category : 'updating' }
CFMaFiniteFlowListAptitude >> updateSelection [
	itemElements withIndexDo: [ :anItemElement :anIndex |
		(selection contains: anIndex)
			ifTrue: [ anItemElement states addState: BlElementState selected ]
			ifFalse: [ anItemElement states removeState: BlElementState selected ] ]
]
