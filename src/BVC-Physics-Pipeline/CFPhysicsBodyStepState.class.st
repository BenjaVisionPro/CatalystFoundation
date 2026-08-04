"
I represent one body's mutable state during a simulation step. I isolate solver changes from the persistent body until the step is committed.
"

Class {
	#name : 'CFPhysicsBodyStepState',
	#superclass : 'Object',
	#instVars : [ 'body', 'bodyType', 'bodyOrigin', 'rotation', 'linearVelocity', 'angularVelocity', 'force', 'torque', 'inverseMass', 'inverseInertia', 'linearDamping', 'angularDamping', 'gravityScale', 'shapeState', 'shapeStates', 'friction', 'restitution', 'rollingResistance', 'tangentSpeed', 'awake', 'sleepingAllowed', 'sleepThreshold', 'sleepTime', 'collisionCategoryBits', 'collisionMaskBits', 'collisionGroupIndex', 'deltaPosition', 'deltaRotation', 'bullet', 'allowFastRotation' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsBodyStepState class >> on: aBody [
	^ self new body: aBody; capture; yourself
]

{ #category : 'initialization' }
CFPhysicsBodyStepState >> capture [
	bodyType := body bodyType.
	bodyOrigin := body worldBodyOrigin.
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
	shapeStates := IdentityDictionary new.
	body shapes do: [ :each | shapeStates at: each put: each capturedForStep ].
	shapeState := shapeStates at: body shapeState.
	friction := body friction.
	restitution := body restitution.
	rollingResistance := body rollingResistance.
	tangentSpeed := body tangentSpeed.
	awake := body isAwake.
	sleepingAllowed := body allowsSleeping.
	sleepThreshold := body world
		ifNil: [ body sleepThreshold * 100.0 ]
		ifNotNil: [ :aWorld | aWorld lengthUnitsForMetres: body sleepThreshold ].
	sleepTime := body sleepTime.
	collisionCategoryBits := body collisionCategoryBits.
	collisionMaskBits := body collisionMaskBits.
	collisionGroupIndex := body collisionGroupIndex.
	bullet := body isBullet.
	allowFastRotation := body allowFastRotation.
	deltaPosition := 0 @ 0.
	deltaRotation := 0.0
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integrateVelocityBy: seconds gravity: gravityVector [
	^ self
		integrateVelocityBy: seconds
		gravity: gravityVector
		maximumLinearSpeed: Float infinity
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integrateVelocityBy: seconds gravity: gravityVector maximumLinearSpeed: aMaximumLinearSpeed [
	| maximumAngularSpeed |
	maximumAngularSpeed := seconds <= 0.0
		ifTrue: [ Float infinity ]
		ifFalse: [ Float pi * 0.25 / seconds ].
	^ self
		integrateVelocityBy: seconds
		gravity: gravityVector
		maximumLinearSpeed: aMaximumLinearSpeed
		maximumAngularSpeed: maximumAngularSpeed
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integrateVelocityBy: seconds gravity: gravityVector maximumLinearSpeed: aMaximumLinearSpeed maximumAngularSpeed: aMaximumAngularSpeed [
	bodyType isDynamic ifFalse: [ ^ self ].
	awake ifFalse: [ ^ self ].
	self
		integrateDynamicVelocityBy: seconds
		gravity: gravityVector
		maximumLinearSpeed: aMaximumLinearSpeed
		maximumAngularSpeed: aMaximumAngularSpeed
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integrateDynamicVelocityBy: seconds gravity: gravityVector [
	^ self
		integrateDynamicVelocityBy: seconds
		gravity: gravityVector
		maximumLinearSpeed: Float infinity
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integrateDynamicVelocityBy: seconds gravity: gravityVector maximumLinearSpeed: aMaximumLinearSpeed [
	| maximumAngularSpeed |
	maximumAngularSpeed := seconds <= 0.0
		ifTrue: [ Float infinity ]
		ifFalse: [ Float pi * 0.25 / seconds ].
	^ self
		integrateDynamicVelocityBy: seconds
		gravity: gravityVector
		maximumLinearSpeed: aMaximumLinearSpeed
		maximumAngularSpeed: maximumAngularSpeed
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integrateDynamicVelocityBy: seconds gravity: gravityVector maximumLinearSpeed: aMaximumLinearSpeed maximumAngularSpeed: aMaximumAngularSpeed [
	| linearVelocityDelta angularVelocityDelta linearDampingFactor angularDampingFactor |
	linearVelocityDelta := ((gravityVector * gravityScale) + (force * inverseMass)) * seconds.
	angularVelocityDelta := torque * inverseInertia * seconds.
	linearDampingFactor := 1.0 / (1.0 + (seconds * linearDamping)).
	angularDampingFactor := 1.0 / (1.0 + (seconds * angularDamping)).
	linearVelocity := linearVelocityDelta + (linearVelocity * linearDampingFactor).
	angularVelocity := angularVelocityDelta + (angularVelocity * angularDampingFactor).
	self
		limitVelocityMaximumLinearSpeed: aMaximumLinearSpeed
		maximumAngularSpeed: aMaximumAngularSpeed
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> limitVelocityMaximumLinearSpeed: aMaximumLinearSpeed maximumAngularSpeed: aMaximumAngularSpeed [
	| linearSpeed |
	linearSpeed := linearVelocity r.
	linearSpeed > aMaximumLinearSpeed ifTrue: [
		linearVelocity := linearVelocity * (aMaximumLinearSpeed / linearSpeed) ].
	(allowFastRotation not and: [ angularVelocity abs > aMaximumAngularSpeed ]) ifTrue: [
		angularVelocity := angularVelocity >= 0.0
			ifTrue: [ aMaximumAngularSpeed ]
			ifFalse: [ aMaximumAngularSpeed negated ] ]
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
		commitBodyOrigin: bodyOrigin + deltaPosition
		rotation: rotation + deltaRotation
		velocity: linearVelocity
		angularVelocity: angularVelocity.
	body commitAwake: awake sleepTime: sleepTime
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


{ #category : 'accessing' }
CFPhysicsBodyStepState >> friction [ ^ friction ]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> restitution [ ^ restitution ]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> rollingResistance [ ^ rollingResistance ]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> tangentSpeed [ ^ tangentSpeed ]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> inverseMass [ ^ inverseMass ]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> inverseInertia [ ^ inverseInertia ]


{ #category : 'accessing' }
CFPhysicsBodyStepState >> shapeStateFor: aShape [
	^ shapeStates at: aShape
]

{ #category : 'accessing' }
CFPhysicsBodyStepState >> shapeStates [
	^ shapeStates
]
{ #category : 'accessing' }
CFPhysicsBodyStepState >> shapeState [ ^ shapeState ]


{ #category : 'waking' }
CFPhysicsBodyStepState >> wake [
	awake := true.
	sleepTime := 0.0
]

{ #category : 'testing' }
CFPhysicsBodyStepState >> isAwake [ ^ awake ]

{ #category : 'testing' }
CFPhysicsBodyStepState >> isSensor [ ^ shapeState isSensor ]

{ #category : 'prediction' }
CFPhysicsBodyStepState >> predictedTransformAfter: seconds [
	bodyType isStatic ifTrue: [ ^ self currentTransform ].
	(bodyType isDynamic and: [ awake not ]) ifTrue: [ ^ self currentTransform ].
	^ CFPhysicsTransform
		bodyOrigin: self currentTransform bodyOrigin + (linearVelocity * seconds)
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

{ #category : 'geometry - coordinates' }
CFPhysicsBodyStepState >> currentBodyOrigin [
	^ bodyOrigin + deltaPosition
]

{ #category : 'geometry - coordinates' }
CFPhysicsBodyStepState >> startBodyOrigin [
	^ bodyOrigin
]

{ #category : 'geometry - coordinates' }
CFPhysicsBodyStepState >> bodyLocalPointForElementLocalPoint: aPoint [
	^ shapeState bodyLocalPointForElementLocalPoint: aPoint
]

{ #category : 'prediction' }
CFPhysicsBodyStepState >> currentTransform [
	^ CFPhysicsTransform
		bodyOrigin: self currentBodyOrigin
		rotation: rotation + deltaRotation
]


{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> startTransform [
	^ CFPhysicsTransform bodyOrigin: self startBodyOrigin rotation: rotation
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
CFPhysicsBodyStepState >> requiresContinuousCollisionAgainst: anotherStepState [
	self isBullet ifTrue: [ ^ anotherStepState isBullet not ].
	^ anotherStepState bodyType isStatic
]



{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> isBullet [
	^ bullet
]

{ #category : 'accessing' }
CFPhysicsBodyStepState >> bodyType [ ^ bodyType ]

{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> maximumPointMotion [
	^ deltaPosition r + (deltaRotation abs * shapeState boundingRadius)
]

{ #category : 'continuous collision' }
CFPhysicsBodyStepState >> isFastForContinuousCollision [
	bodyType isDynamic ifFalse: [ ^ false ].
	awake ifFalse: [ ^ false ].
	self isSensor ifTrue: [ ^ false ].
	^ self maximumPointMotion > (0.5 * shapeState minimumExtent)
]



{ #category : 'sleeping' }
CFPhysicsBodyStepState >> allowsSleeping [ ^ sleepingAllowed ]

{ #category : 'sleeping' }
CFPhysicsBodyStepState >> sleepThreshold [ ^ sleepThreshold ]

{ #category : 'sleeping' }
CFPhysicsBodyStepState >> sleepVelocityForElapsed: seconds positionCorrectionFactor: aFactor [
	| maximumVelocity maximumCorrection |
	maximumVelocity := linearVelocity r
		+ (angularVelocity abs * shapeState boundingRadius).
	seconds <= 0.0 ifTrue: [ ^ maximumVelocity ].
	maximumCorrection := deltaPosition r
		+ (deltaRotation sin abs * shapeState boundingRadius).
	^ maximumVelocity max: aFactor * maximumCorrection / seconds
]

{ #category : 'sleeping' }
CFPhysicsBodyStepState >> sleepTime [ ^ sleepTime ]

{ #category : 'sleeping' }
CFPhysicsBodyStepState >> advanceSleepTimeBy: seconds [
	sleepTime := sleepTime + seconds
]

{ #category : 'sleeping' }
CFPhysicsBodyStepState >> resetSleepTime [
	sleepTime := 0.0
]

{ #category : 'sleeping' }
CFPhysicsBodyStepState >> sleep [
	awake := false.
	sleepTime := 0.0.
	linearVelocity := 0 @ 0.
	angularVelocity := 0.0
]


{ #category : 'collision filtering' }
CFPhysicsBodyStepState >> formsCollisionPairWith: anotherStepState [
	^ bodyType formsCollisionPairWith: anotherStepState bodyType
]

{ #category : 'collision filtering' }
CFPhysicsBodyStepState >> allowsCollisionWith: anotherStepState [
	(collisionGroupIndex ~= 0 and: [
		collisionGroupIndex = anotherStepState collisionGroupIndex ]) ifTrue: [
		^ collisionGroupIndex > 0 ].
	^ ((collisionMaskBits bitAnd: anotherStepState collisionCategoryBits) ~= 0)
		and: [ (anotherStepState collisionMaskBits bitAnd: collisionCategoryBits) ~= 0 ]
]

{ #category : 'collision filtering' }
CFPhysicsBodyStepState >> collisionCategoryBits [
	^ collisionCategoryBits
]

{ #category : 'collision filtering' }
CFPhysicsBodyStepState >> collisionMaskBits [
	^ collisionMaskBits
]

{ #category : 'collision filtering' }
CFPhysicsBodyStepState >> collisionGroupIndex [
	^ collisionGroupIndex
]

{ #category : 'geometry - coordinates' }
CFPhysicsBodyStepState >> worldPointForBodyLocalPoint: aPoint [
	^ self worldBodyOrigin
		+ (shapeState
			rotateVector: aPoint
			by: rotation + deltaRotation)
]

{ #category : 'geometry - coordinates' }
CFPhysicsBodyStepState >> bodyLocalPointForWorldPoint: aPoint [
	^ shapeState
		rotateVector: aPoint - self worldBodyOrigin
		by: (rotation + deltaRotation) negated
]



{ #category : 'geometry - coordinates' }
CFPhysicsBodyStepState >> worldBodyOrigin [
	^ self currentBodyOrigin
]

{ #category : 'geometry - coordinates' }
CFPhysicsBodyStepState >> worldVectorForBodyLocalVector: aPoint [
	^ shapeState
		rotateVector: aPoint
		by: rotation + deltaRotation
]

{ #category : 'geometry - coordinates' }
CFPhysicsBodyStepState >> bodyLocalVectorForWorldVector: aPoint [
	^ shapeState
		rotateVector: aPoint
		by: (rotation + deltaRotation) negated
]
