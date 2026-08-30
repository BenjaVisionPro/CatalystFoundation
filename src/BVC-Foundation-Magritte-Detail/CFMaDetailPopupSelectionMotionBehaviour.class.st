"I present one off/on popup-selection blink cycle through the BrSimpleList that owns selection.

The first half of one cycle is deselected and the second half is selected.
CFMotionTimeline owns cycle timing and repetition. I deliberately do not restore
selection between repeated cycles; cancellation restores the selection that was
present when playback began."
Class {
	#name : 'CFMaDetailPopupSelectionMotionBehaviour',
	#superclass : 'CFMotionBehaviour',
	#instVars : [
		'list',
		'index',
		'originIndices'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'instance creation' }
CFMaDetailPopupSelectionMotionBehaviour class >> on: aList index: anIndex [
	^ self new
		list: aList;
		index: anIndex;
		yourself
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionBehaviour >> animationTarget [
	^ list
]

{ #category : 'private - presentation' }
CFMaDetailPopupSelectionMotionBehaviour >> applySelected: aBoolean [
	aBoolean
		ifTrue: [ list selectOne: index ]
		ifFalse: [ list deselectAll ]
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> applyDestination [
	self applySelected: true
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> applyProgress: aProgress [
	Transcript
		show: 'POPUP blink applyProgress=';
		show: aProgress printString;
		cr.
	self applySelected: aProgress >= 0.5
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> captureOrigin [
	originIndices ifNil: [ originIndices := list selectedIndices copy ]
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionBehaviour >> index: anIndex [
	index := anIndex
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionBehaviour >> list: aList [
	list := aList
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> prepareForTimelineCycle: aCycleIndex [
	"A repeated blink begins directly at its cycle presentation. The generic
	 restore-origin policy would insert a redundant selected presentation at
	 the cycle boundary."
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionBehaviour >> propertyKey [
	^ CFMotionPropertyKey
		element: list
		property: self class
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> restoreOrigin [
	originIndices ifNil: [ ^ self ].
	list deselectAll.
	originIndices ifNotEmpty: [ list selectSeveral: originIndices ]
]

{ #category : 'controlling' }
CFMaDetailPopupSelectionMotionBehaviour >> reversed [
	^ self class on: list index: index
]
