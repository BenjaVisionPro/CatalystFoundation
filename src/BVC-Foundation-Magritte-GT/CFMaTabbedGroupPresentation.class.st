"I am responsible for presenting Magritte groups as tabs whose contents are the fields in each group."

Class {
	#name : 'CFMaTabbedGroupPresentation',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'building' }
CFMaTabbedGroupPresentation >> newContextIn: aHostElement labelPresentation: aLabelPresentation [
	^ CFMaTabbedGroupPresentationContext new
		hostElement: aHostElement;
		labelPresentation: aLabelPresentation;
		yourself
]
