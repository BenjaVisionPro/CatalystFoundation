Class {
	#name : 'CFMotionValueRecorder',
	#superclass : 'Object',
	#instVars : [ 'value' ],
	#category : 'BVC-Foundation-Motion-Tests-Values',
	#package : 'BVC-Foundation-Motion-Tests'
}

{ #category : 'initialization' }
CFMotionValueRecorder >> initialize [
	super initialize.
	value := 0.0
]

{ #category : 'accessing' }
CFMotionValueRecorder >> value [ ^ value ]

{ #category : 'accessing' }
CFMotionValueRecorder >> value: aNumber [ value := aNumber asFloat ]
