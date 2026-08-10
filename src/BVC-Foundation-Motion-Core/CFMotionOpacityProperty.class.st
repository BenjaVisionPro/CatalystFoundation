"
I represent the exclusive Motion property for a Bloc element's opacity.

I read and apply opacity presentation values and provide stable property identity for Motion ownership and retargeting.
"
Class {
	#name : 'CFMotionOpacityProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionOpacityProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFMotionOpacityProperty >> currentPresentationOf: anElement [ ^ anElement opacity ]

{ #category : 'accessing' }
CFMotionOpacityProperty >> apply: aNumber to: anElement [ anElement opacity: aNumber ]
