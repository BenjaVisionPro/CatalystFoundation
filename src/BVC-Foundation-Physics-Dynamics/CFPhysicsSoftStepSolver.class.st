Class {
	#name : 'CFPhysicsSoftStepSolver',
	#superclass : 'Object',
	#instVars : [ 'world', 'step', 'bodyStates', 'constraints' ],
	#category : 'BVC-Foundation-Physics-Dynamics',
	#package : 'BVC-Foundation-Physics-Dynamics'
}

{ #category : 'instance creation' }
CFPhysicsSoftStepSolver class >> world: aWorld step: aStep [
	^ self new world: aWorld; step: aStep; yourself
]

{ #category : 'solving' }
CFPhysicsSoftStepSolver >> solve [
	self captureBodies.
	self prepareConstraints.
	bodyStates valuesDo: [ :state |
		state integrateVelocityBy: step timeStep gravity: world gravity ].
	constraints do: [ :each | each warmStart ].
	step substepCount timesRepeat: [
		constraints do: [ :each | each solveWith: step biasEnabled: true ].
		bodyStates valuesDo: [ :state | state integratePositionBy: step substepTime ].
		constraints do: [ :each | each solveWith: step biasEnabled: false ] ].
	constraints do: [ :each | each applyRestitutionWithThreshold: world restitutionThreshold ].
	bodyStates valuesDo: [ :state | state commit ]
]

{ #category : 'private' }
CFPhysicsSoftStepSolver >> captureBodies [
	bodyStates := IdentityDictionary new.
	world bodyStatesInOrder do: [ :body |
		bodyStates at: body put: (CFPhysicsBodyStepState on: body) ]
]

{ #category : 'private' }
CFPhysicsSoftStepSolver >> prepareConstraints [
	constraints := world contacts collect: [ :contact |
		CFPhysicsContactConstraint
			contact: contact
			bodyStateA: (bodyStates at: contact firstBody)
			bodyStateB: (bodyStates at: contact secondBody) ]
]

{ #category : 'accessing' }
CFPhysicsSoftStepSolver >> world: aWorld [ world := aWorld ]
{ #category : 'accessing' }
CFPhysicsSoftStepSolver >> step: aStep [ step := aStep ]
