"
I represent a Physics world.

My responsibility is to own authoritative simulation state and advance it through the configured step pipeline. I coordinate bodies, constraints, joints, contacts, Behaviours, telemetry and committed solutions for my member elements.
"
Class {
	#name : 'CFPhysicsWorld',
	#superclass : 'Object',
	#instVars : [ 'owner', 'members', 'membershipProvider', 'bodyStates', 'lengthUnitsPerMetre', 'gravity', 'stepDuration', 'nextBodySequence', 'restitutionThreshold', 'hitEventThreshold', 'maximumContactPushSpeed', 'substepCount', 'contactHertz', 'contactDampingRatio', 'activeContacts', 'calculationContacts', 'lastStepResult', 'stepPipeline', 'mouseJoints', 'motorJoints', 'attractionConstraints', 'repulsionConstraints', 'containmentConstraints', 'boundary', 'distanceJoints', 'revoluteJoints', 'weldJoints', 'prismaticJoints', 'wheelJoints', 'nextMouseJointSequence', 'nextMotorJointSequence', 'nextAttractionSequence', 'nextRepulsionSequence', 'nextDistanceJointSequence', 'nextRevoluteJointSequence', 'nextWeldJointSequence', 'nextPrismaticJointSequence', 'nextWheelJointSequence', 'previousTimeStep', 'warmStarting', 'simulationTime', 'stepNumber', 'behaviours', 'telemetryEnabled', 'telemetryLogger', 'telemetryCapacity', 'telemetryAnnouncer', 'telemetryAnalysisWindowSeconds', 'telemetryStepStatisticsMaximumMicroseconds', 'telemetryAnalysisInBackground', 'backgroundStepping', 'lifetimeGeneration', 'topologyRevision', 'nextSolveTicket', 'activeSolveTicket', 'visualStateConsumers', 'committedVisualState', 'calculationVisualState', 'manifoldGenerator' ],
	#category : 'BVC-Physics-Core',
	#package : 'BVC-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsWorld class >> on: anElement [
	^ self new
		owner: anElement;
		yourself
]

