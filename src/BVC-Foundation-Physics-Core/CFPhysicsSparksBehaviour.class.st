"
I emit short-lived Physics elements from one source element.

Intensity is my public semantic control. I translate it into emission delay, launch speed, spread, lifetime and angular impulse. An injected random source makes emission deterministic in tests and reproducible when supplied with a deterministic generator.

Emission and expiry are discrete Physics events. Every emitted spark is an ordinary element and body owned by me for its lifetime. I do not use Motion to schedule object creation, and removing me removes only the sparks I emitted.
"
Class {
	#name : 'CFPhysicsSparksBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'random',
		'nextEmissionTime',
		'liveSparks',
		'intensity',
		'direction',
		'spread',
		'minimumEmissionDelay',
		'maximumEmissionDelay',
		'minimumLaunchImpulse',
		'maximumLaunchImpulse',
		'minimumAngularImpulse',
		'maximumAngularImpulse',
		'lifetime',
		'sparkFactory'
	],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsSparksBehaviour >> initialize [
	super initialize.
	random := Random new.
	liveSparks := IdentityDictionary new.
	direction := 0 @ -1.
	sparkFactory := [ BlElement new extent: 4 @ 4; yourself ].
	self intensity: 0.25
]

{ #category : 'accessing' }
CFPhysicsSparksBehaviour >> random [ ^ random ]

{ #category : 'accessing' }
CFPhysicsSparksBehaviour >> random: aRandom [ random := aRandom ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> intensity [ ^ intensity ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> intensity: aNumber [
	intensity := (aNumber asFloat min: 1.0) max: 0.0.
	minimumEmissionDelay := 0.18 - (0.14 * intensity).
	maximumEmissionDelay := 0.32 - (0.24 * intensity).
	minimumLaunchImpulse := 18.0 + (42.0 * intensity).
	maximumLaunchImpulse := 35.0 + (95.0 * intensity).
	minimumAngularImpulse := 0.0 - (0.5 + (2.5 * intensity)).
	maximumAngularImpulse := 0.5 + (2.5 * intensity).
	spread := 0.12 + (0.55 * intensity).
	lifetime := 0.35 + (0.45 * intensity)
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> direction [ ^ direction ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> direction: aPoint [
	direction := self normalized: aPoint ifZero: 0 @ -1
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> spread [ ^ spread ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> spread: aNumber [ spread := aNumber asFloat max: 0.0 ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> minimumEmissionDelay [ ^ minimumEmissionDelay ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> minimumEmissionDelay: aNumber [
	minimumEmissionDelay := aNumber max: 0.
	maximumEmissionDelay := maximumEmissionDelay max: minimumEmissionDelay
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> maximumEmissionDelay [ ^ maximumEmissionDelay ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> maximumEmissionDelay: aNumber [
	maximumEmissionDelay := aNumber max: minimumEmissionDelay
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> minimumLaunchImpulse [ ^ minimumLaunchImpulse ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> minimumLaunchImpulse: aNumber [
	minimumLaunchImpulse := aNumber asFloat max: 0.0.
	maximumLaunchImpulse := maximumLaunchImpulse max: minimumLaunchImpulse
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> maximumLaunchImpulse [ ^ maximumLaunchImpulse ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> maximumLaunchImpulse: aNumber [
	maximumLaunchImpulse := aNumber asFloat max: minimumLaunchImpulse
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> minimumAngularImpulse [ ^ minimumAngularImpulse ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> minimumAngularImpulse: aNumber [
	minimumAngularImpulse := aNumber asFloat.
	maximumAngularImpulse := maximumAngularImpulse max: minimumAngularImpulse
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> maximumAngularImpulse [ ^ maximumAngularImpulse ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> maximumAngularImpulse: aNumber [
	maximumAngularImpulse := aNumber asFloat max: minimumAngularImpulse
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> lifetime [ ^ lifetime ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> lifetime: aNumberOrDuration [ lifetime := aNumberOrDuration max: 0 ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> sparkFactory [ ^ sparkFactory ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> sparkFactory: aBlock [ sparkFactory := aBlock ]

{ #category : 'accessing' }
CFPhysicsSparksBehaviour >> nextEmissionTime [ ^ nextEmissionTime ]

{ #category : 'accessing' }
CFPhysicsSparksBehaviour >> liveSparks [ ^ liveSparks keys asArray ]

{ #category : 'accessing' }
CFPhysicsSparksBehaviour >> numberOfLiveSparks [ ^ liveSparks size ]

{ #category : 'updating' }
CFPhysicsSparksBehaviour >> updateForStep: aPhysicsStep [
	self removeExpiredSparksAt: aPhysicsStep simulationTime.
	nextEmissionTime ifNil: [
		^ self scheduleNextEmissionAfter: aPhysicsStep simulationTime ].
	aPhysicsStep simulationTime < nextEmissionTime ifTrue: [ ^ self ].
	self emitSparkExpiringAfter: aPhysicsStep simulationTime.
	self scheduleNextEmissionAfter: aPhysicsStep simulationTime
]

{ #category : 'private - scheduling' }
CFPhysicsSparksBehaviour >> scheduleNextEmissionAfter: simulationTime [
	nextEmissionTime := simulationTime +
		(self randomValueBetween: minimumEmissionDelay and: maximumEmissionDelay)
]

{ #category : 'private - emission' }
CFPhysicsSparksBehaviour >> emitSparkExpiringAfter: simulationTime [
	| spark container sourceBody sparkBody launchDirection magnitude impulse angularImpulse |
	spark := sparkFactory value.
	container := element parent ifNil: [ world owner ].
	container addChild: spark.
	world synchroniseMembership.
	sourceBody := element physics requireBodyState.
	sparkBody := spark physics requireBodyState.
	sparkBody position: sourceBody centre - (sparkBody extent / 2.0).
	launchDirection := self randomLaunchDirection.
	magnitude := self randomValueBetween: minimumLaunchImpulse and: maximumLaunchImpulse.
	impulse := launchDirection * magnitude.
	angularImpulse := self
		randomValueBetween: minimumAngularImpulse
		and: maximumAngularImpulse.
	sparkBody
		applyImpulse: impulse atWorldPoint: sparkBody centre;
		applyAngularImpulse: angularImpulse.
	liveSparks at: spark put: simulationTime + lifetime.
	^ spark
]

{ #category : 'private - emission' }
CFPhysicsSparksBehaviour >> randomLaunchDirection [
	| perpendicular offset |
	perpendicular := direction y negated @ direction x.
	offset := ((random next * 2.0) - 1.0) * spread.
	^ self normalized: direction + (perpendicular * offset) ifZero: direction
]

{ #category : 'private - expiry' }
CFPhysicsSparksBehaviour >> removeExpiredSparksAt: simulationTime [
	| expired |
	expired := liveSparks keys select: [ :each |
		simulationTime >= (liveSparks at: each) ].
	expired do: [ :each | self removeOwnedSpark: each ]
]

{ #category : 'private - expiry' }
CFPhysicsSparksBehaviour >> removeOwnedSpark: anElement [
	liveSparks removeKey: anElement ifAbsent: [ ^ self ].
	anElement hasParent ifTrue: [ anElement removeFromParent ]
]

{ #category : 'private - geometry' }
CFPhysicsSparksBehaviour >> normalized: aPoint ifZero: fallbackPoint [
	| length |
	length := ((aPoint x * aPoint x) + (aPoint y * aPoint y)) sqrt.
	(length closeTo: 0.0) ifTrue: [ ^ fallbackPoint ].
	^ aPoint / length
]

{ #category : 'private - random' }
CFPhysicsSparksBehaviour >> randomValueBetween: minimum and: maximum [
	^ minimum + (random next * (maximum - minimum))
]

{ #category : 'removing' }
CFPhysicsSparksBehaviour >> removing [
	liveSparks keys copy do: [ :each | self removeOwnedSpark: each ].
	nextEmissionTime := nil
]
