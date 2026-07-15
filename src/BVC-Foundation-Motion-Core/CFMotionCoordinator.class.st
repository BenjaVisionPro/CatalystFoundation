Class {
	#name : 'CFMotionCoordinator',
	#superclass : 'Object',
	#instVars : [ 'space', 'owners', 'activeOperations', 'history' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionCoordinator class >> on: aSpace [ ^ self new space: aSpace; yourself ]

{ #category : 'initialization' }
CFMotionCoordinator >> initialize [
	super initialize.
	owners := Dictionary new.
	activeOperations := OrderedCollection new.
	history := OrderedCollection new
]

{ #category : 'accessing' }
CFMotionCoordinator >> space: aSpace [ space := aSpace ]

{ #category : 'accessing' }
CFMotionCoordinator >> space [ ^ space ]

{ #category : 'accessing' }
CFMotionCoordinator >> history [ ^ history asArray ]

{ #category : 'accessing' }
CFMotionCoordinator >> activeOperations [ ^ activeOperations asArray ]

{ #category : 'ownership' }
CFMotionCoordinator >> ownerOf: aKey [ ^ owners at: aKey ifAbsent: [ nil ] ]

{ #category : 'ownership' }
CFMotionCoordinator >> claim: aKey for: anOperation [
	| currentOwner |
	currentOwner := self ownerOf: aKey.
	(currentOwner notNil and: [ currentOwner ~~ anOperation ])
		ifTrue: [ self error: 'A Motion property can have only one owner in a BlSpace' ].
	owners at: aKey put: anOperation.
	(activeOperations includes: anOperation) ifFalse: [
		activeOperations add: anOperation.
		history add: anOperation ]
]

{ #category : 'ownership' }
CFMotionCoordinator >> release: aKey from: anOperation [
	(owners at: aKey ifAbsent: [ nil ]) == anOperation
		ifTrue: [ owners removeKey: aKey ]
]

{ #category : 'ownership' }
CFMotionCoordinator >> releaseAllFor: anOperation [
	anOperation tracks do: [ :each |
		self release: each propertyKey from: anOperation ].
	activeOperations remove: anOperation ifAbsent: [ nil ]
]

{ #category : 'playing' }
CFMotionCoordinator >> retarget: aTrack duration: aDuration easing: anInterpolator [
	| owner operation |
	owner := self ownerOf: aTrack propertyKey.
	owner ifNotNil: [
		^ owner
			retarget: aTrack
			duration: aDuration
			easing: anInterpolator ].
	operation := CFMotionOperation coordinator: self tracks: { aTrack }.
	operation
		duration: aDuration;
		easing: anInterpolator.
	^ operation start
]
