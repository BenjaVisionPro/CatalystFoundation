"I am responsible for creating a compact editable Foundation identity affordance from a Magritte memento."

Class {
	#name : 'CFMaIdentityAffordanceStencil',
	#superclass : 'BrStencil',
	#instVars : [
		'memento'
	],
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaIdentityAffordanceStencil >> create [
	^ CFMaIdentityAffordanceElement new
		memento: memento;
		yourself
]

{ #category : 'accessing' }
CFMaIdentityAffordanceStencil >> memento [
	^ memento
]

{ #category : 'accessing' }
CFMaIdentityAffordanceStencil >> memento: aMemento [
	memento := aMemento
]
