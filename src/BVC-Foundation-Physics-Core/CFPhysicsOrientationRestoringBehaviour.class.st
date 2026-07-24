"
I restore the orientation of the single Physics element to which I am attached.

I capture that body's rotation when I first update and apply a damped restoring
torque before each Physics step. I know only my attached Physics body, its target
orientation, and the scalar values required to restore it. I do not select,
configure, distribute, retire, or restore any other Physics element.
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
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
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
CFPhysicsOrientationRestoringBehaviour >> updateForStep: aPhysicsStep [
	| body |
	body := physics requireBodyState.
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
