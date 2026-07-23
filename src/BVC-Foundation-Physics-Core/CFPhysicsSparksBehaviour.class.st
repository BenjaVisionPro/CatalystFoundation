Class {
	#name : 'CFPhysicsSparksBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'random',
		'nextEmissionTime',
		'activeSparks',
		'minimumDelay',
		'maximumDelay',
		'sparkLifetime',
		'sparkFactory',
		'sparkParent',
		'emissionDirection',
		'emissionSpread',
		'minimumImpulse',
		'maximumImpulse',
		'minimumAngularImpulse',
		'maximumAngularImpulse'
	],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsSparksBehaviour >> initialize [
	super initialize.
	random := Random new.
	activeSparks := OrderedCollection new.
	minimumDelay := 0.05.
	maximumDelay := 0.15.
	sparkLifetime := 0.75.
	sparkFactory := [ BlElement new extent: 4 @ 4 ].
	emissionDirection := 0.0.
	emissionSpread := Float pi / 3.0.
	minimumImpulse := 40.0.
	maximumImpulse := 100.0.
	minimumAngularImpulse := -2.0.
	maximumAngularImpulse := 2.0
]

{ #category : 'accessing' }
CFPhysicsSparksBehaviour >> activeSparks [
	^ activeSparks asArray
]

{ #category : 'accessing' }
CFPhysicsSparksBehaviour >> nextEmissionTime [
	^ nextEmissionTime
]

{ #category : 'accessing' }
CFPhysicsSparksBehaviour >> random [
	^ random
]

{ #category : 'accessing' }
CFPhysicsSparksBehaviour >> random: aRandom [
	random := aRandom
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> minimumDelay [ ^ minimumDelay ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> minimumDelay: aNumber [
	minimumDelay := aNumber asFloat max: 0.0.
	maximumDelay := maximumDelay max: minimumDelay
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> maximumDelay [ ^ maximumDelay ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> maximumDelay: aNumber [
	maximumDelay := aNumber asFloat max: minimumDelay
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> sparkLifetime [ ^ sparkLifetime ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> sparkLifetime: aNumber [
	sparkLifetime := aNumber asFloat max: 0.0
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> sparkFactory [ ^ sparkFactory ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> sparkFactory: aBlock [
	sparkFactory := aBlock
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> sparkParent [
	^ sparkParent ifNil: [ element hasParent ifTrue: [ element parent ] ifFalse: [ element ] ]
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> sparkParent: anElement [
	sparkParent := anElement
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> emissionDirection [ ^ emissionDirection ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> emissionDirection: radians [
	emissionDirection := radians asFloat
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> emissionSpread [ ^ emissionSpread ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> emissionSpread: radians [
	emissionSpread := radians asFloat max: 0.0
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> minimumImpulse [ ^ minimumImpulse ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> minimumImpulse: aNumber [
	minimumImpulse := aNumber asFloat max: 0.0.
	maximumImpulse := maximumImpulse max: minimumImpulse
]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> maximumImpulse [ ^ maximumImpulse ]

{ #category : 'configuration' }
CFPhysicsSparksBehaviour >> maximumImpulse: aNumber [
	maximumImpulse := aNumber asFloat max: minimumImpulse
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

{ #category : 'updating' }
CFPhysicsSparksBehaviour >> updateForStep: aPhysicsStep [
	self removeExpiredSparksAt: aPhysicsStep simulationTime.
	self launchPendingSparks.
	nextEmissionTime ifNil: [
		^ self scheduleNextEmissionAfter: aPhysicsStep simulationTime ].
	aPhysicsStep simulationTime < nextEmissionTime ifTrue: [ ^ self ].
	self emitAt: aPhysicsStep simulationTime.
	self scheduleNextEmissionAfter: aPhysicsStep simulationTime
]

{ #category : 'private - scheduling' }
CFPhysicsSparksBehaviour >> scheduleNextEmissionAfter: simulationTime [
	nextEmissionTime := simulationTime
		+ (self randomValueBetween: minimumDelay and: maximumDelay)
]

{ #category : 'private - emission' }
CFPhysicsSparksBehaviour >> emitAt: simulationTime [
	| sparkElement spark |
	sparkElement := sparkFactory value.
	sparkElement position: physics requireBodyState position.
	self sparkParent addChild: sparkElement.
	spark := CFPhysicsSpark
		element: sparkElement
		emittedAt: simulationTime
		expiresAt: simulationTime + sparkLifetime.
	activeSparks add: spark
]

{ #category : 'private - launching' }
CFPhysicsSparksBehaviour >> launchPendingSparks [
	activeSparks do: [ :spark |
		spark isLaunched ifFalse: [ self launch: spark ] ]
]

{ #category : 'private - launching' }
CFPhysicsSparksBehaviour >> launch: aSpark [
	| body angle magnitude impulse angularImpulse |
	body := aSpark element physics requireBodyState.
	angle := emissionDirection
		+ ((random next - 0.5) * emissionSpread).
	magnitude := self randomValueBetween: minimumImpulse and: maximumImpulse.
	impulse := angle cos @ angle sin * magnitude.
	angularImpulse := self
		randomValueBetween: minimumAngularImpulse
		and: maximumAngularImpulse.
	body
		applyImpulse: impulse atWorldPoint: body centre;
		applyAngularImpulse: angularImpulse.
	aSpark beLaunched
]

{ #category : 'private - expiry' }
CFPhysicsSparksBehaviour >> removeExpiredSparksAt: simulationTime [
	activeSparks copy do: [ :spark |
		(spark isExpiredAt: simulationTime) ifTrue: [
			self removeSpark: spark ] ]
]

{ #category : 'private - removal' }
CFPhysicsSparksBehaviour >> removeSpark: aSpark [
	aSpark element hasParent ifTrue: [ aSpark element removeFromParent ].
	activeSparks remove: aSpark ifAbsent: [ ]
]

{ #category : 'removing' }
CFPhysicsSparksBehaviour >> removing [
	activeSparks copy do: [ :spark | self removeSpark: spark ]
]

{ #category : 'private - random' }
CFPhysicsSparksBehaviour >> randomValueBetween: minimum and: maximum [
	^ minimum + (random next * (maximum - minimum))
]
