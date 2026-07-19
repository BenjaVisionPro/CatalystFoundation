"
I represent the lifecycle state of a CFMotion.

States are canonical identity objects so Motion can compare them directly. Idle has not started, running receives coordinator frames, paused retains playback and presentation without receiving frames, settled deliberately holds destination presentation, and completed or cancelled are terminal. I contain no transition policy; CFMotion owns valid lifecycle changes.
"
Class {
	#name : 'CFMotionState',
	#superclass : 'Object',
	#instVars : [ 'name' ],
	#classInstVars : [ 'states' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionState class >> named: aSymbol [
	^ (states ifNil: [ states := Dictionary new ])
		at: aSymbol
		ifAbsentPut: [ self new name: aSymbol; yourself ]
]

{ #category : 'instance creation' }
CFMotionState class >> idle [ ^ self named: #idle ]

{ #category : 'instance creation' }
CFMotionState class >> running [ ^ self named: #running ]

{ #category : 'instance creation' }
CFMotionState class >> paused [ ^ self named: #paused ]

{ #category : 'instance creation' }
CFMotionState class >> settled [ ^ self named: #settled ]

{ #category : 'instance creation' }
CFMotionState class >> completed [ ^ self named: #completed ]

{ #category : 'instance creation' }
CFMotionState class >> cancelled [ ^ self named: #cancelled ]

{ #category : 'accessing' }
CFMotionState >> name [ ^ name ]

{ #category : 'accessing' }
CFMotionState >> name: aSymbol [ name := aSymbol ]

{ #category : 'testing' }
CFMotionState >> isTerminal [
	^ self == self class completed or: [ self == self class cancelled ]
]

{ #category : 'printing' }
CFMotionState >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ': '; nextPutAll: name asString
]
