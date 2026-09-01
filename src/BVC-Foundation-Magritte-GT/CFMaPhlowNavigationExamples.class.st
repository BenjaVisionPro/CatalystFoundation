Class {
	#name : 'CFMaPhlowNavigationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'examples - tree pager' }
CFMaPhlowNavigationExamples >> immediateLinkMatchesPhlowToolObjectByIdentity [
	<gtExample>
	| aParentPane aChildPane anObject anEqualObject aLink |
	anObject := 'related object' copy.
	anEqualObject := anObject copy.
	aParentPane := GtTreePagerPaneModel new.
	aChildPane := GtTreePagerPaneModel new object: anObject.
	aParentPane selectPane: aChildPane.
	aLink := aParentPane followingLinks first.

	self assert: anObject = anEqualObject.
	self assert: anObject ~~ anEqualObject.
	self
		assert: (CFMaPhlowNavigation immediateLinkFrom: aParentPane showing: anObject)
		equals: aLink.
	self
		assert: (CFMaPhlowNavigation immediateLinkFrom: aParentPane showing: anEqualObject)
		equals: nil.
	^ aParentPane
]

{ #category : 'examples - tree pager' }
CFMaPhlowNavigationExamples >> immediateSpawnedLinkMatchesPhlowToolObjectByIdentity [
	<gtExample>
	| aParentPane aChildPane anObject aLink |
	anObject := Object new.
	aParentPane := GtTreePagerPaneModel new.
	aChildPane := GtTreePagerPaneModel new object: anObject.
	aParentPane spawnSiblingPane: aChildPane.
	aLink := aParentPane spawnedFollowingLinks first.

	self
		assert: (CFMaPhlowNavigation immediateSpawnedLinkFrom: aParentPane showing: anObject)
		equals: aLink.
	self
		assert: (CFMaPhlowNavigation immediateSpawnedLinkFrom: aParentPane showing: Object new)
		equals: nil.
	^ aParentPane
]
