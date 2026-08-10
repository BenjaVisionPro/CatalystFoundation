"
I represent an exclusively ownable presentation property used by Motion tracks.

I define how a property reads its current presentation value and applies a new value. My identity participates in CFMotionPropertyKey so one Motion can own a given property of a given element at a time.
"
Class {
	#name : 'CFMotionProperty',
	#superclass : 'Object',
	#category : 'BVC-Motion-Core',
	#package : 'BVC-Motion-Core'
}

{ #category : 'accessing' }
CFMotionProperty >> currentPresentationOf: anElement [ self subclassResponsibility ]

{ #category : 'accessing' }
CFMotionProperty >> apply: aValue to: anElement [ self subclassResponsibility ]
