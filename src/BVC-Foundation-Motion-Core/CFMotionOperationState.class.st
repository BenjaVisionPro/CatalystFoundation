Class {
	#name : 'CFMotionOperationState',
	#superclass : 'Object',
	#instVars : [ 'name' ],
	#classInstVars : [ 'states' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionOperationState class >> named: aSymbol [
	^ (states ifNil: [ states := Dictionary new ])
		at: aSymbol
		ifAbsentPut: [ self new name: aSymbol; yourself ]
]

{ #category : 'instance creation' }
CFMotionOperationState class >> idle [ ^ self named: #idle ]

{ #category : 'instance creation' }
CFMotionOperationState class >> running [ ^ self named: #running ]

{ #category : 'instance creation' }
CFMotionOperationState class >> completed [ ^ self named: #completed ]

{ #category : 'instance creation' }
CFMotionOperationState class >> cancelled [ ^ self named: #cancelled ]

{ #category : 'accessing' }
CFMotionOperationState >> name [ ^ name ]

{ #category : 'accessing' }
CFMotionOperationState >> name: aSymbol [ name := aSymbol ]

{ #category : 'testing' }
CFMotionOperationState >> isTerminal [
	^ self == self class completed or: [ self == self class cancelled ]
]

{ #category : 'printing' }
CFMotionOperationState >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ': '; nextPutAll: name asString
]
