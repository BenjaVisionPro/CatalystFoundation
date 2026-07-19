"
I coordinate Motion presentation within one BlSpace.

There is one CFMotionCoordinator per BlSpace. I own the ordered collection of active Motions, the single CFMotionFrameDriver that advances them, property ownership, transform composition channels and execution history. Every active Motion receives the same CFMotionFrame in stable registration order during Bloc's task phase.

I decide neither what a Motion contains nor how its timeline interprets time. A CFMotion owns its temporal composition and lifecycle. Bloc owns pulse scheduling and rendering. I connect those responsibilities without introducing another timer or scheduler.
"
Class {
	#name : 'CFMotionCoordinator',
	#superclass : 'Object',
	#instVars : [ 'space', 'owners', 'activeMotions', 'history', 'transformChannels', 'frameDriver' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionCoordinator class >> on: aSpace [ ^ self new space: aSpace; yourself ]

{ #category : 'accessing' }
CFMotionCoordinator >> activeMotions [
	^ activeMotions asArray
]

{ #category : 'playing' }
CFMotionCoordinator >> advanceWith: aFrame [
	activeMotions asArray do: [ :each | each advanceWith: aFrame ]
]

{ #category : 'ownership' }
CFMotionCoordinator >> claim: aKey for: anOperation [
	| currentOwner |
	currentOwner := self ownerOf: aKey.
	(currentOwner notNil and: [ currentOwner ~~ anOperation ])
		ifTrue: [ self error: 'A Motion property can have only one owner in a BlSpace' ].
	owners at: aKey put: anOperation
]

{ #category : 'accessing' }
CFMotionCoordinator >> frameDriver [
	^ frameDriver
]

{ #category : 'testing' }
CFMotionCoordinator >> hasActiveMotions [
	^ activeMotions isNotEmpty
]

{ #category : 'accessing' }
CFMotionCoordinator >> history [ ^ history asArray ]

{ #category : 'initialization' }
CFMotionCoordinator >> initialize [
	super initialize.
	owners := Dictionary new.
	activeMotions := OrderedCollection new.
	history := OrderedCollection new.
	transformChannels := IdentityDictionary new
]

{ #category : 'ownership' }
CFMotionCoordinator >> ownerOf: aKey [ ^ owners at: aKey ifAbsent: [ nil ] ]

{ #category : 'playing' }
CFMotionCoordinator >> play: aMotion [
	(activeMotions includes: aMotion) ifFalse: [
		activeMotions add: aMotion ].
	(history includes: aMotion) ifFalse: [ history add: aMotion ].
	frameDriver activate.
	^ aMotion
]

{ #category : 'ownership' }
CFMotionCoordinator >> release: aKey from: anOperation [
	(owners at: aKey ifAbsent: [ nil ]) == anOperation
		ifTrue: [ owners removeKey: aKey ]
]

{ #category : 'ownership' }
CFMotionCoordinator >> releaseAllFor: anOperation [
	anOperation tracks do: [ :each |
		self release: each propertyKey from: anOperation ]
]

{ #category : 'playing' }
CFMotionCoordinator >> removeActiveMotion: aMotion [
	activeMotions remove: aMotion ifAbsent: [ nil ].
	activeMotions ifEmpty: [ frameDriver deactivate ].
	^ aMotion
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
	| owner motion |
	owner := self ownerOf: aTrack propertyKey.
	owner ifNotNil: [
		^ owner
			retarget: aTrack
			duration: aDuration
			easing: anInterpolator ].
	motion := CFMotion coordinator: self tracks: { aTrack }.
	motion
		duration: aDuration;
		easing: anInterpolator.
	^ motion start
]

{ #category : 'accessing' }
CFMotionCoordinator >> space [ ^ space ]

{ #category : 'accessing' }
CFMotionCoordinator >> space: aSpace [
	space := aSpace.
	frameDriver := CFMotionFrameDriver coordinator: self
]

{ #category : 'transform channels' }
CFMotionCoordinator >> transformChannelFor: anElement [
	^ transformChannels at: anElement ifAbsentPut: [
		| channel |
		channel := CFMotionTransformChannel on: anElement.
		channel whenEmptyDo: [
			transformChannels removeKey: anElement ifAbsent: [ nil ] ].
		channel ]
]
