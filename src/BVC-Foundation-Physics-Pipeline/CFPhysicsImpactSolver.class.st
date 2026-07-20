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
	^ (self
		solveAdvancements: { advancement }
		bodyStates: bodyStates
		step: step
		restitutionThreshold: restitutionThreshold) first
]

{ #category : 'solving' }
CFPhysicsImpactSolver >> solveAdvancements: advancements bodyStates: bodyStates step: step restitutionThreshold: restitutionThreshold [
	| results constraints solver |
	results := advancements collect: [ :advancement |
		self resultForAdvancement: advancement bodyStates: bodyStates ].
	constraints := results flatCollect: #constraints.
	constraints ifNotEmpty: [
		solver := CFPhysicsSoftStepSolver
			step: step
			bodyStates: bodyStates
			constraints: constraints.
		solver solveImpactWithRestitutionThreshold: restitutionThreshold ].
	^ results asArray
]

{ #category : 'private - solving' }
CFPhysicsImpactSolver >> resultForAdvancement: advancement bodyStates: bodyStates [
	| pair firstState secondState manifold contact constraints |
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
	^ CFPhysicsImpactSolveResult
		advancement: advancement
		contact: contact
		constraints: constraints
]

{ #category : 'accessing' }
CFPhysicsImpactSolver >> constraintBuilder [ ^ constraintBuilder ]

{ #category : 'accessing' }
CFPhysicsImpactSolver >> constraintBuilder: anObject [ constraintBuilder := anObject ]