{ #category : 'initialization' }
CFPhysicsWorld >> initialize [
	super initialize.
	members := IdentitySet new.
	bodyStates := IdentityDictionary new.
	nextBodySequence := 1.
	lengthUnitsPerMetre := 100.0.
	gravity := 0 @ 10.0.
	stepDuration := 16 milliseconds.
	restitutionThreshold := 1.0.
	hitEventThreshold := 1.0.
	maximumContactPushSpeed := 3.0.
	substepCount := 4.
	contactHertz := 30.0.
	contactDampingRatio := 10.0.
	activeContacts := #().
	calculationContacts := #().
	mouseJoints := IdentitySet new.
	motorJoints := IdentitySet new.
	attractionConstraints := IdentitySet new.
	repulsionConstraints := IdentitySet new.
	nextMouseJointSequence := 1.
	nextMotorJointSequence := 1.
	nextAttractionSequence := 1.
	nextRepulsionSequence := 1.
	nextDistanceJointSequence := 1.
	nextRevoluteJointSequence := 1.
	nextWeldJointSequence := 1.
	nextPrismaticJointSequence := 1.
	nextWheelJointSequence := 1.
	previousTimeStep := nil.
	warmStarting := true.
	simulationTime := 0.0.
	stepNumber := 0.
	behaviours := OrderedCollection new.
	telemetryEnabled := false.
	telemetryLogger := nil.
	telemetryCapacity := 3600.
	telemetryAnalysisWindowSeconds := 5.
	telemetryStepStatisticsMaximumMicroseconds := nil.
	telemetryAnalysisInBackground := false.
	backgroundStepping := false.
	telemetryAnnouncer := Announcer new.
	lifetimeGeneration := 1.
	topologyRevision := 0.
	nextSolveTicket := 1.
	activeSolveTicket := nil.
	visualStateConsumers := 0.
	committedVisualState := CFPhysicsWorldVisualState new.
	calculationVisualState := CFPhysicsWorldVisualState new.
	containmentConstraints := IdentitySet new.
	boundary := CFPhysicsWorldBoundary new.
	distanceJoints := IdentitySet new.
	revoluteJoints := IdentitySet new.
	weldJoints := IdentitySet new.
	prismaticJoints := IdentitySet new.
	wheelJoints := IdentitySet new.
	manifoldGenerator := CFPhysicsManifoldGenerator new.
	stepPipeline := CFPhysicsStepPipeline manifoldGenerator: manifoldGenerator
]


{ #category : 'accessing' }
CFPhysicsWorld >> manifoldGenerator [ ^ manifoldGenerator ]

{ #category : 'accessing' }
CFPhysicsWorld >> owner [ ^ owner ]

{ #category : 'accessing' }
CFPhysicsWorld >> owner: anElement [
	owner == anElement ifTrue: [ ^ self ].
	(self respondsTo: #physicsOwnerWillChange) ifTrue: [
		self physicsOwnerWillChange ].
	owner := anElement
]

{ #category : 'lifecycle' }
CFPhysicsWorld >> release [
	self invalidateLifetime.
	"Release every resource owned by this world. My owner remains structurally
	unchanged; its Physics facade removes the world association separately."
	self telemetryEnabled: false.
	telemetryLogger := nil.
	behaviours copy do: [ :each | each remove ].
	mouseJoints copy do: [ :each | self removeMouseJoint: each ].
	motorJoints copy do: [ :each | self removeMotorJoint: each ].
	attractionConstraints copy do: [ :each | self removeAttractionConstraint: each ].
	repulsionConstraints copy do: [ :each | self removeRepulsionConstraint: each ].
	distanceJoints copy do: [ :each | self removeDistanceJoint: each ].
	revoluteJoints copy do: [ :each | self removeRevoluteJoint: each ].
	weldJoints copy do: [ :each | self removeWeldJoint: each ].
	prismaticJoints copy do: [ :each | self removePrismaticJoint: each ].
	wheelJoints copy do: [ :each | self removeWheelJoint: each ].
	containmentConstraints copy do: [ :each | self removeContainmentConstraint: each ].
	bodyStates keys do: [ :each |
		each existingPhysics ifNotNil: [ :physics |
			physics retireBodyFromWorld: self ] ].
	bodyStates removeAll.
	members removeAll.
	activeContacts := #().
	calculationContacts := #().
	membershipProvider := nil.
	self owner: nil.
	^ self
]

{ #category : 'units' }
CFPhysicsWorld >> lengthUnitsPerMetre [
	"Number of physics length units representing one metre.

	The default is 100. Changing this value affects conversion of
	metre-based world configuration into simulation units when each state
	is captured. Existing body positions, shapes and transforms are not
	modified. Mondrian canvas scaling is presentation-only and does not
	change this value."
	^ lengthUnitsPerMetre
]

{ #category : 'units' }
CFPhysicsWorld >> lengthUnitsPerMetre: aNumber [
	"Set the number of physics length units representing one metre.

	The supplied value must be greater than zero. The new scale is used by
	the next captured simulation state; no stored configuration values need
	to be rewritten."
	self assert: (aNumber > 0).
	lengthUnitsPerMetre := aNumber asFloat
]

{ #category : 'units' }
CFPhysicsWorld >> lengthUnitsForMetres: aNumber [
	"Convert a length specified in metres into physics length units."
	^ aNumber * lengthUnitsPerMetre
]

{ #category : 'units' }
CFPhysicsWorld >> metresForLengthUnits: aNumber [
	"Convert a length specified in physics length units into metres."
	^ aNumber / lengthUnitsPerMetre
]

{ #category : 'units' }
CFPhysicsWorld >> accelerationUnitsForMetresPerSecondSquared: aPoint [
	"Convert an acceleration vector specified in metres per second squared
	into physics length units per second squared."
	^ aPoint * lengthUnitsPerMetre
]

{ #category : 'accessing' }
CFPhysicsWorld >> gravity [
	"Gravitational acceleration.

	The value is specified in metres per second squared. For Earth-like
	gravity use, for example:

		world gravity: 0 @ 9.81

	It is converted into physics length units when a simulation state is
	captured."
	^ gravity
]

{ #category : 'accessing' }
CFPhysicsWorld >> gravity: aPoint [
	"Set gravitational acceleration. The supplied vector is specified in
	metres per second squared, for example 0 @ 9.81."
	gravity := aPoint
]

{ #category : 'accessing' }
CFPhysicsWorld >> stepDuration [ ^ stepDuration ]

{ #category : 'accessing' }
CFPhysicsWorld >> stepDuration: aDuration [ stepDuration := aDuration ]

{ #category : 'solver configuration' }
CFPhysicsWorld >> restitutionThreshold [
	"Minimum collision speed at which restitution is applied.

	The value is specified in metres per second. For example:

		world restitutionThreshold: 1.0

	It is converted into physics length units per second when a simulation
	state is captured."
	^ restitutionThreshold
]

{ #category : 'solver configuration' }
CFPhysicsWorld >> restitutionThreshold: aNumber [
	"Set the minimum collision speed for restitution. The supplied value is
	specified in metres per second."
	restitutionThreshold := aNumber asFloat max: 0.0
]

{ #category : 'solver configuration' }
CFPhysicsWorld >> maximumContactPushSpeed [
	"Maximum penetration recovery speed.

	The value is specified in metres per second. For example:

		world maximumContactPushSpeed: 3.0

	It is converted into physics length units per second when a simulation
	step is produced."
	^ maximumContactPushSpeed
]

{ #category : 'solver configuration' }
CFPhysicsWorld >> maximumContactPushSpeed: aNumber [
	"Set the maximum penetration recovery speed. The supplied value is
	specified in metres per second."
	maximumContactPushSpeed := aNumber asFloat max: 0.0
]

{ #category : 'solver configuration' }
CFPhysicsWorld >> substepCount [ ^ substepCount ]

{ #category : 'solver configuration' }
CFPhysicsWorld >> substepCount: anInteger [ substepCount := anInteger max: 1 ]

{ #category : 'solver configuration' }
CFPhysicsWorld >> contactHertz [ ^ contactHertz ]

{ #category : 'solver configuration' }
CFPhysicsWorld >> contactHertz: aNumber [ contactHertz := aNumber asFloat max: 0.0 ]

{ #category : 'solver configuration' }
CFPhysicsWorld >> contactDampingRatio [ ^ contactDampingRatio ]

{ #category : 'solver configuration' }
CFPhysicsWorld >> contactDampingRatio: aNumber [ contactDampingRatio := aNumber asFloat max: 0.0 ]


{ #category : 'solver configuration' }
CFPhysicsWorld >> warmStarting [ ^ warmStarting ]

{ #category : 'solver configuration' }
CFPhysicsWorld >> warmStarting: aBoolean [ warmStarting := aBoolean ]

{ #category : 'pipeline' }
CFPhysicsWorld >> stepPipeline [ ^ stepPipeline ]

{ #category : 'pipeline' }
CFPhysicsWorld >> stepPipeline: aStepPipeline [ stepPipeline := aStepPipeline ]

{ #category : 'pipeline' }
CFPhysicsWorld >> lastStepResult [ ^ lastStepResult ]


{ #category : 'collision' }
CFPhysicsWorld >> activeContacts [ ^ activeContacts ]

{ #category : 'collision' }
CFPhysicsWorld >> endedContacts [
	^ lastStepResult
		ifNil: [ #() ]
		ifNotNil: [ lastStepResult endedContacts ]
]

{ #category : 'body states' }
CFPhysicsWorld >> bodyStateFor: anElement [
	^ bodyStates at: anElement ifAbsent: [ nil ]
]

{ #category : 'body states' }
CFPhysicsWorld >> bodyStatesInOrder [
	^ bodyStates values sorted: [ :first :second |
		first sequence < second sequence ]
]

{ #category : 'body states' }
CFPhysicsWorld >> registerBodyFor: anElement [
	| body |
	body := anElement physics ensureBodyInWorld: self.
	self invalidateTopology.
	body sequence: nextBodySequence.
	nextBodySequence := nextBodySequence + 1.
	^ body
]

{ #category : 'membership' }
CFPhysicsWorld >> members [ ^ members asArray ]

{ #category : 'membership' }
CFPhysicsWorld >> membershipProvider [
	^ membershipProvider
]

{ #category : 'membership' }
CFPhysicsWorld >> membershipProvider: aCollectionOrProvider [
	"A collection or zero-argument block that supplies exactly the elements that
	should become bodies. Nil retains the default recursive membership of my owner."
	membershipProvider := aCollectionOrProvider.
	self synchroniseMembership.
	^ self
]

{ #category : 'testing' }
CFPhysicsWorld >> includes: anElement [ ^ members includes: anElement ]

{ #category : 'membership' }
CFPhysicsWorld >> collectMembersFrom: anElement into: aSet [
	| physics |
	physics := anElement physics.
	(physics world == self and: [ physics isExcludedFromWorld not ])
		ifTrue: [ aSet add: anElement ].
	physics isWorld ifTrue: [ ^ self ].
	anElement children do: [ :each |
		self collectMembersFrom: each into: aSet ]
]

{ #category : 'membership' }
CFPhysicsWorld >> collectProvidedMembersInto: aSet [
	membershipProvider value do: [ :each |
		| physics |
		physics := each physics.
		(physics world == self and: [ physics isExcludedFromWorld not ])
			ifTrue: [ aSet add: each ] ]
]

{ #category : 'membership' }
CFPhysicsWorld >> synchroniseMembership [
	| currentMembers |
	currentMembers := IdentitySet new.
	membershipProvider
		ifNil: [ owner children do: [ :each |
			self collectMembersFrom: each into: currentMembers ] ]
		ifNotNil: [ self collectProvidedMembersInto: currentMembers ].
	self retireBodiesAbsentFrom: currentMembers.
	currentMembers do: [ :each |
		bodyStates at: each ifAbsentPut: [ self registerBodyFor: each ] ].
	members := currentMembers.
	^ members
]

{ #category : 'membership' }
CFPhysicsWorld >> retireBodiesAbsentFrom: currentMembers [
	| retiredElements |
	retiredElements := bodyStates keys reject: [ :each | currentMembers includes: each ].
	retiredElements ifNotEmpty: [ self invalidateTopology ].
	retiredElements do: [ :each |
		| body |
		body := bodyStates removeKey: each.
		each physics retireBodyFromWorld: self.
		self removeAttractionsUsingBody: body.
		self removeRepulsionsUsingBody: body.
		self removeMouseJointsUsingBody: body.
		self removeDistanceJointsUsingBody: body.
		self removeRevoluteJointsUsingBody: body.
		self removeWeldJointsUsingBody: body.
		self removePrismaticJointsUsingBody: body.
		self removeWheelJointsUsingBody: body.
		self removeContainmentsUsingBody: body.
		activeContacts := activeContacts reject: [ :contact |
			contact firstBody == body or: [ contact secondBody == body ] ].
		calculationContacts := calculationContacts reject: [ :contact |
			contact firstBody == body or: [ contact secondBody == body ] ] ]
]




{ #category : 'behaviours' }
CFPhysicsWorld >> behaviours [
	^ behaviours copy
]

{ #category : 'behaviours' }
CFPhysicsWorld >> addBehaviour: aBehaviour [
	(behaviours identityIncludes: aBehaviour) ifFalse: [
		behaviours add: aBehaviour ].
	^ aBehaviour
]

{ #category : 'behaviours' }
CFPhysicsWorld >> removeBehaviour: aBehaviour [
	behaviours remove: aBehaviour ifAbsent: [ ].
	^ aBehaviour
]

{ #category : 'behaviours' }
CFPhysicsWorld >> retireInvalidBehaviours [
	behaviours copy do: [ :each |
		each belongsToWorld ifFalse: [ each remove ] ]
]

{ #category : 'behaviours' }
CFPhysicsWorld >> updateBehavioursForStep: aPhysicsStep [
	behaviours copy do: [ :each |
		each isRemoved ifFalse: [
			each updateForStep: aPhysicsStep ] ]
]

{ #category : 'accessing - stepping' }
CFPhysicsWorld >> backgroundStepping [
	^ backgroundStepping
]

{ #category : 'accessing - stepping' }
CFPhysicsWorld >> backgroundStepping: aBoolean [
	backgroundStepping := aBoolean
]

{ #category : 'simulation identity' }
CFPhysicsWorld >> simulationTime [
	^ simulationTime
]

{ #category : 'simulation identity' }
CFPhysicsWorld >> stepNumber [
	^ stepNumber
]

{ #category : 'stepping' }
CFPhysicsWorld >> newStep [
	| currentTimeStep step |
	currentTimeStep := stepDuration asMilliSeconds / 1000.0.
	step := CFPhysicsStep
		timeStep: currentTimeStep
		substeps: substepCount
		contactHertz: contactHertz
		dampingRatio: contactDampingRatio.
	step
		simulationTime: simulationTime;
		stepNumber: stepNumber + 1;
		maximumContactPushSpeed: (self lengthUnitsForMetres: maximumContactPushSpeed);
		hitEventThreshold: (self lengthUnitsForMetres: hitEventThreshold);
		speculativeDistance: (self lengthUnitsForMetres: 0.02);
		broadphaseAABBMargin: (self lengthUnitsForMetres: 0.05);
		warmStartRatio: (warmStarting
		ifFalse: [ 0.0 ]
		ifTrue: [ previousTimeStep
			ifNil: [ 1.0 ]
			ifNotNil: [ previousTimeStep = 0.0
				ifTrue: [ 0.0 ]
				ifFalse: [ currentTimeStep / previousTimeStep ] ] ]).
	^ step
]

{ #category : 'stepping' }
CFPhysicsWorld >> step [
	telemetryEnabled ifTrue: [ ^ self stepWithTelemetry ].
	^ self stepWithoutTelemetry
]

{ #category : 'private - stepping' }
CFPhysicsWorld >> stepWithoutTelemetry [
	| state solution |
	state := self captureState.
	solution := stepPipeline solve: state.
	^ self commit: solution
]


{ #category : 'private - stepping' }
CFPhysicsWorld >> captureStateIfIdle [
	self hasSolveInFlight ifTrue: [ ^ nil ].
	^ self captureState
]

{ #category : 'private - stepping' }
CFPhysicsWorld >> captureState [
	self synchroniseForStateCapture.
	^ self captureStateAfterSynchronisation
]

{ #category : 'private - stepping' }
CFPhysicsWorld >> synchroniseForStateCapture [
	self synchroniseMembership.
	self retireInvalidBehaviours
]

{ #category : 'private - stepping' }
CFPhysicsWorld >> captureStateAfterSynchronisation [
	| bodies step explicitlyContainedBodies capturedBodyStates orderedBodyStates capturedJoints index solveTicket |
	bodies := self bodyStatesInOrder.
	bodies do: #beginStep.
	step := self newStep.
	self updateBehavioursForStep: step.
	self prepareAttractionConstraintsForStep: step timeStep.
	self prepareRepulsionConstraintsForStep: step timeStep.
	explicitlyContainedBodies := self prepareContainmentConstraintsForStep.
	capturedBodyStates := IdentityDictionary new.
	orderedBodyStates := Array new: bodies size.
	capturedJoints := self joints collect: #capturedForStep.
	index := 0.
	bodies do: [ :body |
		| bodyState |
		bodyState := CFPhysicsBodyStepState on: body.
		capturedBodyStates at: body put: bodyState.
		orderedBodyStates at: (index := index + 1) put: bodyState ].
	solveTicket := self beginSolveTicket.
	^ CFPhysicsWorldState new
		world: self;
		lifetimeGeneration: lifetimeGeneration;
		topologyRevision: topologyRevision;
		solveTicket: solveTicket;
		bodies: bodies;
		bodyStates: capturedBodyStates;
		orderedBodyStates: orderedBodyStates;
		contacts: activeContacts;
		calculationContacts: calculationContacts;
		joints: capturedJoints;
		collisionSuppressedBodyPairs: self collisionSuppressedBodyPairs;
		step: step;
		gravity: (self accelerationUnitsForMetresPerSecondSquared: gravity);
		restitutionThreshold: (self lengthUnitsForMetres: restitutionThreshold);
		explicitlyContainedBodies: explicitlyContainedBodies;
		calculationVisualState: (visualStateConsumers > 0
			ifTrue: [ calculationVisualState ]
			ifFalse: [ nil ]);
		yourself
]

{ #category : 'private - stepping' }
CFPhysicsWorld >> commit: aWorldSolution [
	| pipelineResult step previousCommittedContacts |
	(self canCommit: aWorldSolution) ifFalse: [
		self rejectTelemetrySolveTicket: aWorldSolution solveTicket.
		^ nil ].
	pipelineResult := aWorldSolution pipelineResult.
	step := pipelineResult step.
	pipelineResult commitBodyStates.
	pipelineResult commitJointConstraints.
	previousCommittedContacts := activeContacts.
	activeContacts := pipelineResult activeContacts.
	calculationContacts := previousCommittedContacts.
	lastStepResult := pipelineResult.
	self applyDefaultBoundaryExcept: aWorldSolution explicitlyContainedBodies.
	previousTimeStep := step timeStep.
	simulationTime := simulationTime + step timeStep.
	stepNumber := step stepNumber.
	(visualStateConsumers > 0 and: [ aWorldSolution visualState notNil ]) ifTrue: [
		| previousVisualState |
		previousVisualState := committedVisualState.
		committedVisualState := aWorldSolution visualState.
		calculationVisualState := previousVisualState ].
	activeSolveTicket := nil.
	self commitTelemetrySolveTicket: aWorldSolution solveTicket.
	^ pipelineResult
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> stepWithTelemetry [
	^ ProcessTelemetry
		rootTimeSync: [ 'Physics step' ]
		during: [
			ProcessTelemetry
				profile: [ self stepRecordingTelemetry ]
				executing: [ :run |
					| result |
					result := run value.
					self telemetryDataForStepResult: result ]
				as: #physicsFrame ]
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> stepRecordingTelemetry [
	| state solution |
	ProcessTelemetry time: [ 'Membership synchronisation' ] during: [
		self synchroniseForStateCapture ].
	state := ProcessTelemetry time: [ 'Preparation' ] during: [
		self captureStateAfterSynchronisation ].
	solution := ProcessTelemetry time: [ 'Pipeline' ] during: [
		stepPipeline solveWithTelemetry: state ].
	^ ProcessTelemetry time: [ 'Boundary' ] during: [
		self commit: solution ]
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> telemetryDataForStepResult: aStepResult [
	| solvedIslands |
	solvedIslands := aStepResult islands select: [ :island |
		island dynamicBodies anySatisfy: #isAwake ].
	^ Dictionary new
		at: #physicsWorld put: self;
		at: #kind put: #step;
		at: #stepNumber put: stepNumber;
		at: #simulationTime put: simulationTime;
		at: #bodyCount put: bodyStates size;
		at: #activeBodyCount put: (bodyStates values count: #isAwake);
		at: #sleepingBodyCount put: (bodyStates values count: [ :each | each isAwake not ]);
		at: #contactCount put: activeContacts size;
		at: #pairFinderEntryCount put: self pairFinderMeasurements entryCount;
		at: #pairFinderComparisonCount put: self pairFinderMeasurements comparisonCount;
		at: #pairFinderAcceptedPairCount put: self pairFinderMeasurements acceptedPairCount;
		at: #pairFinderMaximumActiveCount put: self pairFinderMeasurements maximumActiveCount;
		at: #broadphaseProxyCount put: self pairFinderMeasurements proxyCount;
		at: #broadphaseMovedProxyCount put: self pairFinderMeasurements movedProxyCount;
		at: #broadphaseQueryVisitCount put: self pairFinderMeasurements queryVisitCount;
		at: #constraintCount put: aStepResult constraints size;
		at: #jointCount put: self joints size;
		at: #islandCount put: aStepResult islands size;
		at: #solvedIslandCount put: solvedIslands size;
		at: #largestSolvedIslandBodyCount put: (self largestBodyCountIn: solvedIslands);
		at: #largestSolvedIslandDynamicBodyCount put: (self largestDynamicBodyCountIn: solvedIslands);
		at: #largestSolvedIslandConstraintCount put: (self largestConstraintCountIn: solvedIslands);
		at: #solvedIslandConstraintCount put: (solvedIslands inject: 0 into: [ :total :island | total + island constraints size ]);
		at: #solverContactConstraintCount put: aStepResult solver contactConstraintCount;
		at: #solverContactPointCount put: aStepResult solver contactPointCount;
		at: #solverWarmStartedContactPointCount put: aStepResult solver warmStartedContactPointCount;
		at: #solverRestitutionCandidatePointCount put: aStepResult solver restitutionCandidatePointCount;
		at: #solverJointConstraintCount put: aStepResult solver jointConstraintCount;
		at: #solverDistanceJointConstraintCount put: aStepResult solver distanceJointConstraintCount;
		at: #solverPrismaticJointConstraintCount put: aStepResult solver prismaticJointConstraintCount;
		at: #solverRevoluteJointConstraintCount put: aStepResult solver revoluteJointConstraintCount;
		at: #solverWeldJointConstraintCount put: aStepResult solver weldJointConstraintCount;
		at: #preparedContactConstraintCount put: self constraintPreparationMeasurements preparedContactConstraintCount;
		at: #continuedPreparedContactConstraintCount put: self constraintPreparationMeasurements continuedContactConstraintCount;
		at: #beganPreparedContactConstraintCount put: self constraintPreparationMeasurements beganContactConstraintCount;
		at: #preparedContactPointCount put: self constraintPreparationMeasurements preparedContactPointCount;
		at: #reusablePreparedContactPointCount put: self constraintPreparationMeasurements reusableContactPointCount;
		at: #newPreparedContactPointCount put: self constraintPreparationMeasurements newContactPointCount;
		at: #stablePreparedManifoldCount put: self constraintPreparationMeasurements stableManifoldCount;
		at: #changedPreparedManifoldCount put: self constraintPreparationMeasurements changedManifoldCount;
		at: #preparedJointConstraintCount put: self constraintPreparationMeasurements preparedJointConstraintCount;
		at: #preparedConstraintObjectCount put: self constraintPreparationMeasurements preparedObjectCount;
		at: #stepResult put: aStepResult;
		yourself
]


{ #category : 'private - telemetry' }
CFPhysicsWorld >> pairFinderMeasurements [
	^ (stepPipeline stageOfType: CFPhysicsPairFinderStage) pairFinder
]


{ #category : 'private - telemetry' }
CFPhysicsWorld >> constraintPreparationMeasurements [
	^ stepPipeline stageOfType: CFPhysicsConstraintPreparationStage
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> largestBodyCountIn: islands [
	^ islands
		ifEmpty: [ 0 ]
		ifNotEmpty: [ (islands collect: [ :island | island bodies size ]) max ]
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> largestDynamicBodyCountIn: islands [
	^ islands
		ifEmpty: [ 0 ]
		ifNotEmpty: [ (islands collect: [ :island | island dynamicBodies size ]) max ]
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> largestConstraintCountIn: islands [
	^ islands
		ifEmpty: [ 0 ]
		ifNotEmpty: [ (islands collect: [ :island | island constraints size ]) max ]
]

{ #category : 'telemetry' }
CFPhysicsWorld >> telemetryEnabled [
	^ telemetryEnabled
]

{ #category : 'telemetry' }
CFPhysicsWorld >> telemetryEnabled: aBoolean [
	telemetryEnabled = aBoolean ifTrue: [ ^ self ].
	telemetryEnabled := aBoolean.
	aBoolean ifTrue: [ self startTelemetry ] ifFalse: [ self stopTelemetry ].
	self announceTelemetryChanged
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> ensureTelemetryLogger [
	telemetryLogger ifNil: [
		telemetryLogger := CFPhysicsTelemetryLogger on: self.
		telemetryLogger capacity: telemetryCapacity ].
	^ telemetryLogger
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> startTelemetry [
	ProcessTelemetry defaultTelemetryClass == MemoryTelemetry ifFalse: [
		ProcessTelemetry defaultTelemetryClass: MemoryTelemetry ].
	self ensureTelemetryLogger start
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> stopTelemetry [
	telemetryLogger ifNotNil: [ telemetryLogger stop ]
]


{ #category : 'telemetry' }
CFPhysicsWorld >> telemetryAnnouncer [
	^ telemetryAnnouncer
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> announceTelemetryChanged [
	telemetryAnnouncer announce: Announcement new
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> hasTelemetryLogger [
	^ telemetryLogger notNil
]

{ #category : 'telemetry' }
CFPhysicsWorld >> telemetryRecordings [
	telemetryLogger ifNil: [ ^ #() ].
	^ telemetryLogger recordings asArray
]

{ #category : 'telemetry' }
CFPhysicsWorld >> telemetryCapacity [
	^ telemetryCapacity
]

{ #category : 'telemetry' }
CFPhysicsWorld >> telemetryCapacity: anInteger [
	telemetryCapacity := anInteger max: 1.
	telemetryLogger ifNotNil: [ telemetryLogger capacity: telemetryCapacity ]
]




{ #category : 'telemetry' }
CFPhysicsWorld >> telemetryAnalysisInBackground [
	^ telemetryAnalysisInBackground
]

{ #category : 'telemetry' }
CFPhysicsWorld >> telemetryAnalysisInBackground: aBoolean [
	telemetryAnalysisInBackground := aBoolean
]

{ #category : 'telemetry' }
CFPhysicsWorld >> telemetryAnalysisWindowSeconds [
	^ telemetryAnalysisWindowSeconds
]

{ #category : 'telemetry' }
CFPhysicsWorld >> telemetryAnalysisWindowSeconds: aNumber [
	telemetryAnalysisWindowSeconds := aNumber max: 1.
	telemetryStepStatisticsMaximumMicroseconds := nil.
	self announceTelemetryChanged
]

{ #category : 'telemetry' }
CFPhysicsWorld >> telemetryStepStatisticsMaximumMicrosecondsFor: measuredMaximum [
	| proposedMaximum |
	proposedMaximum := ((((measuredMaximum max: 1) * 1.15) / 1000.0) ceiling * 1000) max: 1000.
	telemetryStepStatisticsMaximumMicroseconds := telemetryStepStatisticsMaximumMicroseconds
		ifNil: [ proposedMaximum ]
		ifNotNil: [ :currentMaximum | currentMaximum max: proposedMaximum ].
	^ telemetryStepStatisticsMaximumMicroseconds
]

{ #category : 'telemetry' }
CFPhysicsWorld >> resetTelemetryStepStatisticsScale [
	telemetryStepStatisticsMaximumMicroseconds := nil
]

{ #category : 'telemetry' }
CFPhysicsWorld >> latestTelemetryRecording [
	^ self telemetryRecordings ifEmpty: [ nil ] ifNotEmpty: [ :recordings | recordings last ]
]

{ #category : 'telemetry' }
CFPhysicsWorld >> resetTelemetry [
	telemetryLogger ifNotNil: [ telemetryLogger reset ].
	self resetTelemetryStepStatisticsScale.
	self announceTelemetryChanged
]

{ #category : 'stepping' }
CFPhysicsWorld >> step: aPositiveInteger [
	aPositiveInteger timesRepeat: [ self step ].
	^ lastStepResult
]



{ #category : 'sleeping' }
CFPhysicsWorld >> sleepConfiguration [ ^ stepPipeline sleepConfiguration ]


{ #category : 'sleeping' }
CFPhysicsWorld >> sleepConfiguration: aConfiguration [ stepPipeline sleepConfiguration: aConfiguration ]

{ #category : 'sleeping' }
CFPhysicsWorld >> linearSleepVelocityThreshold [ ^ self sleepConfiguration linearVelocityThreshold ]

{ #category : 'sleeping' }
CFPhysicsWorld >> linearSleepVelocityThreshold: aNumber [ self sleepConfiguration linearVelocityThreshold: aNumber ]

{ #category : 'sleeping' }
CFPhysicsWorld >> angularSleepVelocityThreshold [ ^ self sleepConfiguration angularVelocityThreshold ]

{ #category : 'sleeping' }
CFPhysicsWorld >> angularSleepVelocityThreshold: aNumber [ self sleepConfiguration angularVelocityThreshold: aNumber ]

{ #category : 'sleeping' }
CFPhysicsWorld >> timeToSleep [ ^ self sleepConfiguration timeToSleep ]

{ #category : 'sleeping' }
CFPhysicsWorld >> timeToSleep: aNumber [ self sleepConfiguration timeToSleep: aNumber ]

{ #category : 'sleeping' }
CFPhysicsWorld >> wakeAll [
	bodyStates valuesDo: [ :each | each wake ]
]

{ #category : 'events' }
CFPhysicsWorld >> hitEventThreshold [
	"Minimum collision approach speed required to produce a hit event.

	The value is specified in metres per second. For example:

		world hitEventThreshold: 1.0

	It is converted into physics length units per second when a simulation
	step is produced."
	^ hitEventThreshold
]

{ #category : 'events' }
CFPhysicsWorld >> hitEventThreshold: aNumber [
	"Set the minimum collision approach speed for hit events. The supplied
	value is specified in metres per second."
	hitEventThreshold := aNumber asFloat max: 0.0
]

{ #category : 'events' }
CFPhysicsWorld >> hitEvents [
	^ lastStepResult ifNil: [ #() ] ifNotNil: [ lastStepResult hitEvents ]
]


{ #category : 'mouse joints' }
CFPhysicsWorld >> mouseJoints [
	^ mouseJoints asArray sorted: [ :first :second | first orderingKey < second orderingKey ]
]

{ #category : 'mouse joints' }
CFPhysicsWorld >> addMouseJoint: aJoint [
	aJoint bodyB world == self ifFalse: [ self error: 'Mouse joint body must belong to this physics world' ].
	self invalidateTopology.
	aJoint sequence: nextMouseJointSequence.
	nextMouseJointSequence := nextMouseJointSequence + 1.
	mouseJoints add: aJoint.
	aJoint wakeBodies.
	^ aJoint
]

{ #category : 'mouse joints' }
CFPhysicsWorld >> removeMouseJoint: aJoint [
	(mouseJoints includes: aJoint) ifTrue: [
		self invalidateTopology.
		aJoint release.
		mouseJoints remove: aJoint ].
	^ aJoint
]

{ #category : 'mouse joints' }
CFPhysicsWorld >> removeMouseJointsUsingBody: aBody [
	(mouseJoints select: [ :each | each includesBody: aBody ]) copy do: [ :each | self removeMouseJoint: each ]
]



{ #category : 'motor joints' }
CFPhysicsWorld >> motorJoints [ ^ motorJoints asArray sorted: [ :first :second | first orderingKey < second orderingKey ] ]
{ #category : 'motor joints' }
CFPhysicsWorld >> addMotorJoint: aJoint [
	(aJoint bodyA world == self and: [ aJoint bodyB world == self ]) ifFalse: [ self error: 'Motor joint bodies must belong to this physics world' ].
	self invalidateTopology. aJoint sequence: nextMotorJointSequence. nextMotorJointSequence := nextMotorJointSequence + 1. motorJoints add: aJoint. aJoint wakeBodies. ^ aJoint
]
{ #category : 'motor joints' }
CFPhysicsWorld >> removeMotorJoint: aJoint [ (motorJoints includes: aJoint) ifTrue: [ self invalidateTopology. aJoint release. motorJoints remove: aJoint ]. ^ aJoint ]
{ #category : 'motor joints' }
CFPhysicsWorld >> removeMotorJointsUsingBody: aBody [ (motorJoints select: [ :each | each includesBody: aBody ]) copy do: [ :each | self removeMotorJoint: each ] ]

{ #category : 'attraction interaction' }
CFPhysicsWorld >> attractions [
	^ attractionConstraints asArray sorted: [ :first :second |
		first orderingKey < second orderingKey ]
]

{ #category : 'attraction interaction' }
CFPhysicsWorld >> addAttractionConstraint: aConstraint [
	aConstraint endpointPair world == self
		ifFalse: [ self error: 'Attraction endpoints must belong to this physics world' ].
	aConstraint sequence: nextAttractionSequence.
	nextAttractionSequence := nextAttractionSequence + 1.
	attractionConstraints add: aConstraint.
	^ aConstraint
]

{ #category : 'attraction interaction' }
CFPhysicsWorld >> attractionsUsingBody: aBodyState [
	^ self attractions select: [ :each | each includesBody: aBodyState ]
]

{ #category : 'attraction interaction' }
CFPhysicsWorld >> removeAttractionConstraint: aConstraint [
	(attractionConstraints includes: aConstraint) ifTrue: [
		aConstraint release.
		attractionConstraints remove: aConstraint ].
	^ aConstraint
]

{ #category : 'attraction interaction' }
CFPhysicsWorld >> removeAttractionsUsingBody: aBodyState [
	(attractionConstraints select: [ :each | each includesBody: aBodyState ]) copy do: [ :each |
		self removeAttractionConstraint: each ]
]

{ #category : 'attraction interaction' }
CFPhysicsWorld >> prepareAttractionConstraintsForStep: seconds [
	attractionConstraints copy do: [ :each |
		each isActive
			ifTrue: [ each prepareForStep: seconds ]
			ifFalse: [ attractionConstraints remove: each ifAbsent: [ ] ] ]
]


{ #category : 'repulsion interaction' }
CFPhysicsWorld >> repulsions [
	^ repulsionConstraints asArray sorted: [ :first :second |
		first orderingKey < second orderingKey ]
]

{ #category : 'repulsion interaction' }
CFPhysicsWorld >> addRepulsionConstraint: aConstraint [
	aConstraint endpointPair world == self
		ifFalse: [ self error: 'Repulsion endpoints must belong to this physics world' ].
	aConstraint sequence: nextRepulsionSequence.
	nextRepulsionSequence := nextRepulsionSequence + 1.
	repulsionConstraints add: aConstraint.
	^ aConstraint
]

{ #category : 'repulsion interaction' }
CFPhysicsWorld >> repulsionsUsingBody: aBodyState [
	^ self repulsions select: [ :each | each includesBody: aBodyState ]
]

{ #category : 'repulsion interaction' }
CFPhysicsWorld >> removeRepulsionConstraint: aConstraint [
	(repulsionConstraints includes: aConstraint) ifTrue: [
		aConstraint release.
		repulsionConstraints remove: aConstraint ].
	^ aConstraint
]

{ #category : 'repulsion interaction' }
CFPhysicsWorld >> removeRepulsionsUsingBody: aBodyState [
	(repulsionConstraints select: [ :each | each includesBody: aBodyState ]) copy do: [ :each |
		self removeRepulsionConstraint: each ]
]

{ #category : 'repulsion interaction' }
CFPhysicsWorld >> prepareRepulsionConstraintsForStep: seconds [
	repulsionConstraints copy do: [ :each |
		each isActive
			ifTrue: [ each prepareForStep: seconds ]
			ifFalse: [ repulsionConstraints remove: each ifAbsent: [ ] ] ]
]


{ #category : 'distance joints' }
CFPhysicsWorld >> springs [
	^ self distanceJoints select: [ :each | each springEnabled ]
]

{ #category : 'distance joints' }
CFPhysicsWorld >> springsUsingBody: aBody [
	^ self springs select: [ :each | each includesBody: aBody ]
]


{ #category : 'distance joints' }
CFPhysicsWorld >> distanceJoints [
	^ distanceJoints asArray sorted: [ :first :second |
		first orderingKey < second orderingKey ]
]

{ #category : 'distance joints' }
CFPhysicsWorld >> addDistanceJoint: aJoint [
	aJoint endpointPair world == self
		ifFalse: [ self error: 'Distance joint endpoints must belong to this physics world' ].
	(aJoint bodyA notNil or: [ aJoint bodyB notNil ])
		ifFalse: [ self error: 'A distance joint requires at least one body endpoint' ].
	self invalidateTopology.
	aJoint sequence: nextDistanceJointSequence.
	nextDistanceJointSequence := nextDistanceJointSequence + 1.
	distanceJoints add: aJoint.
	aJoint wakeBodies.
	^ aJoint
]

{ #category : 'distance joints' }
CFPhysicsWorld >> distanceJointsUsingBody: aBodyState [
	^ self distanceJoints select: [ :each | each includesBody: aBodyState ]
]

{ #category : 'joints' }
CFPhysicsWorld >> joints [
	^ (self mouseJoints, self motorJoints, self distanceJoints, self revoluteJoints, self weldJoints, self prismaticJoints, self wheelJoints) asArray sorted: [ :first :second |
		first orderingKey = second orderingKey
			ifTrue: [ first class name asString < second class name asString ]
			ifFalse: [ first orderingKey < second orderingKey ] ]
]


{ #category : 'collision filtering' }
CFPhysicsWorld >> collisionSuppressedBodyPairs [
	^ (self joints
		select: [ :joint | joint isActive and: [ joint collideConnected not ] ])
		collect: [ :joint | { joint bodyA. joint bodyB } ]
]

{ #category : 'collision filtering' }
CFPhysicsWorld >> jointPreventsCollisionBetween: firstBody and: secondBody [
	^ self joints anySatisfy: [ :joint |
		(joint isActive and: [ joint collideConnected not ]) and: [
			(joint bodyA == firstBody and: [ joint bodyB == secondBody ])
				or: [ joint bodyA == secondBody
					and: [ joint bodyB == firstBody ] ] ] ]
]

{ #category : 'distance joints' }
CFPhysicsWorld >> removeDistanceJoint: aJoint [
	(distanceJoints includes: aJoint) ifTrue: [
		self invalidateTopology.
		aJoint release.
		distanceJoints remove: aJoint ].
	^ aJoint
]

{ #category : 'distance joints' }
CFPhysicsWorld >> removeDistanceJointsUsingBody: aBodyState [
	(distanceJoints select: [ :each | each includesBody: aBodyState ]) copy do: [ :each |
		self removeDistanceJoint: each ]
]

{ #category : 'revolute joints' }
CFPhysicsWorld >> revoluteJoints [
	^ revoluteJoints asArray sorted: [ :first :second |
		first orderingKey < second orderingKey ]
]

{ #category : 'revolute joints' }
CFPhysicsWorld >> addRevoluteJoint: aJoint [
	aJoint endpointPair world == self
		ifFalse: [ self error: 'Revolute joint endpoints must belong to this physics world' ].
	(aJoint bodyA notNil or: [ aJoint bodyB notNil ])
		ifFalse: [ self error: 'A revolute joint requires at least one body endpoint' ].
	self invalidateTopology.
	aJoint sequence: nextRevoluteJointSequence.
	nextRevoluteJointSequence := nextRevoluteJointSequence + 1.
	revoluteJoints add: aJoint.
	aJoint wakeBodies.
	^ aJoint
]

{ #category : 'revolute joints' }
CFPhysicsWorld >> revoluteJointsUsingBody: aBodyState [
	^ self revoluteJoints select: [ :each | each includesBody: aBodyState ]
]

{ #category : 'revolute joints' }
CFPhysicsWorld >> removeRevoluteJoint: aJoint [
	(revoluteJoints includes: aJoint) ifTrue: [
		self invalidateTopology.
		aJoint release.
		revoluteJoints remove: aJoint ].
	^ aJoint
]

{ #category : 'revolute joints' }
CFPhysicsWorld >> removeRevoluteJointsUsingBody: aBodyState [
	(revoluteJoints select: [ :each | each includesBody: aBodyState ]) copy do: [ :each |
		self removeRevoluteJoint: each ]
]

{ #category : 'weld joints' }
CFPhysicsWorld >> weldJoints [
	^ weldJoints asArray sorted: [ :first :second |
		first orderingKey < second orderingKey ]
]

{ #category : 'weld joints' }
CFPhysicsWorld >> addWeldJoint: aJoint [
	aJoint endpointPair world == self
		ifFalse: [ self error: 'Weld joint endpoints must belong to this physics world' ].
	(aJoint bodyA notNil or: [ aJoint bodyB notNil ])
		ifFalse: [ self error: 'A weld joint requires at least one body endpoint' ].
	self invalidateTopology.
	aJoint sequence: nextWeldJointSequence.
	nextWeldJointSequence := nextWeldJointSequence + 1.
	weldJoints add: aJoint.
	aJoint wakeBodies.
	^ aJoint
]

{ #category : 'weld joints' }
CFPhysicsWorld >> weldJointsUsingBody: aBodyState [
	^ self weldJoints select: [ :each | each includesBody: aBodyState ]
]

{ #category : 'weld joints' }
CFPhysicsWorld >> removeWeldJoint: aJoint [
	(weldJoints includes: aJoint) ifTrue: [
		self invalidateTopology.
		aJoint release.
		weldJoints remove: aJoint ].
	^ aJoint
]

{ #category : 'weld joints' }
CFPhysicsWorld >> removeWeldJointsUsingBody: aBodyState [
	(weldJoints select: [ :each | each includesBody: aBodyState ]) copy do: [ :each |
		self removeWeldJoint: each ]
]

{ #category : 'prismatic joints' }
CFPhysicsWorld >> prismaticJoints [
	^ prismaticJoints asArray sorted: [ :first :second |
		first orderingKey < second orderingKey ]
]

{ #category : 'prismatic joints' }
CFPhysicsWorld >> addPrismaticJoint: aJoint [
	aJoint endpointPair world == self
		ifFalse: [ self error: 'Prismatic joint endpoints must belong to this physics world' ].
	(aJoint bodyA notNil or: [ aJoint bodyB notNil ])
		ifFalse: [ self error: 'A prismatic joint requires at least one body endpoint' ].
	self invalidateTopology.
	aJoint sequence: nextPrismaticJointSequence.
	nextPrismaticJointSequence := nextPrismaticJointSequence + 1.
	prismaticJoints add: aJoint.
	aJoint wakeBodies.
	^ aJoint
]

{ #category : 'prismatic joints' }
CFPhysicsWorld >> prismaticJointsUsingBody: aBodyState [
	^ self prismaticJoints select: [ :each | each includesBody: aBodyState ]
]

{ #category : 'prismatic joints' }
CFPhysicsWorld >> removePrismaticJoint: aJoint [
	(prismaticJoints includes: aJoint) ifTrue: [
		self invalidateTopology.
		aJoint release.
		prismaticJoints remove: aJoint ].
	^ aJoint
]

{ #category : 'prismatic joints' }
CFPhysicsWorld >> removePrismaticJointsUsingBody: aBodyState [
	(prismaticJoints select: [ :each | each includesBody: aBodyState ]) copy do: [ :each |
		self removePrismaticJoint: each ]
]

{ #category : 'distance joints' }
CFPhysicsWorld >> wakeDistanceJointsUsingAnchor: anAnchor [
	self wakeJointsUsingAnchor: anAnchor
]

{ #category : 'joints' }
CFPhysicsWorld >> wakeJointsUsingAnchor: anAnchor [
	(self joints select: [ :each | each includesAnchor: anAnchor ]) do: #wakeBodies
]

{ #category : 'joints' }
CFPhysicsWorld >> wakeJointsUsingBody: aBodyState [
	(self joints select: [ :each | each includesBody: aBodyState ]) do: #wakeBodies
]


{ #category : 'containment interaction' }
CFPhysicsWorld >> containmentExtent [
	^ (CFPhysicsShapeState on: owner) extent
]

{ #category : 'containment interaction' }
CFPhysicsWorld >> boundary [
	^ boundary ifNil: [ boundary := CFPhysicsWorldBoundary new ]
]


{ #category : 'containment interaction' }
CFPhysicsWorld >> containmentConstraints [
	^ containmentConstraints asArray sorted: [ :first :second |
		first body sequence < second body sequence ]
]

{ #category : 'containment interaction' }
CFPhysicsWorld >> addContainmentConstraint: aConstraint [
	aConstraint body world == self
		ifFalse: [ self error: 'The contained body must belong to this physics world' ].
	containmentConstraints add: aConstraint.
	^ aConstraint
]

{ #category : 'containment interaction' }
CFPhysicsWorld >> removeContainmentConstraint: aConstraint [
	(containmentConstraints includes: aConstraint) ifTrue: [
		aConstraint release.
		containmentConstraints remove: aConstraint ].
	^ aConstraint
]

{ #category : 'containment interaction' }
CFPhysicsWorld >> removeContainmentsUsingBody: aBodyState [
	(containmentConstraints select: [ :each | each body == aBodyState ]) copy do: [ :each |
		self removeContainmentConstraint: each ]
]

{ #category : 'containment interaction' }
CFPhysicsWorld >> applyDefaultBoundaryExcept: explicitlyContainedBodies [
	| bounds worldBoundary |
	bounds := 0 @ 0 extent: self containmentExtent.
	worldBoundary := self boundary.
	worldBoundary enabled ifTrue: [
		self bodyStatesInOrder do: [ :each |
			(explicitlyContainedBodies includes: each) ifFalse: [
				worldBoundary applyTo: each bounds: bounds ] ] ]
]

{ #category : 'containment interaction' }
CFPhysicsWorld >> prepareContainmentConstraintsForStep [
	| bounds explicitlyContainedBodies |
	bounds := 0 @ 0 extent: self containmentExtent.
	explicitlyContainedBodies := IdentitySet new.
	containmentConstraints copy do: [ :each |
		each isActive
			ifTrue: [
				each prepareForBounds: bounds.
				explicitlyContainedBodies add: each body ]
			ifFalse: [ containmentConstraints remove: each ifAbsent: [ ] ] ].
	self applyDefaultBoundaryExcept: explicitlyContainedBodies.
	^ explicitlyContainedBodies
]


{ #category : 'anchors' }
CFPhysicsWorld >> anchorAt: aPoint [
	^ CFPhysicsWorldAnchor in: self at: aPoint
]


{ #category : 'private - solution identity' }
CFPhysicsWorld >> beginSolveTicket [
	| ticket |
	ticket := nextSolveTicket.
	nextSolveTicket := nextSolveTicket + 1.
	activeSolveTicket := ticket.
	^ ticket
]

{ #category : 'private - solution identity' }
CFPhysicsWorld >> canCommit: aWorldSolution [
	^ aWorldSolution world == self
		and: [ aWorldSolution lifetimeGeneration = lifetimeGeneration
		and: [ aWorldSolution topologyRevision = topologyRevision
		and: [ aWorldSolution solveTicket = activeSolveTicket ] ] ]
]

{ #category : 'private - solution identity' }
CFPhysicsWorld >> invalidateLifetime [
	self rejectTelemetrySolveTicket: activeSolveTicket.
	lifetimeGeneration := lifetimeGeneration + 1.
	activeSolveTicket := nil
]

{ #category : 'private - solution identity' }
CFPhysicsWorld >> invalidateTopology [
	self rejectTelemetrySolveTicket: activeSolveTicket.
	topologyRevision := topologyRevision + 1.
	activeSolveTicket := nil
]

{ #category : 'accessing - solution identity' }
CFPhysicsWorld >> lifetimeGeneration [ ^ lifetimeGeneration ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorld >> topologyRevision [ ^ topologyRevision ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorld >> activeSolveTicket [ ^ activeSolveTicket ]

{ #category : 'testing - solution identity' }
CFPhysicsWorld >> hasSolveInFlight [
	^ activeSolveTicket notNil
]



{ #category : 'private - solution identity' }
CFPhysicsWorld >> abandonActiveSolve [
	self rejectTelemetrySolveTicket: activeSolveTicket.
	activeSolveTicket := nil
]
{ #category : 'private - solution identity' }
CFPhysicsWorld >> abandonSolveTicket: aSolveTicket [
	self rejectTelemetrySolveTicket: aSolveTicket.
	activeSolveTicket = aSolveTicket ifTrue: [
		activeSolveTicket := nil ]
]



{ #category : 'private - telemetry' }
CFPhysicsWorld >> discardDetachedTelemetrySignals [
	telemetryLogger ifNotNil: [ telemetryLogger discardDetachedSignals ]
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> telemetryContextForState: aWorldState [
	^ CFPhysicsStepTelemetryContext world: self state: aWorldState
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> commitTelemetrySolveTicket: aSolveTicket [
	telemetryLogger ifNotNil: [ telemetryLogger commitSolveTicket: aSolveTicket ]
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> rejectTelemetrySolveTicket: aSolveTicket [
	telemetryLogger ifNotNil: [ telemetryLogger rejectSolveTicket: aSolveTicket ]
]


{ #category : 'accessing - visual state' }
CFPhysicsWorld >> committedVisualState [
	^ committedVisualState
]

{ #category : 'accessing - visual state' }
CFPhysicsWorld >> enableVisualState [
	visualStateConsumers = 0 ifTrue: [
		committedVisualState updateFromContacts: activeContacts ].
	visualStateConsumers := visualStateConsumers + 1.
	^ self
]

{ #category : 'accessing - visual state' }
CFPhysicsWorld >> disableVisualState [
	visualStateConsumers := (visualStateConsumers - 1) max: 0.
	visualStateConsumers = 0 ifTrue: [
		committedVisualState clear.
		calculationVisualState clear ].
	^ self
]

{ #category : 'testing' }
CFPhysicsWorld >> visualStateEnabled [
	^ visualStateConsumers > 0
]


{ #category : 'wheel joints' }
CFPhysicsWorld >> wheelJoints [
	^ wheelJoints asArray sorted: [ :first :second |
		first orderingKey < second orderingKey ]
]

{ #category : 'wheel joints' }
CFPhysicsWorld >> addWheelJoint: aJoint [
	aJoint endpointPair world == self
		ifFalse: [ self error: 'Wheel joint endpoints must belong to this physics world' ].
	(aJoint bodyA notNil or: [ aJoint bodyB notNil ])
		ifFalse: [ self error: 'A wheel joint requires at least one body endpoint' ].
	self invalidateTopology.
	aJoint sequence: nextWheelJointSequence.
	nextWheelJointSequence := nextWheelJointSequence + 1.
	wheelJoints add: aJoint.
	aJoint wakeBodies.
	^ aJoint
]

{ #category : 'wheel joints' }
CFPhysicsWorld >> wheelJointsUsingBody: aBodyState [
	^ self wheelJoints select: [ :each | each includesBody: aBodyState ]
]

{ #category : 'wheel joints' }
CFPhysicsWorld >> removeWheelJoint: aJoint [
	(wheelJoints includes: aJoint) ifTrue: [
		self invalidateTopology.
		aJoint release.
		wheelJoints remove: aJoint ].
	^ aJoint
]

{ #category : 'wheel joints' }
CFPhysicsWorld >> removeWheelJointsUsingBody: aBodyState [
	(wheelJoints select: [ :each | each includesBody: aBodyState ]) copy do: [ :each |
		self removeWheelJoint: each ]
]
