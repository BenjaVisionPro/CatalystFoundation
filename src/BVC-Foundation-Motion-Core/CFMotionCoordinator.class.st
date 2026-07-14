Class {
	#name : 'CFMotionCoordinator',
	#superclass : 'Object',
	#instVars : [ 'space', 'owners', 'history' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionCoordinator class >> on: aSpace [ ^ self new space: aSpace; yourself ]

{ #category : 'initialization' }
CFMotionCoordinator >> initialize [
	super initialize.
	owners := Dictionary new.
	history := OrderedCollection new
]

{ #category : 'accessing' }
CFMotionCoordinator >> space: aSpace [ space := aSpace ]

{ #category : 'accessing' }
CFMotionCoordinator >> space [ ^ space ]

{ #category : 'accessing' }
CFMotionCoordinator >> history [ ^ history asArray ]

{ #category : 'ownership' }
CFMotionCoordinator >> ownerOf: aKey [ ^ owners at: aKey ifAbsent: [ nil ] ]

{ #category : 'ownership' }
CFMotionCoordinator >> claim: aKey for: anOperation [
	owners at: aKey put: anOperation.
	history add: anOperation
]

{ #category : 'ownership' }
CFMotionCoordinator >> release: aKey from: anOperation [
	(owners at: aKey ifAbsent: [ nil ]) == anOperation
		ifTrue: [ owners removeKey: aKey ]
]
