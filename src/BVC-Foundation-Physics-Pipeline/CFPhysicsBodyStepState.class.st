Class {
	#name : 'CFPhysicsBodyStepState',
	#superclass : 'Object',
	#instVars : [ 'body', 'linearVelocity', 'angularVelocity', 'deltaPosition', 'deltaRotation' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsBodyStepState class >> on: aBody [
	^ self new body: aBody; capture; yourself
]

{ #category : 'initialization' }
CFPhysicsBodyStepState >> capture [
	linearVelocity := body velocity.
	angularVelocity := body angularVelocity.
	deltaPosition := 0 @ 0.
	deltaRotation := 0.0
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integrateVelocityBy: seconds gravity: gravityVector [
	body isDynamic ifFalse: [ ^ self ].
	linearVelocity := linearVelocity + ((((gravityVector * body gravityScale) + (body force * body inverseMass))) * seconds).
	angularVelocity := angularVelocity + (body torque * body inverseInertia * seconds).
	body linearDamping > 0.0 ifTrue: [
		linearVelocity := linearVelocity * (1.0 / (1.0 + (seconds * body linearDamping))) ].
	body angularDamping > 0.0 ifTrue: [
		angularVelocity := angularVelocity * (1.0 / (1.0 + (seconds * body angularDamping))) ]
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integratePositionBy: seconds [
	body isAwake ifFalse: [ ^ self ].
	deltaPosition := deltaPosition + (linearVelocity * seconds).
	deltaRotation := deltaRotation + (angularVelocity * seconds)
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> translateBy: aPoint [
	body isDynamic ifTrue: [ deltaPosition := deltaPosition + aPoint ]
]

{ #category : 'committing' }
CFPhysicsBodyStepState >> commit [
	body
		commitPosition: body position + deltaPosition
		rotation: body rotation + deltaRotation
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
	| currentTransform |
	currentTransform := self currentTransform.
	body isAwake ifFalse: [ ^ currentTransform ].
	^ CFPhysicsTransform
		position: currentTransform position + (linearVelocity * seconds)
		rotation: currentTransform rotation + (angularVelocity * seconds)
]

{ #category : 'prediction' }
CFPhysicsBodyStepState >> predictedSweepFor: seconds [
	^ CFPhysicsSweep
		from: self currentTransform
		to: (self predictedTransformAfter: seconds)
]
{ #category : 'prediction' }
CFPhysicsBodyStepState >> predictedSweptAABBFor: seconds [
	^ body shapeState sweptAABBAlong: (self predictedSweepFor: seconds)
]

{ #category : 'prediction' }
CFPhysicsBodyStepState >> currentTransform [
	^ CFPhysicsTransform
		position: body position + deltaPosition
		rotation: body rotation + deltaRotation
]


{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> startTransform [
	^ CFPhysicsTransform position: body position rotation: body rotation
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
	^ body shapeState sweptAABBAlong: self solvedSweep
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
	^ deltaPosition r + (deltaRotation abs * body shapeState boundingRadius)
]

{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> isFastForContinuousCollision [
	body isDynamic ifFalse: [ ^ false ].
	body isAwake ifFalse: [ ^ false ].
	body isSensor ifTrue: [ ^ false ].
	^ self maximumPointMotion > (0.5 * body shapeState minimumExtent)
]

