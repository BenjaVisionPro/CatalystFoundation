"I expose one popup option's selected state as a Motion value."

Class {
	#name : 'CFMaDetailPopupSelectionMotionValue',
	#superclass : 'CFMotionValue',
	#instVars : [ 'element' ],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'instance creation' }
CFMaDetailPopupSelectionMotionValue class >> on: anElement [
	^ self new
		element: anElement;
		value: (anElement states includes: BlElementState selected);
		yourself
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionValue >> element: anElement [
	element := anElement
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionValue >> value: aBoolean [
	super value: aBoolean.
	aBoolean
		ifTrue: [ element states addState: BlElementState selected ]
		ifFalse: [ element states removeState: BlElementState selected ].
	^ self
]
