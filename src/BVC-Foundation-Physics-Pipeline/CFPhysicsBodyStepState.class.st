Class {
	#name : 'CFPhysicsBodyStepState',
	#superclass : 'Object',
	#instVars : [ 'body', 'bodyType', 'position', 'rotation', 'linearVelocity', 'angularVelocity', 'force', 'torque', 'inverseMass', 'inverseInertia', 'linearDamping', 'angularDamping', 'gravityScale', 'shapeState', 'awake', 'sensor', 'deltaPosition', 'deltaRotation' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsBodyStepState class >> on: aBody [
	^ self new body: aBody; capture; yourself
]

{ #category : 'initialization' }
CFPhysicsBodyStepState >> capture [
	bodyType := body bodyType.
	position := body position.
	rotation := body rotation.
	linearVelocity := body velocity.
	angularVelocity := body angularVelocity.
	force := body force.
	torque := body torque.
	inverseMass := body inverseMass.
	inverseInertia := body inverseInertia.
	linearDamping := body linearDamping.
	angularDamping := body angularDamping.
	gravityScale := body gravityScale.
	shapeState := body shapeState.
	awake := body isAwake.
	sensor := body isSensor.
	deltaPosition := 0 @ 0.
	deltaRotation := 0.0
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integrateVelocityBy: seconds gravity: gravityVector [
	bodyType isDynamic ifFalse: [ ^ self ].
	awake ifFalse: [ ^ self ].
	self integrateDynamicVelocityBy: seconds gravity: gravityVector
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integrateDynamicVelocityBy: seconds gravity: gravityVector [
	linearVelocity := linearVelocity + ((((gravityVector * gravityScale) + (force * inverseMass))) * seconds).
	angularVelocity := angularVelocity + (torque * inverseInertia * seconds).
	linearDamping > 0.0 ifTrue: [
		linearVelocity := linearVelocity * (1.0 / (1.0 + (seconds * linearDamping))) ].
	angularDamping > 0.0 ifTrue: [
		angularVelocity := angularVelocity * (1.0 / (1.0 + (seconds * angularDamping))) ]
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integratePositionBy: seconds [
	bodyType isStatic ifTrue: [ ^ self ].
	(bodyType isDynamic and: [ awake not ]) ifTrue: [ ^ self ].
	self integrateCurrentVelocityBy: seconds
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integrateCurrentVelocityBy: seconds [
	deltaPosition := deltaPosition + (linearVelocity * seconds).
	deltaRotation := deltaRotation + (angularVelocity * seconds)
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> translateBy: aPoint [
	bodyType isMovable ifTrue: [ self accumulateTranslation: aPoint ]
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> accumulateTranslation: aPoint [
	deltaPosition := deltaPosition + aPoint
]

{ #category : 'committing' }
CFPhysicsBodyStepState >> commit [
	body
		commitPosition: position + deltaPosition
		rotation: rotation + deltaRotation
		velocity: linearVelocity
		angularVelocity: angularVelocity
]

{ #category : 'accessing' }
CFPhysicsBodyStepState >> body [ ^ body ]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> body: aBody [ body := aBody ]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> linearVelocity [ ^ linearVelocity ]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> linearVelocity: aPoint [ linearVelocity := aPoint ]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> angularVelocity [ ^ angularVelocity ]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> angularVelocity: aNumber [ angularVelocity := aNumber ]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> deltaPosition [ ^ deltaPosition ]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> deltaRotation [ ^ deltaRotation ]

{ #category : 'prediction' }
CFPhysicsBodyStepState >> predictedTransformAfter: seconds [
	bodyType isStatic ifTrue: [ ^ self currentTransform ].
	(bodyType isDynamic and: [ awake not ]) ifTrue: [ ^ self currentTransform ].
	^ CFPhysicsTransform
		position: self currentTransform position + (linearVelocity * seconds)
		rotation: self currentTransform rotation + (angularVelocity * seconds)
]

{ #category : 'prediction' }
CFPhysicsBodyStepState >> predictedSweepFor: seconds [
	^ CFPhysicsSweep
		from: self currentTransform
		to: (self predictedTransformAfter: seconds)
]
{ #category : 'prediction' }
CFPhysicsBodyStepState >> predictedSweptAABBFor: seconds [
	^ shapeState sweptAABBAlong: (self predictedSweepFor: seconds)
]

{ #category : 'prediction' }
CFPhysicsBodyStepState >> currentTransform [
	^ CFPhysicsTransform
		position: position + deltaPosition
		rotation: rotation + deltaRotation
]


{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> startTransform [
	^ CFPhysicsTransform position: position rotation: rotation
]

{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> solvedTransform [
	^ self currentTransform
]

{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> solvedSweep [
	^ CFPhysicsSweep from: self startTransform to: self solvedTransform
]


{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> solvedSweptAABB [
	^ shapeState sweptAABBAlong: self solvedSweep
]

{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> clampSolvedTransformToFraction: aFraction [
	| fraction |
	fraction := (aFraction max: 0.0) min: 1.0.
	deltaPosition := deltaPosition * fraction.
	deltaRotation := deltaRotation * fraction
]

{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> maximumPointMotion [
	^ deltaPosition r + (deltaRotation abs * shapeState boundingRadius)
]

{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> isFastForContinuousCollision [
	bodyType isDynamic ifFalse: [ ^ false ].
	awake ifFalse: [ ^ false ].
	sensor ifTrue: [ ^ false ].
	^ self maximumPointMotion > (0.5 * shapeState minimumExtent)
]

