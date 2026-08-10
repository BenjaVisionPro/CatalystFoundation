"
I present the bodies of one Physics world through Motion transform channels.

My responsibility is to maintain per-body presentations, interpolate committed transforms for a frame, suppress unchanged presentation work, announce meaningful diagnostic changes, and release presentation resources when bodies or coordinators change.
"
Class {
	#name : 'CFPhysicsWorldPresentation',
	#superclass : 'Object',
	#instVars : [ 'world', 'coordinator', 'presentations', 'fixedCoordinator', 'bodyStates', 'membershipRevision', 'lastPresentationChanged', 'lastContactVisualRevision', 'lastBehaviourRevision' ],
	#category : 'BVC-Physics-Motion',
	#package : 'BVC-Physics-Motion'
}

{ #category : 'instance creation' }
CFPhysicsWorldPresentation class >> on: aWorld [
	^ self new
		world: aWorld;
		yourself
]

{ #category : 'instance creation' }
CFPhysicsWorldPresentation class >> on: aWorld in: aCoordinator [
	^ self new
		world: aWorld;
		coordinator: aCoordinator;
		useFixedCoordinator;
		yourself
]

{ #category : 'initialization' }
CFPhysicsWorldPresentation >> initialize [
	super initialize.
	presentations := IdentityDictionary new.
	bodyStates := #().
	membershipRevision := -1.
	lastPresentationChanged := false.
	lastContactVisualRevision := -1.
	lastBehaviourRevision := -1.
	fixedCoordinator := false
]


{ #category : 'consuming frames' }
CFPhysicsWorldPresentation >> frameReadyAtAlpha: aNumber [
	| didPresent contactStateChanged behaviourChanged |
	didPresent := world telemetryEnabled
		ifTrue: [ self tryPresentAtAlphaWithTelemetry: aNumber ]
		ifFalse: [ self tryPresentAtAlpha: aNumber ].
	didPresent ifFalse: [ ^ self ].
	contactStateChanged := lastContactVisualRevision ~= world contactVisualRevision.
	behaviourChanged := lastBehaviourRevision ~= world behaviourRevision.
	(lastPresentationChanged or: [ contactStateChanged or: [ behaviourChanged ] ])
		ifFalse: [ ^ self ].
	lastContactVisualRevision := world contactVisualRevision.
	lastBehaviourRevision := world behaviourRevision.
	world owner ifNotNil: [ :anOwner |
		anOwner fireEvent: (CFPhysicsFramePresentedEvent
			presentationChanged: lastPresentationChanged
			contactStateChanged: contactStateChanged
			behaviourChanged: behaviourChanged) ].
	^ self
]

{ #category : 'presenting' }
CFPhysicsWorldPresentation >> present [
	world telemetryEnabled ifFalse: [ ^ self presentWithoutTelemetry ].
	^ ProcessTelemetry
		rootTimeSync: [ 'Physics presentation' ]
		during: [
			ProcessTelemetry
				profile: [ self presentWithoutTelemetry ]
				executing: [ :run |
					run value.
					self telemetryDataAtAlpha: 1.0 ]
				as: #physicsPresentation ]
]

{ #category : 'private - presenting' }
CFPhysicsWorldPresentation >> presentWithoutTelemetry [
	self prepare ifFalse: [ ^ self ].
	self synchronisePresentations.
	bodyStates do: [ :each |
		(self presentationFor: each)
			translation: (self translationFor: each at: each position)
			rotation: each rotation radiansToDegrees ]
]

{ #category : 'presenting' }
CFPhysicsWorldPresentation >> presentAtAlpha: aNumber [
	world telemetryEnabled
		ifTrue: [ self tryPresentAtAlphaWithTelemetry: aNumber ]
		ifFalse: [ self tryPresentAtAlpha: aNumber ].
	^ self
]

{ #category : 'private - telemetry' }
CFPhysicsWorldPresentation >> tryPresentAtAlphaWithTelemetry: aNumber [
	^ ProcessTelemetry
		rootTimeSync: [ 'Physics presentation' ]
		during: [
			ProcessTelemetry
				profile: [ self tryPresentAtAlpha: aNumber ]
				executing: [ :run |
					run value.
					self telemetryDataAtAlpha: aNumber ]
				as: #physicsPresentation ]
]

{ #category : 'private - telemetry' }
CFPhysicsWorldPresentation >> telemetryDataAtAlpha: aNumber [
	^ Dictionary new
		at: #physicsWorld put: world;
		at: #kind put: #presentation;
		at: #stepNumber put: world stepNumber;
		at: #bodyCount put: bodyStates size;
		at: #alpha put: aNumber;
		yourself
]

{ #category : 'private - presenting' }
CFPhysicsWorldPresentation >> tryPresentAtAlpha: aNumber [
	| alpha |
	self prepare ifFalse: [
		lastPresentationChanged := false.
		^ false ].
	self synchronisePresentations.
	lastPresentationChanged := false.
	alpha := (aNumber max: 0.0) min: 1.0.
	bodyStates do: [ :each |
		| presentedPosition presentedRotation translation rotation presentation changed |
		presentedPosition := each previousPosition + ((each position - each previousPosition) * alpha).
		presentedRotation := each previousRotation + ((each rotation - each previousRotation) * alpha).
		translation := self translationFor: each at: presentedPosition.
		rotation := presentedRotation radiansToDegrees.
		presentation := self presentationFor: each.
		changed := presentation isActive not
			or: [ presentation translation ~= translation
			or: [ presentation rotation ~= rotation
			or: [ presentation ownsCurrentTransformation not ] ] ].
		presentation translation: translation rotation: rotation.
		(changed and: [ presentation ownsCurrentTransformation ]) ifTrue: [
			lastPresentationChanged := true ] ].
	^ true
]

{ #category : 'private - presenting' }
CFPhysicsWorldPresentation >> translationFor: aBodyState at: aPhysicsPosition [
	"Physics positions are absolute in the world owner's local coordinates, while
	Motion translation is applied on top of the element's existing Bloc position.
	Translate only by the difference so the displayed top-left remains equal to
	the Physics position."
	^ aPhysicsPosition - aBodyState element position
]

{ #category : 'private - presenting' }
CFPhysicsWorldPresentation >> prepare [
	| currentCoordinator |
	fixedCoordinator ifTrue: [ ^ coordinator notNil ].
	currentCoordinator := self resolvedCoordinator.
	currentCoordinator ifNil: [
		self releasePresentations.
		coordinator := nil.
		^ false ].
	coordinator == currentCoordinator ifFalse: [
		self releasePresentations.
		coordinator := currentCoordinator ].
	^ true
]

{ #category : 'private - presenting' }
CFPhysicsWorldPresentation >> resolvedCoordinator [
	| owner |
	owner := world owner.
	(owner notNil and: [ owner isAttachedToSceneGraph ]) ifFalse: [ ^ nil ].
	^ owner space motionCoordinator
]

{ #category : 'private - presenting' }
CFPhysicsWorldPresentation >> synchronisePresentations [
	| currentBodies transformPresentation |
	membershipRevision = world membershipRevision ifTrue: [ ^ self ].
	bodyStates := world bodyStatesInOrder.
	currentBodies := IdentitySet new.
	currentBodies addAll: bodyStates.
	(presentations keys reject: [ :each | currentBodies includes: each ]) do: [ :each |
		(presentations removeKey: each) release ].
	bodyStates do: [ :each |
		transformPresentation := presentations at: each ifAbsent: [ nil ].
		(transformPresentation isNil or: [ transformPresentation isActive not ]) ifTrue: [
			transformPresentation ifNotNil: [ transformPresentation release ].
			transformPresentation := CFMotionTransformPresentation
				on: each element
				using: (coordinator transformChannelFor: each element).
			presentations at: each put: transformPresentation ] ].
	membershipRevision := world membershipRevision
]


{ #category : 'accessing' }
CFPhysicsWorldPresentation >> presentationFor: aBodyState [
	^ presentations at: aBodyState
]

{ #category : 'testing' }
CFPhysicsWorldPresentation >> isPresenting: aBodyState [
	| aPresentation |
	aPresentation := presentations at: aBodyState ifAbsent: [ ^ false ].
	^ aPresentation isActive
]

{ #category : 'controlling' }
CFPhysicsWorldPresentation >> release [
	self releasePresentations.
	fixedCoordinator ifFalse: [ coordinator := nil ]
]

{ #category : 'private - controlling' }
CFPhysicsWorldPresentation >> releasePresentations [
	presentations valuesDo: [ :each | each release ].
	presentations removeAll.
	bodyStates := #().
	membershipRevision := -1.
	lastPresentationChanged := false
]

{ #category : 'private - initialization' }
CFPhysicsWorldPresentation >> world: aWorld [
	world := aWorld.
	lastContactVisualRevision := aWorld contactVisualRevision.
	lastBehaviourRevision := aWorld behaviourRevision
]

{ #category : 'private - initialization' }
CFPhysicsWorldPresentation >> coordinator: aCoordinator [
	coordinator := aCoordinator
]

{ #category : 'private - initialization' }
CFPhysicsWorldPresentation >> useFixedCoordinator [
	fixedCoordinator := true
]
