Class {
	#name : 'CFPhysicsImpactSolver',
	#superclass : 'Object',
	#instVars : [ 'constraintBuilder' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsImpactSolver >> initialize [
	super initialize.
	constraintBuilder := CFPhysicsConstraintBuilder new
]

{ #category : 'solving' }
CFPhysicsImpactSolver >> solveAdvancement: advancement bodyStates: bodyStates step: step restitutionThreshold: restitutionThreshold [
	| pair firstState secondState manifold contact constraints solver |
	pair := advancement impact pair.
	firstState := bodyStates at: pair firstBody.
	secondState := bodyStates at: pair secondBody.
	manifold := CFPhysicsCollision
		manifoldBetweenShapeState: pair firstBody shapeState
		transform: firstState currentTransform
		andShapeState: pair secondBody shapeState
		transform: secondState currentTransform.
	manifold ifNil: [
		^ CFPhysicsImpactSolveResult
			advancement: advancement
			contact: nil
			constraints: #() ].
	contact := CFPhysicsContact pair: pair manifold: manifold.
	constraints := constraintBuilder
		constraintsFrom: { contact }
		bodyStates: bodyStates
		warmStartRatio: 0.0.
	solver := CFPhysicsSoftStepSolver
		step: step
		bodyStates: bodyStates
		constraints: constraints.
	solver solveImpactWithRestitutionThreshold: restitutionThreshold.
	^ CFPhysicsImpactSolveResult
		advancement: advancement
		contact: contact
		constraints: constraints
]

{ #category : 'accessing' }
CFPhysicsImpactSolver >> constraintBuilder [ ^ constraintBuilder ]

{ #category : 'accessing' }
CFPhysicsImpactSolver >> constraintBuilder: anObject [ constraintBuilder := anObject ]
