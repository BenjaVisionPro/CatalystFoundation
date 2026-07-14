Class {
	#name : 'CFMotionSnapshot',
	#superclass : 'Object',
	#instVars : [ 'element', 'bounds' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionSnapshot class >> element: anElement bounds: aRectangle [
	^ self new element: anElement; bounds: aRectangle; yourself
]

{ #category : 'accessing' }
CFMotionSnapshot >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionSnapshot >> element: anElement [ element := anElement ]

{ #category : 'accessing' }
CFMotionSnapshot >> bounds [ ^ bounds ]

{ #category : 'accessing' }
CFMotionSnapshot >> bounds: aRectangle [ bounds := aRectangle ]
