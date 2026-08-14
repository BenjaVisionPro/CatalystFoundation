"I am responsible for presenting one relation item as a Foundation Phlow link."

Class {
	#name : 'CFMaPhlowLinkItemStencilBuilder',
	#superclass : 'BrListRowStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaPhlowLinkItemStencilBuilder >> buildDefault [
	| anObject |
	self rowValue ifNil: [ ^ BrFrame new fitContent ].
	anObject := self rowValue object.
	^ BrButton new
		aptitude: BrGlamorousLinkButtonWithLabelAptitude new;
		label: anObject gtDisplayText asString;
		alignCenterLeft;
		hFitContent;
		vFitContent;
		action: [ :aButton | aButton phlow spawnObject: anObject ];
		yourself
]
