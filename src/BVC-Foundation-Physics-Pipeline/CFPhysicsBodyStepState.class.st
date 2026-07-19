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
	body isAwake ifFalse: [ ^ self ].
	linearVelocity := linearVelocity + (gravityVector * seconds).
	angularVelocity := angularVelocity + (body torque * body inverseInertia * seconds).
	body angularDamping > 0.0 ifTrue: [
		angularVelocity := angularVelocity * (1.0 / (1.0 + (seconds * body angularDamping))) ]
]

{ #category : 'integration' }
CFPhysicsBodyStepState >> integratePositionBy: seconds [
	body isAwake ifFalse: [ ^ self ].
	deltaPosition := deltaPosition + (linearVelocity * seconds).
	deltaRotation := deltaRotation + (angularVelocity * seconds)
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
