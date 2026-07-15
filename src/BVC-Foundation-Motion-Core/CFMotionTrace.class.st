Class {
	#name : 'CFMotionTrace',
	#superclass : 'Object',
	#instVars : [ 'entries' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'initialization' }
CFMotionTrace >> initialize [
	super initialize.
	entries := OrderedCollection new
]

{ #category : 'accessing' }
CFMotionTrace >> entries [ ^ entries asArray ]

{ #category : 'recording' }
CFMotionTrace >> record: aKind for: anOperation [
	self record: aKind for: anOperation track: nil
]

{ #category : 'recording' }
CFMotionTrace >> record: aKind for: anOperation track: aTrack [
	entries add: (CFMotionTraceEntry
		kind: aKind
		operation: anOperation
		track: aTrack)
]
