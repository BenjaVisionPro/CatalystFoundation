"I capture the immutable world-level values needed to describe one detached Physics step.

The worker combines me with its calculation-owned pipeline result. I never inspect or mutate the live world."
Class {
	#name : 'CFPhysicsStepTelemetryContext',
	#superclass : 'Object',
	#instVars : [ 'world', 'solveTicket', 'bodyCount', 'jointCount' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsStepTelemetryContext class >> world: aWorld state: aWorldState [
	^ self new
		world: aWorld;
		solveTicket: aWorldState solveTicket;
		bodyCount: aWorldState orderedBodyStates size;
		jointCount: aWorldState joints size;
		yourself
]

{ #category : 'accessing' }
CFPhysicsStepTelemetryContext >> world: anObject [ world := anObject ]
{ #category : 'accessing' }
CFPhysicsStepTelemetryContext >> solveTicket: anInteger [ solveTicket := anInteger ]
{ #category : 'accessing' }
CFPhysicsStepTelemetryContext >> bodyCount: anInteger [ bodyCount := anInteger ]
{ #category : 'accessing' }
CFPhysicsStepTelemetryContext >> jointCount: anInteger [ jointCount := anInteger ]

{ #category : 'telemetry' }
CFPhysicsStepTelemetryContext >> dataForSolution: aWorldSolution pipeline: aPipeline [
	| result solvedIslands bodyStates pairFinder preparation step |
	result := aWorldSolution pipelineResult.
	bodyStates := result bodyStates values.
	step := result step.
	solvedIslands := result islands select: [ :island |
		island dynamicBodies anySatisfy: #isAwake ].
	pairFinder := (aPipeline stageOfType: CFPhysicsPairFinderStage) pairFinder.
	preparation := aPipeline stageOfType: CFPhysicsConstraintPreparationStage.
	^ Dictionary new
		at: #physicsWorld put: world;
		at: #kind put: #step;
		at: #solveTicket put: solveTicket;
		at: #stepNumber put: step stepNumber;
		at: #simulationTime put: step simulationTime + step timeStep;
		at: #bodyCount put: bodyCount;
		at: #activeBodyCount put: (bodyStates count: #isAwake);
		at: #sleepingBodyCount put: (bodyStates count: [ :each | each isAwake not ]);
		at: #contactCount put: result activeContacts size;
		at: #pairFinderEntryCount put: pairFinder entryCount;
		at: #pairFinderComparisonCount put: pairFinder comparisonCount;
		at: #pairFinderAcceptedPairCount put: pairFinder acceptedPairCount;
		at: #pairFinderMaximumActiveCount put: pairFinder maximumActiveCount;
		at: #constraintCount put: result constraints size;
		at: #jointCount put: jointCount;
		at: #islandCount put: result islands size;
		at: #solvedIslandCount put: solvedIslands size;
		at: #largestSolvedIslandBodyCount put: (self largestBodyCountIn: solvedIslands);
		at: #largestSolvedIslandDynamicBodyCount put: (self largestDynamicBodyCountIn: solvedIslands);
		at: #largestSolvedIslandConstraintCount put: (self largestConstraintCountIn: solvedIslands);
		at: #solvedIslandConstraintCount put: (solvedIslands inject: 0 into: [ :total :island | total + island constraints size ]);
		at: #solverContactConstraintCount put: result solver contactConstraintCount;
		at: #solverContactPointCount put: result solver contactPointCount;
		at: #solverWarmStartedContactPointCount put: result solver warmStartedContactPointCount;
		at: #solverRestitutionCandidatePointCount put: result solver restitutionCandidatePointCount;
		at: #solverJointConstraintCount put: result solver jointConstraintCount;
		at: #solverDistanceJointConstraintCount put: result solver distanceJointConstraintCount;
		at: #solverRailJointConstraintCount put: result solver railJointConstraintCount;
		at: #solverRevoluteJointConstraintCount put: result solver revoluteJointConstraintCount;
		at: #solverFixedJointConstraintCount put: result solver fixedJointConstraintCount;
		at: #preparedContactConstraintCount put: preparation preparedContactConstraintCount;
		at: #continuedPreparedContactConstraintCount put: preparation continuedContactConstraintCount;
		at: #beganPreparedContactConstraintCount put: preparation beganContactConstraintCount;
		at: #preparedContactPointCount put: preparation preparedContactPointCount;
		at: #reusablePreparedContactPointCount put: preparation reusableContactPointCount;
		at: #newPreparedContactPointCount put: preparation newContactPointCount;
		at: #stablePreparedManifoldCount put: preparation stableManifoldCount;
		at: #changedPreparedManifoldCount put: preparation changedManifoldCount;
		at: #preparedJointConstraintCount put: preparation preparedJointConstraintCount;
		at: #preparedConstraintObjectCount put: preparation preparedObjectCount;
		at: #stepResult put: result;
		yourself
]

{ #category : 'private' }
CFPhysicsStepTelemetryContext >> largestBodyCountIn: islands [
	^ islands ifEmpty: [ 0 ] ifNotEmpty: [ (islands collect: [ :island | island bodies size ]) max ]
]
{ #category : 'private' }
CFPhysicsStepTelemetryContext >> largestDynamicBodyCountIn: islands [
	^ islands ifEmpty: [ 0 ] ifNotEmpty: [ (islands collect: [ :island | island dynamicBodies size ]) max ]
]
{ #category : 'private' }
CFPhysicsStepTelemetryContext >> largestConstraintCountIn: islands [
	^ islands ifEmpty: [ 0 ] ifNotEmpty: [ (islands collect: [ :island | island constraints size ]) max ]
]
