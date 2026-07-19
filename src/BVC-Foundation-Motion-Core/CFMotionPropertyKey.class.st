"
I identify one independently owned presentation property on one element.

My element and property are compared by identity so every coordinator reaches the same ownership decision for the same presentation surface. I carry no mutable ownership state; CFMotionCoordinator maps me to the Motion that currently owns that surface.
"
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
CFMotionPropertyKey >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionPropertyKey >> element: anElement [ element := anElement ]

{ #category : 'accessing' }
CFMotionPropertyKey >> property [ ^ property ]

{ #category : 'accessing' }
CFMotionPropertyKey >> property: aProperty [ property := aProperty ]
