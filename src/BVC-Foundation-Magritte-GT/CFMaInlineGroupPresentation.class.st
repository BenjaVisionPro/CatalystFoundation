"I am responsible for presenting Magritte groups as headings followed by their fields."

Class {
	#name : 'CFMaInlineGroupPresentation',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'building' }
CFMaInlineGroupPresentation >> newContextIn: aHostElement labelPresentation: aLabelPresentation [
	^ CFMaInlineGroupPresentationContext new
		hostElement: aHostElement;
		labelPresentation: aLabelPresentation;
		yourself
]
