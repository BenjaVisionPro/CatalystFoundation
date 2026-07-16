Class {
	#name : 'CFMotionCoordinator',
	#superclass : 'Object',
	#instVars : [ 'space', 'owners', 'activeOperations', 'history', 'transformChannels' ],
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
	history := OrderedCollection new.
	transformChannels := IdentityDictionary new
]

{ #category : 'accessing' }
CFMotionCoordinator >> space: aSpace [ space := aSpace ]

{ #category : 'accessing' }
CFMotionCoordinator >> space [ ^ space ]

{ #category : 'transform channels' }
CFMotionCoordinator >> transformChannelFor: anElement [
	^ transformChannels at: anElement ifAbsentPut: [
		| channel |
		channel := CFMotionTransformChannel on: anElement.
		channel whenEmptyDo: [
			transformChannels removeKey: anElement ifAbsent: [ nil ] ].
		channel ]
]

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

{ #category : 'ownership' }
CFMotionCoordinator >> replaceGeometryOwnersFor: geometryTracks [
	^ self replaceGeometryOwnersForKeys: (geometryTracks collect: #propertyKey)
]

{ #category : 'ownership' }
CFMotionCoordinator >> replaceGeometryOwnersForKeys: propertyKeys [
	| ownersToReplace |
	ownersToReplace := OrderedCollection new.
	propertyKeys do: [ :eachKey |
		| owner |
		owner := self ownerOf: eachKey.
		(owner notNil and: [ (ownersToReplace includes: owner) not ]) ifTrue: [
			ownersToReplace add: owner ] ].
	ownersToReplace do: [ :eachOwner |
		(eachOwner tracks allSatisfy: [ :eachTrack |
			eachTrack isKindOf: CFMotionGeometryTrack ]) ifFalse: [
			self error: 'Geometry retargeting cannot replace a mixed Motion operation' ] ].
	ownersToReplace do: [ :eachOwner |
		eachOwner cancelSettlingAtEnd ]
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
	operation := CFMotion coordinator: self tracks: { aTrack }.
	operation
		duration: aDuration;
		easing: anInterpolator.
	^ operation start
]
