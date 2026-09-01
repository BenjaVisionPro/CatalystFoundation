"I am the common abstraction for Detail group presentation configuration. I contain configuration only and no live UI state. Concrete presentations double-dispatch to CFMaDetailGroupElement for their visual realization."

Class {
	#name : 'CFMaDetailGroupPresentationConfiguration',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'private - presentation' }
CFMaDetailGroupPresentationConfiguration >> addGroup: aGroup label: aLabel to: aGroupElement [
	self subclassResponsibility
]

{ #category : 'private - presentation' }
CFMaDetailGroupPresentationConfiguration >> newGroupsElementFor: aGroupElement [
	self subclassResponsibility
]

{ #category : 'private - presentation' }
CFMaDetailGroupPresentationConfiguration >> updateGroupSpacingIn: aGroupElement [
	self subclassResponsibility
]
