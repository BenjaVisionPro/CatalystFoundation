Class {
	#name : 'CFMotionPropertyKey',
	#superclass : 'Object',
	#instVars : [ 'element', 'property' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionPropertyKey class >> element: anElement property: aProperty [
	^ self new element: anElement; property: aProperty; yourself
]

{ #category : 'comparing' }
CFMotionPropertyKey >> = another [
	^ self class = another class
		and: [ element == another element and: [ property == another property ] ]
]

{ #category : 'comparing' }
CFMotionPropertyKey >> hash [ ^ element identityHash bitXor: property identityHash ]

{ #category : 'accessing' }
CFMotionPropertyKey >> element: anElement [ element := anElement ]

{ #category : 'accessing' }
CFMotionPropertyKey >> property: aProperty [ property := aProperty ]
