"
I restore the initial orientation of my attached Physics body.

My responsibility is to apply a bounded damped torque before each step until the body returns to that orientation.
"
Class {
	#name : 'CFPhysicsOrientationRestoringBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'targetRotation',
		'stiffness',
		'damping',
		'maximumAngularAcceleration',
		'angularResponseVelocityScale',
		'angleTolerance',
		'angularVelocityTolerance'
	],
	#category : 'BVC-Physics-Behaviours',
	#package : 'BVC-Physics-Behaviours'
}

{ #category : 'initialization' }
CFPhysicsOrientationRestoringBehaviour >> initialize [
	super initialize.
	stiffness := CFPhysicsSharedScalar value: 36.0.
	damping := CFPhysicsSharedScalar value: 6.0.
	maximumAngularAcceleration := CFPhysicsSharedScalar value: 30.0.
	angularResponseVelocityScale := CFPhysicsSharedScalar value: 4.0.
	angleTolerance := CFPhysicsSharedScalar value: 0.002.
	angularVelocityTolerance := CFPhysicsSharedScalar value: 0.01
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> stiffness: aNumberOrSharedScalar [
	stiffness := self scalarFrom: aNumberOrSharedScalar minimum: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> stiffness [ ^ stiffness ]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> damping: aNumberOrSharedScalar [
	damping := self scalarFrom: aNumberOrSharedScalar minimum: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> damping [ ^ damping ]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> maximumAngularAcceleration: aNumberOrSharedScalar [
	maximumAngularAcceleration := self scalarFrom: aNumberOrSharedScalar minimum: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> maximumAngularAcceleration [ ^ maximumAngularAcceleration ]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> angularResponseVelocityScale: aNumberOrSharedScalar [
	angularResponseVelocityScale := self scalarFrom: aNumberOrSharedScalar minimum: Float machineEpsilon.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> angularResponseVelocityScale [ ^ angularResponseVelocityScale ]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> angleTolerance: aNumberOrSharedScalar [
	angleTolerance := self scalarFrom: aNumberOrSharedScalar minimum: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> angleTolerance [ ^ angleTolerance ]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> angularVelocityTolerance: aNumberOrSharedScalar [
	angularVelocityTolerance := self scalarFrom: aNumberOrSharedScalar minimum: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> angularVelocityTolerance [ ^ angularVelocityTolerance ]

{ #category : 'updating' }
CFPhysicsOrientationRestoringBehaviour >> step: aPhysicsStep [
	| body |
	body := target physics body.
	targetRotation ifNil: [ targetRotation := body rotation ].
	self restoreBody: body
]

{ #category : 'private - restoring' }
CFPhysicsOrientationRestoringBehaviour >> restoreBody: body [
	| error angularAcceleration inverseInertia torque |
	body isDynamic ifFalse: [ ^ self ].
	error := self shortestAngleFrom: body rotation to: targetRotation.
	(error abs <= angleTolerance value and: [
		body angularVelocity abs <= angularVelocityTolerance value ]) ifTrue: [
		error isZero ifFalse: [ body rotation: targetRotation ].
		body angularVelocity isZero ifFalse: [ body angularVelocity: 0.0 ].
		^ self ].
	angularAcceleration := ((stiffness value * error)
		- (damping value * body angularVelocity))
		* (self responseFactorForAngularVelocity: body angularVelocity).
	angularAcceleration := (angularAcceleration max: maximumAngularAcceleration value negated)
		min: maximumAngularAcceleration value.
	inverseInertia := body inverseInertia.
	inverseInertia isZero ifTrue: [ ^ self ].
	torque := angularAcceleration / inverseInertia.
	body applyTorque: torque
]

{ #category : 'private - restoring' }
CFPhysicsOrientationRestoringBehaviour >> responseFactorForAngularVelocity: anAngularVelocity [
	^ angularResponseVelocityScale value
		/ (angularResponseVelocityScale value + anAngularVelocity abs)
]

{ #category : 'private - geometry' }
CFPhysicsOrientationRestoringBehaviour >> shortestAngleFrom: currentAngle to: targetAngle [
	| difference fullTurn |
	difference := targetAngle - currentAngle.
	fullTurn := Float pi * 2.0.
	[ difference > Float pi ] whileTrue: [ difference := difference - fullTurn ].
	[ difference < Float pi negated ] whileTrue: [ difference := difference + fullTurn ].
	^ difference
]

{ #category : 'private - configuration' }
CFPhysicsOrientationRestoringBehaviour >> scalarFrom: aNumberOrSharedScalar minimum: aMinimum [
	(aNumberOrSharedScalar isKindOf: CFPhysicsSharedScalar) ifTrue: [
		^ aNumberOrSharedScalar ].
	^ CFPhysicsSharedScalar value: (aNumberOrSharedScalar asFloat max: aMinimum)
]
