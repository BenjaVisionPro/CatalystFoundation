"I configure a Detail group to present its immediate child groups as ordinary stacked groups. I contain configuration only and no live UI state."

Class {
	#name : 'CFMaDetailDefaultGroupConfiguration',
	#superclass : 'CFMaDetailGroupPresentationConfiguration',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'private - presentation' }
CFMaDetailDefaultGroupConfiguration >> addGroup: aGroup label: aLabel to: aGroupElement [
	^ aGroupElement addDefaultGroup: aGroup
]

{ #category : 'private - presentation' }
CFMaDetailDefaultGroupConfiguration >> newGroupsElementFor: aGroupElement [
	^ aGroupElement newDefaultGroupsElement
]

{ #category : 'private - presentation' }
CFMaDetailDefaultGroupConfiguration >> updateGroupSpacingIn: aGroupElement [
	^ aGroupElement updateDefaultGroupSpacing
]
