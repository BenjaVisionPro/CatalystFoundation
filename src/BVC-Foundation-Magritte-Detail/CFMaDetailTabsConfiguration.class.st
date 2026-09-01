"I configure a Detail group to present its immediate child groups as tabs. I contain configuration only and no live UI state."

Class {
	#name : 'CFMaDetailTabsConfiguration',
	#superclass : 'CFMaDetailGroupPresentationConfiguration',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'private - presentation' }
CFMaDetailTabsConfiguration >> addGroup: aGroup label: aLabel to: aGroupElement [
	^ aGroupElement addTabGroup: aGroup label: aLabel
]

{ #category : 'private - presentation' }
CFMaDetailTabsConfiguration >> newGroupsElementFor: aGroupElement [
	^ aGroupElement newTabGroupsElement
]

{ #category : 'private - presentation' }
CFMaDetailTabsConfiguration >> updateGroupSpacingIn: aGroupElement [
	^ self
]
