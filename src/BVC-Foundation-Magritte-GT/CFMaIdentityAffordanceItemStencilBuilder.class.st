"
I am responsible for presenting one relation item as a compact editable identity affordance.
"
Class {
	#name : 'CFMaIdentityAffordanceItemStencilBuilder',
	#superclass : 'BrListRowStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaIdentityAffordanceItemStencilBuilder >> buildDefault [
	self rowValue ifNil: [ ^ BrFrame new fitContent ].
	^ CFMaIdentityAffordanceStencil new
		memento: self rowValue memento;
		create
]
