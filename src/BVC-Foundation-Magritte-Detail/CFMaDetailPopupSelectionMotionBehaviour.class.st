"I present one off/on popup-selection blink cycle.

One timeline track evaluates this Behaviour for one complete blink cycle:
the first half is unselected and the second half is selected. Repetition
belongs to CFMotionTimeline; this Behaviour owns only the selected-state
presentation for one cycle."
Class {
	#name : 'CFMaDetailPopupSelectionMotionBehaviour',
	#superclass : 'CFMotionBehaviour',
	#instVars : [
		'element',
		'originSelected'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'instance creation' }
CFMaDetailPopupSelectionMotionBehaviour class >> on: anElement [
	^ self new
		element: anElement;
		yourself
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionBehaviour >> animationTarget [
	^ element
]

{ #category : 'private - presentation' }
CFMaDetailPopupSelectionMotionBehaviour >> applySelected: aBoolean [
	aBoolean
		ifTrue: [ element states addState: BlElementState selected ]
		ifFalse: [ element states removeState: BlElementState selected ]
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> applyDestination [
	self applySelected: true
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> applyProgress: aProgress [
	self applySelected: aProgress >= 0.5
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> captureOrigin [
	originSelected ifNil: [
		originSelected := element states hasState: BlElementState selected ]
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionBehaviour >> element: anElement [
	element := anElement
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionBehaviour >> propertyKey [
	^ CFMotionPropertyKey
		element: element
		property: self class
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> restoreOrigin [
	originSelected ifNil: [ ^ self ].
	self applySelected: originSelected
]

{ #category : 'controlling' }
CFMaDetailPopupSelectionMotionBehaviour >> reversed [
	^ self class on: element
]
