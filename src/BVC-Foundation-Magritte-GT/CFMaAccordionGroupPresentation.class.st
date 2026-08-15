"I am responsible for presenting each Magritte group as a Brick accordion."

Class {
	#name : 'CFMaAccordionGroupPresentation',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'building' }
CFMaAccordionGroupPresentation >> newContextIn: aHostElement labelPresentation: aLabelPresentation [
	^ CFMaAccordionGroupPresentationContext new
		hostElement: aHostElement;
		labelPresentation: aLabelPresentation;
		yourself
]
