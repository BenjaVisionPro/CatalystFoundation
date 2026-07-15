Class {
	#name : 'CFMotionProperty',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'accessing' }
CFMotionProperty >> currentPresentationOf: anElement [ self subclassResponsibility ]

{ #category : 'accessing' }
CFMotionProperty >> apply: aValue to: anElement [ self subclassResponsibility ]
