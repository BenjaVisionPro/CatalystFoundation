"
I keep selected ordinary Physics bodies near the orientation they had when they
first joined me.

I apply a damped angular controller before each Physics step. My optional density
and angular-damping profile makes selected bodies feel heavier without leaking
that policy after I am removed: original per-body values are restored for retired
participants and during teardown.
"
Class {
	#name : 'CFPhysicsOrientationRestoringBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'nodes',
		'targetRotations',
		'originalDensityByNode',
		'originalAngularDampingByNode',
		'density',
		'angularDamping',
		'stiffness',
		'damping',
		'maximumAngularAcceleration',
		'angleTolerance',
		'angularVelocityTolerance'
	],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsOrientationRestoringBehaviour >> initialize [
	super initialize.
	targetRotations := IdentityDictionary new.
	originalDensityByNode := IdentityDictionary new.
	originalAngularDampingByNode := IdentityDictionary new.
	density := nil.
	angularDamping := nil.
	stiffness := 36.0.
	damping := 6.0.
	maximumAngularAcceleration := 30.0.
	angleTolerance := 0.002.
	angularVelocityTolerance := 0.01
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> nodes: aCollectionOrProvider [
	nodes := aCollectionOrProvider.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> nodes [
	^ self resolvedParticipantsFrom: nodes default: [ world members ]
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> density: aNumber [
	density := aNumber ifNil: [ nil ] ifNotNil: [ aNumber asFloat max: 0.0 ].
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> density [
	^ density
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> angularDamping: aNumber [
	angularDamping := aNumber ifNil: [ nil ] ifNotNil: [ aNumber asFloat max: 0.0 ].
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> angularDamping [
	^ angularDamping
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> stiffness: aNumber [
	stiffness := aNumber asFloat max: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> stiffness [
	^ stiffness
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> damping: aNumber [
	damping := aNumber asFloat max: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> damping [
	^ damping
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> maximumAngularAcceleration: aNumber [
	maximumAngularAcceleration := aNumber asFloat max: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> maximumAngularAcceleration [
	^ maximumAngularAcceleration
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> angleTolerance: aNumber [
	angleTolerance := aNumber asFloat max: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> angleTolerance [
	^ angleTolerance
]

{ #category : 'configuration' }
CFPhysicsOrientationRestoringBehaviour >> angularVelocityTolerance: aNumber [
	angularVelocityTolerance := aNumber asFloat max: 0.0.
	^ self
]

{ #category : 'accessing' }
CFPhysicsOrientationRestoringBehaviour >> angularVelocityTolerance [
	^ angularVelocityTolerance
]

{ #category : 'updating' }
CFPhysicsOrientationRestoringBehaviour >> updateForStep: aPhysicsStep [
	| currentNodes currentSet |
	currentNodes := self nodes.
	self validateNodes: currentNodes.
	currentSet := currentNodes asIdentitySet.
	self restoreRetiredNodesExcept: currentSet.
	currentNodes do: [ :each |
		self ensureConfigurationFor: each.
		self restoreOrientationOf: each over: aPhysicsStep timeStep ]
]

{ #category : 'private - validation' }
CFPhysicsOrientationRestoringBehaviour >> validateNodes: currentNodes [
	currentNodes do: [ :node |
		(node physics behaviourWorld == world) ifFalse: [
			self error: 'Orientation-restoring nodes must belong to the Behaviour physics world' ] ]
]

{ #category : 'private - configuration' }
CFPhysicsOrientationRestoringBehaviour >> ensureConfigurationFor: aNode [
	| body |
	(targetRotations includesKey: aNode) ifTrue: [ ^ self ].
	body := aNode physics requireBodyState.
	targetRotations at: aNode put: body rotation.
	originalDensityByNode at: aNode put: body density.
	originalAngularDampingByNode at: aNode put: body angularDamping.
	density ifNotNil: [ body density: density ].
	angularDamping ifNotNil: [ body angularDamping: angularDamping ]
]

{ #category : 'private - restoring' }
CFPhysicsOrientationRestoringBehaviour >> restoreOrientationOf: aNode over: aTimeStep [
	| body target error angularAcceleration inverseInertia torque |
	body := aNode physics requireBodyState.
	body isDynamic ifFalse: [ ^ self ].
	target := targetRotations at: aNode.
	error := self shortestAngleFrom: body rotation to: target.
	(error abs <= angleTolerance and: [ body angularVelocity abs <= angularVelocityTolerance ])
		ifTrue: [
			error isZero ifFalse: [ body rotation: target ].
			body angularVelocity isZero ifFalse: [ body angularVelocity: 0.0 ].
			^ self ].
	angularAcceleration := (stiffness * error) - (damping * body angularVelocity).
	angularAcceleration := (angularAcceleration max: maximumAngularAcceleration negated)
		min: maximumAngularAcceleration.
	inverseInertia := body inverseInertia.
	inverseInertia isZero ifTrue: [ ^ self ].
	torque := angularAcceleration / inverseInertia.
	body applyTorque: torque
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

{ #category : 'private - lifecycle' }
CFPhysicsOrientationRestoringBehaviour >> restoreRetiredNodesExcept: currentNodes [
	targetRotations keys copy do: [ :each |
		(currentNodes includes: each) ifFalse: [ self restoreNode: each ] ]
]

{ #category : 'private - lifecycle' }
CFPhysicsOrientationRestoringBehaviour >> restoreNode: aNode [
	| physics body |
	physics := aNode existingPhysics.
	body := physics ifNil: [ nil ] ifNotNil: [ physics bodyState ].
	body ifNotNil: [
		(originalDensityByNode at: aNode ifAbsent: [ nil ]) ifNotNil: [ :originalDensity |
			body density: originalDensity ].
		(originalAngularDampingByNode at: aNode ifAbsent: [ nil ]) ifNotNil: [ :originalDamping |
			body angularDamping: originalDamping ] ].
	targetRotations removeKey: aNode ifAbsent: [ ].
	originalDensityByNode removeKey: aNode ifAbsent: [ ].
	originalAngularDampingByNode removeKey: aNode ifAbsent: [ ]
]

{ #category : 'removing' }
CFPhysicsOrientationRestoringBehaviour >> removing [
	targetRotations keys copy do: [ :each | self restoreNode: each ]
]
