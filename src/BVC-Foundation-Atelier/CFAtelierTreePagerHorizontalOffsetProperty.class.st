"I expose an Atelier Tree Pager flow element's horizontal layout offset to Foundation Motion.

Atelier pages have a fixed width and one visible column. I let page settling use the same Motion ownership and interruption semantics as the rest of Foundation instead of Bloc's private tree-flow transition."
Class {
	#name : 'CFAtelierTreePagerHorizontalOffsetProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'instance creation' }
CFAtelierTreePagerHorizontalOffsetProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFAtelierTreePagerHorizontalOffsetProperty >> currentPresentationOf: anElement [
	^ anElement layout horizontalOffset
]

{ #category : 'accessing' }
CFAtelierTreePagerHorizontalOffsetProperty >> apply: anOffset to: anElement [
	anElement layout horizontalOffset: anOffset.
	anElement requestLayout
]
