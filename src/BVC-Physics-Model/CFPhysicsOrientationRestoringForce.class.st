"
I restore one Physics body to the orientation it had when I was configured.

My responsibility is to apply a bounded damped torque each Physics step until the body returns to that orientation.
"
Class {
	#name : 'CFPhysicsOrientationRestoringForce',
	#superclass : 'CFPhysicsForce',
	#instVars : [
		'body',
		'targetRotation',
		'stiffness',
		'damping',
		'maximumAngularAcceleration',
		'angularResponseVelocityScale',
		'angleTolerance',
		'angularVelocityTolerance'
	],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsOrientationRestoringForce >> initialize [
	super initialize.
	stiffness := 36.0.
	damping := 6.0.
	maximumAngularAcceleration := 30.0.
	angularResponseVelocityScale := 4.0.
	angleTolerance := 0.002.
	angularVelocityTolerance := 0.01
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringForce >> body [
	^ body
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringForce >> body: aBody [
	world ifNotNil: [ self error: 'Remove an orientation restoring force before changing its body' ].
	body := aBody.
	targetRotation := body rotation.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringForce >> targetRotation [
	^ targetRotation
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringForce >> targetRotation: anAngle [
	targetRotation := anAngle asFloat.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringForce >> stiffness [
	^ stiffness
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringForce >> stiffness: aNumber [
	stiffness := aNumber asFloat max: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringForce >> damping [
	^ damping
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringForce >> damping: aNumber [
	damping := aNumber asFloat max: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringForce >> maximumAngularAcceleration [
	^ maximumAngularAcceleration
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringForce >> maximumAngularAcceleration: aNumber [
	maximumAngularAcceleration := aNumber asFloat max: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringForce >> angularResponseVelocityScale [
	^ angularResponseVelocityScale
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringForce >> angularResponseVelocityScale: aNumber [
	angularResponseVelocityScale := aNumber asFloat max: Float machineEpsilon.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringForce >> angleTolerance [
	^ angleTolerance
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringForce >> angleTolerance: aNumber [
	angleTolerance := aNumber asFloat max: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringForce >> angularVelocityTolerance [
	^ angularVelocityTolerance
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringForce >> angularVelocityTolerance: aNumber [
	angularVelocityTolerance := aNumber asFloat max: 0.0.
	^ self
]

{ #category : 'testing' }
CFPhysicsOrientationRestoringForce >> includesBody: aBody [
	^ body == aBody
]

{ #category : 'validation' }
CFPhysicsOrientationRestoringForce >> validateForWorld: aWorld [
	body ifNil: [ self error: 'An orientation restoring force requires a body' ].
	body world == aWorld ifFalse: [
		self error: 'Orientation restoring force body must belong to the Physics world' ]
]

{ #category : 'stepping' }
CFPhysicsOrientationRestoringForce >> applyForStep: seconds [
	| error angularAcceleration inverseInertia torque |
	body isDynamic ifFalse: [ ^ self ].
	error := self shortestAngleFrom: body rotation to: targetRotation.
	(error abs <= angleTolerance and: [
		body angularVelocity abs <= angularVelocityTolerance ]) ifTrue: [
		error isZero ifFalse: [ body rotation: targetRotation ].
		body angularVelocity isZero ifFalse: [ body angularVelocity: 0.0 ].
		^ self ].
	angularAcceleration := ((stiffness * error)
		- (damping * body angularVelocity))
		* (self responseFactorForAngularVelocity: body angularVelocity).
	angularAcceleration := (angularAcceleration max: maximumAngularAcceleration negated)
		min: maximumAngularAcceleration.
	inverseInertia := body inverseInertia.
	inverseInertia isZero ifTrue: [ ^ self ].
	torque := angularAcceleration / inverseInertia.
	body applyTorque: torque
]

{ #category : 'private - restoring' }
CFPhysicsOrientationRestoringForce >> responseFactorForAngularVelocity: anAngularVelocity [
	^ angularResponseVelocityScale
		/ (angularResponseVelocityScale + anAngularVelocity abs)
]

{ #category : 'private - geometry' }
CFPhysicsOrientationRestoringForce >> shortestAngleFrom: currentAngle to: targetAngle [
	| difference fullTurn |
	difference := targetAngle - currentAngle.
	fullTurn := Float pi * 2.0.
	[ difference > Float pi ] whileTrue: [ difference := difference - fullTurn ].
	[ difference < Float pi negated ] whileTrue: [ difference := difference + fullTurn ].
	^ difference
]
