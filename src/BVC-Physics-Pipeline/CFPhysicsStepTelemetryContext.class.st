"
I capture the world and workload context associated with a telemetry-recorded solve. I combine pipeline measurements with stable world and solve identifiers.
"

Class {
	#name : 'CFPhysicsStepTelemetryContext',
	#superclass : 'Object',
	#instVars : [ 'world', 'solveTicket', 'bodyCount', 'jointCount' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
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
	| result solvedIslands bodyStates dynamicBodyStates pairFinder preparation contactUpdater sleepConfiguration step sleepVelocities sleepThresholdRatios motionThresholdRatios correctionThresholdRatios worstState worstRatio worstMotionState worstMotionRatio worstCorrectionState worstCorrectionRatio worstMaximumVelocity worstCorrectionVelocity worstNormalImpulse worstTangentImpulse |
	result := aWorldSolution pipelineResult.
	bodyStates := result bodyStates values.
	dynamicBodyStates := bodyStates select: [ :each | each bodyType isDynamic ].
	step := result step.
	sleepConfiguration := aPipeline sleepConfiguration.
	sleepVelocities := dynamicBodyStates collect: [ :each |
		each sleepVelocityForElapsed: step timeStep positionCorrectionFactor: sleepConfiguration positionCorrectionFactor ].
	sleepThresholdRatios := dynamicBodyStates collect: [ :each |
		| threshold velocity |
		threshold := each sleepThreshold.
		velocity := each sleepVelocityForElapsed: step timeStep positionCorrectionFactor: sleepConfiguration positionCorrectionFactor.
		threshold <= 0.0
			ifTrue: [ velocity = 0.0 ifTrue: [ 0.0 ] ifFalse: [ Float infinity ] ]
			ifFalse: [ velocity / threshold ] ].
	motionThresholdRatios := dynamicBodyStates collect: [ :each |
		| threshold velocity |
		threshold := each sleepThreshold.
		velocity := each linearVelocity r + (each angularVelocity abs * each shapeState boundingRadius).
		threshold <= 0.0
			ifTrue: [ velocity = 0.0 ifTrue: [ 0.0 ] ifFalse: [ Float infinity ] ]
			ifFalse: [ velocity / threshold ] ].
	correctionThresholdRatios := dynamicBodyStates collect: [ :each |
		| threshold velocity |
		threshold := each sleepThreshold.
		velocity := step timeStep <= 0.0
			ifTrue: [ 0.0 ]
			ifFalse: [ sleepConfiguration positionCorrectionFactor
				* (each deltaPosition r + (each deltaRotation sin abs * each shapeState boundingRadius))
				/ step timeStep ].
		threshold <= 0.0
			ifTrue: [ velocity = 0.0 ifTrue: [ 0.0 ] ifFalse: [ Float infinity ] ]
			ifFalse: [ velocity / threshold ] ].
	worstState := nil.
	worstRatio := -1.0.
	worstMotionState := nil.
	worstMotionRatio := -1.0.
	worstCorrectionState := nil.
	worstCorrectionRatio := -1.0.
	dynamicBodyStates do: [ :each |
		| threshold velocity ratio |
		threshold := each sleepThreshold.
		velocity := each sleepVelocityForElapsed: step timeStep positionCorrectionFactor: sleepConfiguration positionCorrectionFactor.
		ratio := threshold <= 0.0
			ifTrue: [ velocity = 0.0 ifTrue: [ 0.0 ] ifFalse: [ Float infinity ] ]
			ifFalse: [ velocity / threshold ].
		ratio > worstRatio ifTrue: [
			worstRatio := ratio.
			worstState := each ].
		((motionThresholdRatios at: (dynamicBodyStates indexOf: each)) > worstMotionRatio) ifTrue: [
			worstMotionRatio := motionThresholdRatios at: (dynamicBodyStates indexOf: each).
			worstMotionState := each ].
		((correctionThresholdRatios at: (dynamicBodyStates indexOf: each)) > worstCorrectionRatio) ifTrue: [
			worstCorrectionRatio := correctionThresholdRatios at: (dynamicBodyStates indexOf: each).
			worstCorrectionState := each ] ].
	worstMaximumVelocity := 0.0.
	worstCorrectionVelocity := 0.0.
	worstNormalImpulse := 0.0.
	worstTangentImpulse := 0.0.
	worstState ifNotNil: [
		worstMaximumVelocity := worstState linearVelocity r
			+ (worstState angularVelocity abs * worstState shapeState boundingRadius).
		step timeStep > 0.0 ifTrue: [
			worstCorrectionVelocity := sleepConfiguration positionCorrectionFactor
				* (worstState deltaPosition r
					+ (worstState deltaRotation sin abs * worstState shapeState boundingRadius))
				/ step timeStep ].
		result activeContacts do: [ :contact |
			(contact firstBody == worstState body or: [ contact secondBody == worstState body ]) ifTrue: [
				contact manifold ifNotNil: [ :manifold |
					manifold contactPoints do: [ :point |
						worstNormalImpulse := worstNormalImpulse + point normalImpulse.
						worstTangentImpulse := worstTangentImpulse + point tangentImpulse abs ] ] ] ] ].
	solvedIslands := result islands select: [ :island |
		island dynamicBodies anySatisfy: #isAwake ].
	pairFinder := (aPipeline stageOfType: CFPhysicsPairFinderStage) pairFinder.
	preparation := aPipeline stageOfType: CFPhysicsConstraintPreparationStage.
	contactUpdater := (aPipeline stageOfType: CFPhysicsContactUpdateStage) contactUpdater.
	^ Dictionary new
		at: #physicsWorld put: world;
		at: #kind put: #step;
		at: #solveTicket put: solveTicket;
		at: #stepNumber put: step stepNumber;
		at: #simulationTime put: step simulationTime + step timeStep;
		at: #bodyCount put: bodyCount;
		at: #activeBodyCount put: (dynamicBodyStates count: #isAwake);
		at: #sleepingBodyCount put: (dynamicBodyStates count: [ :each | each isAwake not ]);
		at: #sleepAllowedBodyCount put: (dynamicBodyStates count: #allowsSleeping);
		at: #sleepMotionAcceptedBodyCount put: (dynamicBodyStates count: [ :each |
			each allowsSleeping and: [ sleepConfiguration acceptsStepState: each elapsed: step timeStep ] ]);
		at: #sleepMotionRejectedBodyCount put: (dynamicBodyStates count: [ :each |
			each allowsSleeping and: [ (sleepConfiguration acceptsStepState: each elapsed: step timeStep) not ] ]);
		at: #sleepMotionOnlyRejectedBodyCount put: ((1 to: dynamicBodyStates size) count: [ :index |
			(dynamicBodyStates at: index) allowsSleeping
				and: [ (motionThresholdRatios at: index) > 1.0
				and: [ (correctionThresholdRatios at: index) <= 1.0 ] ] ]);
		at: #sleepCorrectionOnlyRejectedBodyCount put: ((1 to: dynamicBodyStates size) count: [ :index |
			(dynamicBodyStates at: index) allowsSleeping
				and: [ (motionThresholdRatios at: index) <= 1.0
				and: [ (correctionThresholdRatios at: index) > 1.0 ] ] ]);
		at: #sleepMotionAndCorrectionRejectedBodyCount put: ((1 to: dynamicBodyStates size) count: [ :index |
			(dynamicBodyStates at: index) allowsSleeping
				and: [ (motionThresholdRatios at: index) > 1.0
				and: [ (correctionThresholdRatios at: index) > 1.0 ] ] ]);
		at: #sleepDisabledBodyCount put: (dynamicBodyStates count: [ :each | each allowsSleeping not ]);
		at: #maximumSleepMotionThresholdRatio put: (motionThresholdRatios ifEmpty: [ 0.0 ] ifNotEmpty: [ motionThresholdRatios max ]);
		at: #maximumSleepCorrectionThresholdRatio put: (correctionThresholdRatios ifEmpty: [ 0.0 ] ifNotEmpty: [ correctionThresholdRatios max ]);
		at: #worstSleepMotionBodySequence put: (worstMotionState ifNil: [ 0 ] ifNotNil: [ worstMotionState body sequence ]);
		at: #worstSleepCorrectionBodySequence put: (worstCorrectionState ifNil: [ 0 ] ifNotNil: [ worstCorrectionState body sequence ]);
		at: #maximumSleepVelocity put: (sleepVelocities ifEmpty: [ 0.0 ] ifNotEmpty: [ sleepVelocities max ]);
		at: #maximumSleepThresholdRatio put: (sleepThresholdRatios ifEmpty: [ 0.0 ] ifNotEmpty: [ sleepThresholdRatios max ]);
		at: #minimumSleepTime put: (dynamicBodyStates ifEmpty: [ 0.0 ] ifNotEmpty: [ (dynamicBodyStates collect: #sleepTime) min ]);
		at: #worstSleepBodySequence put: (worstState ifNil: [ 0 ] ifNotNil: [ worstState body sequence ]);
		at: #worstSleepThresholdRatio put: (worstRatio max: 0.0);
		at: #worstSleepLinearSpeed put: (worstState ifNil: [ 0.0 ] ifNotNil: [ worstState linearVelocity r ]);
		at: #worstSleepAngularSpeed put: (worstState ifNil: [ 0.0 ] ifNotNil: [ worstState angularVelocity abs ]);
		at: #worstSleepMaximumVelocity put: worstMaximumVelocity;
		at: #worstSleepCorrectionVelocity put: worstCorrectionVelocity;
		at: #worstSleepTime put: (worstState ifNil: [ 0.0 ] ifNotNil: [ worstState sleepTime ]);
		at: #worstSleepNormalImpulse put: worstNormalImpulse;
		at: #worstSleepTangentImpulse put: worstTangentImpulse;
		at: #worstSleepReason put: (worstCorrectionVelocity > worstMaximumVelocity ifTrue: [ #correction ] ifFalse: [ #velocity ]);
		at: #contactCount put: result activeContacts size;
		at: #persistentContactCount put: result contacts size;
		at: #contactUpdateVisitedPairCount put: contactUpdater visitedPairCount;
		at: #contactUpdatePreviousMatchCount put: contactUpdater previousContactMatchCount;
		at: #contactUpdateReusedContactCount put: contactUpdater reusedContactCount;
		at: #contactUpdateCreatedContactCount put: contactUpdater createdContactCount;
		at: #contactUpdateCopiedContactCount put: contactUpdater copiedContactCount;
		at: #contactUpdateImpactContactCount put: contactUpdater impactContactCount;
		at: #contactUpdateManifoldGenerationCount put: contactUpdater manifoldGenerationCount;
		at: #contactUpdateCachedSimplexCount put: contactUpdater cachedSimplexCount;
		at: #contactUpdateBothSleepingPairCount put: contactUpdater bothSleepingPairCount;
		at: #contactUpdateTouchingContactCount put: contactUpdater touchingContactCount;
		at: #contactUpdateSleepingRetainedContactCount put: contactUpdater sleepingRetainedContactCount;
		at: #contactUpdateAwakeManifoldGenerationCount put: contactUpdater awakeManifoldGenerationCount;
		at: #contactUpdateSleepingImpactManifoldGenerationCount put: contactUpdater sleepingImpactManifoldGenerationCount;
		at: #contactUpdateSleepingNewManifoldGenerationCount put: contactUpdater sleepingNewManifoldGenerationCount;
		at: #contactUpdateSleepingNonTouchingManifoldGenerationCount put: contactUpdater sleepingNonTouchingManifoldGenerationCount;
		at: #contactUpdateSleepingNonSolidManifoldGenerationCount put: contactUpdater sleepingNonSolidManifoldGenerationCount;
		at: #contactUpdateSleepingOtherManifoldGenerationCount put: contactUpdater sleepingOtherManifoldGenerationCount;
		at: #pairFinderEntryCount put: pairFinder entryCount;
		at: #pairFinderComparisonCount put: pairFinder comparisonCount;
		at: #pairFinderAcceptedPairCount put: pairFinder acceptedPairCount;
		at: #pairFinderMaximumActiveCount put: pairFinder maximumActiveCount;
		at: #constraintCount put: result solverConstraints size;
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
		at: #solverMaximumInitialContactPenetration put: result solver maximumInitialContactPenetration;
		at: #solverMaximumFinalContactPenetration put: result solver maximumFinalContactPenetration;
		at: #solverAverageFinalContactPenetration put: result solver averageFinalContactPenetration;
		at: #solverMaximumBodyTranslation put: result solver maximumBodyTranslation;
		at: #solverTotalNormalImpulse put: result solver totalNormalImpulse;
		at: #solverTotalTangentImpulse put: result solver totalTangentImpulse;
		at: #solverJointConstraintCount put: result solver jointConstraintCount;
		at: #solverDistanceJointConstraintCount put: result solver distanceJointConstraintCount;
		at: #solverPrismaticJointConstraintCount put: result solver prismaticJointConstraintCount;
		at: #solverRevoluteJointConstraintCount put: result solver revoluteJointConstraintCount;
		at: #solverWeldJointConstraintCount put: result solver weldJointConstraintCount;
		at: #preparedContactConstraintCount put: preparation preparedContactConstraintCount;
		at: #continuedPreparedContactConstraintCount put: preparation continuedContactConstraintCount;
		at: #beganPreparedContactConstraintCount put: preparation beganContactConstraintCount;
		at: #preparedContactPointCount put: preparation preparedContactPointCount;
		at: #reusablePreparedContactPointCount put: preparation reusableContactPointCount;
		at: #newPreparedContactPointCount put: preparation newContactPointCount;
		at: #stablePreparedManifoldCount put: preparation stableManifoldCount;
		at: #changedPreparedManifoldCount put: preparation changedManifoldCount;
		at: #featureIdChangedPreparedManifoldCount put: preparation featureIdChangedManifoldCount;
		at: #normalChangedPreparedManifoldCount put: preparation normalChangedManifoldCount;
		at: #pointCountChangedPreparedManifoldCount put: preparation pointCountChangedManifoldCount;
		at: #pointOrderChangedPreparedManifoldCount put: preparation pointOrderChangedManifoldCount;
		at: #separationChangedPreparedManifoldCount put: preparation separationChangedManifoldCount;
		at: #preparedJointConstraintCount put: preparation preparedJointConstraintCount;
		at: #preparedConstraintObjectCount put: preparation preparedObjectCount;
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
