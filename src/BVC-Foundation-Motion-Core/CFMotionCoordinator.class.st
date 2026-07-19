"
I coordinate all Motion playback within one BlSpace.

I own the single CFMotionFrameDriver, the stable registration order of active Motions, presentation-property ownership, transform composition channels and playback history. Each Bloc frame produces one immutable CFMotionFrame which I deliver to every active Motion in registration order.

I never interpret a timeline or perform presentation work. Bloc owns pulse scheduling, CFMotion owns playback lifecycle, CFMotionTimeline owns playback position, and CFMotionBehaviour owns evaluated work.
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
CFMotionCoordinator >> claim: aKey for: aMotion [
	| currentOwner |
	currentOwner := self ownerOf: aKey.
	(currentOwner notNil and: [ currentOwner ~~ aMotion ])
		ifTrue: [ self error: 'A Motion property can have only one owner in a BlSpace' ].
	owners at: aKey put: aMotion
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
CFMotionCoordinator >> release: aKey from: aMotion [
	(owners at: aKey ifAbsent: [ nil ]) == aMotion
		ifTrue: [ owners removeKey: aKey ]
]

{ #category : 'ownership' }
CFMotionCoordinator >> releaseAllFor: aMotion [
	aMotion tracks do: [ :each |
		each propertyKey ifNotNil: [ :aKey |
			self release: aKey from: aMotion ] ]
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
			self error: 'Geometry retargeting cannot replace a mixed Motion motion' ] ].
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
