Class {
	#name : 'CFAnimationCoordinator',
	#superclass : 'Object',
	#instVars : [
		'ownerElement',
		'entries'
	],
	#category : 'BVC-Foundation-UI-Animation',
	#package : 'BVC-Foundation-UI-Animation'
}

{ #category : 'instance creation' }
CFAnimationCoordinator class >> on: anElement [
	^ self new ownerElement: anElement; yourself
]

{ #category : 'private' }
CFAnimationCoordinator >> addAnimation: anAnimation [ ownerElement addAnimation: anAnimation ]

{ #category : 'private' }
CFAnimationCoordinator >> animationNamed: aSymbol finished: anAnimation [
	| entry |
	entry := entries at: aSymbol ifAbsent: [ ^ self ].
	entry animation == anAnimation ifFalse: [ ^ self ].
	entries removeKey: aSymbol ifAbsent: [ nil ]
]

{ #category : 'looping' }
CFAnimationCoordinator >> finishLoopNamed: aSymbol then: aBlock [
	| entry |
	entry := entries at: aSymbol ifAbsent: [ ^ aBlock ifNotNil: [ aBlock value ] ].
	entry looping ifFalse: [ self stop: aSymbol. ^ aBlock ifNotNil: [ aBlock value ] ].
	entry finishRequested: true; finishAction: aBlock
]

{ #category : 'initialization' }
CFAnimationCoordinator >> initialize [ super initialize. entries := Dictionary new ]

{ #category : 'testing' }
CFAnimationCoordinator >> isActive: aSymbol [ ^ entries includesKey: aSymbol ]

{ #category : 'looping' }
CFAnimationCoordinator >> loop: anAnimationFactoryBlock named: aSymbol [
	(entries at: aSymbol ifAbsent: [ nil ]) ifNotNil: [ :entry |
		entry looping ifTrue: [
			entry factory: anAnimationFactoryBlock; finishRequested: false; finishAction: nil.
			^ self ].
		self stop: aSymbol ].
	entries at: aSymbol put: (CFAnimationEntry new
		looping: true;
		factory: anAnimationFactoryBlock;
		finishRequested: false;
		yourself).
	self startLoopNamed: aSymbol
]

{ #category : 'looping' }
CFAnimationCoordinator >> loopNamed: aSymbol finished: anAnimation [
	| entry finishAction nextAnimation |
	entry := entries at: aSymbol ifAbsent: [ ^ self ].
	entry animation == anAnimation ifFalse: [ ^ self ].
	entry finishRequested ifTrue: [
		finishAction := entry finishAction.
		entries removeKey: aSymbol ifAbsent: [ nil ].
		^ finishAction ifNotNil: [ finishAction value ] ].
	nextAnimation := entry factory value.
	entry animation: nextAnimation.
	nextAnimation onFinishedDo: [ self loopNamed: aSymbol finished: nextAnimation ].
	self addAnimation: nextAnimation
]

{ #category : 'accessing' }
CFAnimationCoordinator >> ownerElement [ ^ ownerElement ]

{ #category : 'accessing' }
CFAnimationCoordinator >> ownerElement: anElement [ ownerElement := anElement ]

{ #category : 'playing' }
CFAnimationCoordinator >> play: anAnimation named: aSymbol [
	self stop: aSymbol.
	entries at: aSymbol put: (CFAnimationEntry new animation: anAnimation; looping: false; yourself).
	anAnimation onFinishedDo: [ self animationNamed: aSymbol finished: anAnimation ].
	self addAnimation: anAnimation
]

{ #category : 'playing' }
CFAnimationCoordinator >> replace: anAnimation named: aSymbol [ self play: anAnimation named: aSymbol ]

{ #category : 'playing' }
CFAnimationCoordinator >> retarget: anAnimationFactory named: aSymbol [
	self stop: aSymbol.
	self play: anAnimationFactory value named: aSymbol
]

{ #category : 'looping' }
CFAnimationCoordinator >> startLoopNamed: aSymbol [
	| entry animation |
	entry := entries at: aSymbol ifAbsent: [ ^ self ].
	animation := entry factory value.
	entry animation: animation.
	animation onFinishedDo: [ self loopNamed: aSymbol finished: animation ].
	self addAnimation: animation
]

{ #category : 'stopping' }
CFAnimationCoordinator >> stop: aSymbol [
	| entry |
	entry := entries removeKey: aSymbol ifAbsent: [ ^ self ].
	entry animation ifNotNil: [ :animation | animation stopIfRunning ]
]

{ #category : 'stopping' }
CFAnimationCoordinator >> stopAll [ entries keys asArray do: [ :each | self stop: each ] ]
