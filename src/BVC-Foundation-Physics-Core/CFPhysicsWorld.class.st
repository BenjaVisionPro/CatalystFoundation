"
I am the deterministic Physics simulation owned by one Bloc element.

I own body membership, solver configuration, constraints, contacts and the explicit #step operation. A step synchronises membership and advances the pipeline by one fixed #stepDuration. I do not schedule frames or own visual presentation resources.

Motion-backed presentation and continuous playback are optional integration capabilities supplied by BVC-Foundation-Physics-Motion.
"
Class {
	#name : 'CFPhysicsWorld',
	#superclass : 'Object',
	#instVars : [ 'owner', 'members', 'membershipProvider', 'bodyStates', 'gravity', 'stepDuration', 'nextBodySequence', 'restitutionThreshold', 'substepCount', 'contactHertz', 'contactDampingRatio', 'activeContacts', 'lastStepResult', 'stepPipeline', 'pointerConstraints', 'springConstraints', 'attractionConstraints', 'repulsionConstraints', 'containmentConstraints', 'boundary', 'distanceJoints', 'revoluteJoints', 'fixedJoints', 'railJoints', 'nextSpringSequence', 'nextAttractionSequence', 'nextRepulsionSequence', 'nextDistanceJointSequence', 'nextRevoluteJointSequence', 'nextFixedJointSequence', 'nextRailJointSequence', 'previousTimeStep', 'warmStarting', 'simulationTime', 'stepNumber', 'behaviours', 'telemetryEnabled', 'telemetryLogger', 'telemetryCapacity', 'telemetryAnnouncer', 'telemetryAnalysisWindowSeconds', 'telemetryStepStatisticsMaximumMicroseconds', 'telemetryAnalysisInBackground' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
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
	gravity := 0 @ 1000.
	stepDuration := 16 milliseconds.
	restitutionThreshold := 1.0.
	substepCount := 4.
	contactHertz := 30.0.
	contactDampingRatio := 10.0.
	activeContacts := #().
	pointerConstraints := IdentitySet new.
	springConstraints := IdentitySet new.
	attractionConstraints := IdentitySet new.
	repulsionConstraints := IdentitySet new.
	nextSpringSequence := 1.
	nextAttractionSequence := 1.
	nextRepulsionSequence := 1.
	nextDistanceJointSequence := 1.
	nextRevoluteJointSequence := 1.
	nextFixedJointSequence := 1.
	nextRailJointSequence := 1.
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
	telemetryAnnouncer := Announcer new.
	containmentConstraints := IdentitySet new.
	boundary := CFPhysicsWorldBoundary new.
	distanceJoints := IdentitySet new.
	revoluteJoints := IdentitySet new.
	fixedJoints := IdentitySet new.
	railJoints := IdentitySet new.
	stepPipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsBlocManifoldBuilder
			manifoldBetweenBody: pair firstBody
			andBody: pair secondBody ]
]

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
	"Release every resource owned by this world. My owner remains structurally
	unchanged; its Physics facade removes the world association separately."
	self telemetryEnabled: false.
	telemetryLogger := nil.
	behaviours copy do: [ :each | each remove ].
	pointerConstraints copy do: [ :each | self removePointerConstraint: each ].
	attractionConstraints copy do: [ :each | self removeAttractionConstraint: each ].
	repulsionConstraints copy do: [ :each | self removeRepulsionConstraint: each ].
	springConstraints copy do: [ :each | self removeSpringConstraint: each ].
	distanceJoints copy do: [ :each | self removeDistanceJoint: each ].
	revoluteJoints copy do: [ :each | self removeRevoluteJoint: each ].
	fixedJoints copy do: [ :each | self removeFixedJoint: each ].
	railJoints copy do: [ :each | self removeRailJoint: each ].
	containmentConstraints copy do: [ :each | self removeContainmentConstraint: each ].
	bodyStates keys do: [ :each |
		each existingPhysics ifNotNil: [ :physics |
			physics retireBodyFromWorld: self ] ].
	bodyStates removeAll.
	members removeAll.
	activeContacts := #().
	membershipProvider := nil.
	self owner: nil.
	^ self
]

{ #category : 'accessing' }
CFPhysicsWorld >> gravity [ ^ gravity ]

{ #category : 'accessing' }
CFPhysicsWorld >> gravity: aPoint [ gravity := aPoint ]

{ #category : 'accessing' }
CFPhysicsWorld >> stepDuration [ ^ stepDuration ]

{ #category : 'accessing' }
CFPhysicsWorld >> stepDuration: aDuration [ stepDuration := aDuration ]

{ #category : 'solver configuration' }
CFPhysicsWorld >> restitutionThreshold [ ^ restitutionThreshold ]

{ #category : 'solver configuration' }
CFPhysicsWorld >> restitutionThreshold: aNumber [ restitutionThreshold := aNumber asFloat max: 0.0 ]

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
CFPhysicsWorld >> contacts [ ^ activeContacts ]

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
	(physics owningWorld == self and: [ physics isExcludedFromWorld not ])
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
		(physics owningWorld == self and: [ physics isExcludedFromWorld not ])
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
	(bodyStates keys reject: [ :each | currentMembers includes: each ]) do: [ :each |
		| body |
		body := bodyStates removeKey: each.
		each physics retireBodyFromWorld: self.
		self removeSpringsUsingBody: body.
		self removeAttractionsUsingBody: body.
		self removeRepulsionsUsingBody: body.
		self removeDistanceJointsUsingBody: body.
		self removeRevoluteJointsUsingBody: body.
		self removeFixedJointsUsingBody: body.
		self removeRailJointsUsingBody: body.
		self removeContainmentsUsingBody: body.
		activeContacts := activeContacts reject: [ :contact |
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
		each stillBelongsToWorld ifFalse: [ each remove ] ]
]

{ #category : 'behaviours' }
CFPhysicsWorld >> updateBehavioursForStep: aPhysicsStep [
	behaviours copy do: [ :each |
		each isRemoved ifFalse: [
			each updateForStep: aPhysicsStep ] ]
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
	| bodies step explicitlyContainedBodies |
	bodies := self bodyStatesInOrder.
	bodies do: #beginStep.
	step := self newStep.
	self updateBehavioursForStep: step.
	self prepareAttractionConstraintsForStep: step timeStep.
	self prepareRepulsionConstraintsForStep: step timeStep.
	self prepareSpringConstraintsForStep: step timeStep.
	explicitlyContainedBodies := self prepareContainmentConstraintsForStep.
	self preparePointerConstraintsForStep: step timeStep.
	^ CFPhysicsWorldState new
		bodies: bodies;
		contacts: activeContacts;
		joints: self joints;
		step: step;
		gravity: gravity;
		restitutionThreshold: restitutionThreshold;
		explicitlyContainedBodies: explicitlyContainedBodies;
		yourself
]

{ #category : 'private - stepping' }
CFPhysicsWorld >> commit: aWorldSolution [
	| pipelineResult step |
	pipelineResult := aWorldSolution pipelineResult.
	step := pipelineResult step.
	lastStepResult := pipelineResult.
	activeContacts := pipelineResult activeContacts.
	self applyDefaultBoundaryExcept: aWorldSolution explicitlyContainedBodies.
	previousTimeStep := step timeStep.
	simulationTime := simulationTime + step timeStep.
	stepNumber := step stepNumber.
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
		at: #solverRailJointConstraintCount put: aStepResult solver railJointConstraintCount;
		at: #solverRevoluteJointConstraintCount put: aStepResult solver revoluteJointConstraintCount;
		at: #solverFixedJointConstraintCount put: aStepResult solver fixedJointConstraintCount;
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
CFPhysicsWorld >> hitEventThreshold [ ^ stepPipeline hitEventThreshold ]

{ #category : 'events' }
CFPhysicsWorld >> hitEventThreshold: aNumber [ stepPipeline hitEventThreshold: aNumber ]

{ #category : 'events' }
CFPhysicsWorld >> hitEvents [
	^ lastStepResult ifNil: [ #() ] ifNotNil: [ lastStepResult hitEvents ]
]


{ #category : 'pointer interaction' }
CFPhysicsWorld >> pointerConstraints [
	^ pointerConstraints asArray sorted: [ :first :second |
		first body sequence < second body sequence ]
]

{ #category : 'pointer interaction' }
CFPhysicsWorld >> addPointerConstraint: aConstraint [
	pointerConstraints add: aConstraint.
	^ aConstraint
]

{ #category : 'pointer interaction' }
CFPhysicsWorld >> removePointerConstraint: aConstraint [
	(pointerConstraints includes: aConstraint) ifTrue: [
		aConstraint release.
		pointerConstraints remove: aConstraint ].
	^ aConstraint
]

{ #category : 'pointer interaction' }
CFPhysicsWorld >> preparePointerConstraintsForStep: seconds [
	pointerConstraints copy do: [ :each |
		each isActive
			ifTrue: [ each prepareForStep: seconds ]
			ifFalse: [ pointerConstraints remove: each ifAbsent: [ ] ] ]
]



{ #category : 'attraction interaction' }
CFPhysicsWorld >> attractions [
	^ self attractionConstraints
]

{ #category : 'attraction interaction' }
CFPhysicsWorld >> attractionConstraints [
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
	^ self attractionConstraints select: [ :each | each includesBody: aBodyState ]
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
	^ self repulsionConstraints
]

{ #category : 'repulsion interaction' }
CFPhysicsWorld >> repulsionConstraints [
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
	^ self repulsionConstraints select: [ :each | each includesBody: aBodyState ]
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


{ #category : 'spring interaction' }
CFPhysicsWorld >> springs [
	^ self springConstraints
]

{ #category : 'spring interaction' }
CFPhysicsWorld >> springConstraints [
	^ springConstraints asArray sorted: [ :first :second |
		first orderingKey < second orderingKey ]
]

{ #category : 'spring interaction' }
CFPhysicsWorld >> addSpringConstraint: aConstraint [
	aConstraint endpointPair world == self
		ifFalse: [ self error: 'Spring endpoints must belong to this physics world' ].
	aConstraint sequence: nextSpringSequence.
	nextSpringSequence := nextSpringSequence + 1.
	springConstraints add: aConstraint.
	^ aConstraint
]


{ #category : 'spring interaction' }
CFPhysicsWorld >> springsUsingBody: aBodyState [
	^ self springConstraints select: [ :each | each includesBody: aBodyState ]
]

{ #category : 'spring interaction' }
CFPhysicsWorld >> removeSpringConstraint: aConstraint [
	(springConstraints includes: aConstraint) ifTrue: [
		aConstraint release.
		springConstraints remove: aConstraint ].
	^ aConstraint
]

{ #category : 'spring interaction' }
CFPhysicsWorld >> removeSpringsUsingBody: aBodyState [
	(springConstraints select: [ :each | each includesBody: aBodyState ]) copy do: [ :each |
		self removeSpringConstraint: each ]
]

{ #category : 'spring interaction' }
CFPhysicsWorld >> prepareSpringConstraintsForStep: seconds [
	springConstraints copy do: [ :each |
		each isActive
			ifTrue: [ each prepareForStep: seconds ]
			ifFalse: [ springConstraints remove: each ifAbsent: [ ] ] ]
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
	(aJoint firstBody notNil or: [ aJoint secondBody notNil ])
		ifFalse: [ self error: 'A distance joint requires at least one body endpoint' ].
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
	^ (self distanceJoints, self revoluteJoints, self fixedJoints, self railJoints) asArray sorted: [ :first :second |
		first orderingKey = second orderingKey
			ifTrue: [ first class name asString < second class name asString ]
			ifFalse: [ first orderingKey < second orderingKey ] ]
]

{ #category : 'collision filtering' }
CFPhysicsWorld >> jointPreventsCollisionBetween: firstBody and: secondBody [
	^ self joints anySatisfy: [ :joint |
		(joint isActive and: [ joint collideConnected not ]) and: [
			(joint firstBody == firstBody and: [ joint secondBody == secondBody ])
				or: [ joint firstBody == secondBody
					and: [ joint secondBody == firstBody ] ] ] ]
]

{ #category : 'distance joints' }
CFPhysicsWorld >> removeDistanceJoint: aJoint [
	(distanceJoints includes: aJoint) ifTrue: [
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
	(aJoint firstBody notNil or: [ aJoint secondBody notNil ])
		ifFalse: [ self error: 'A revolute joint requires at least one body endpoint' ].
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
		aJoint release.
		revoluteJoints remove: aJoint ].
	^ aJoint
]

{ #category : 'revolute joints' }
CFPhysicsWorld >> removeRevoluteJointsUsingBody: aBodyState [
	(revoluteJoints select: [ :each | each includesBody: aBodyState ]) copy do: [ :each |
		self removeRevoluteJoint: each ]
]

{ #category : 'fixed joints' }
CFPhysicsWorld >> fixedJoints [
	^ fixedJoints asArray sorted: [ :first :second |
		first orderingKey < second orderingKey ]
]

{ #category : 'fixed joints' }
CFPhysicsWorld >> addFixedJoint: aJoint [
	aJoint endpointPair world == self
		ifFalse: [ self error: 'Fixed joint endpoints must belong to this physics world' ].
	(aJoint firstBody notNil or: [ aJoint secondBody notNil ])
		ifFalse: [ self error: 'A fixed joint requires at least one body endpoint' ].
	aJoint sequence: nextFixedJointSequence.
	nextFixedJointSequence := nextFixedJointSequence + 1.
	fixedJoints add: aJoint.
	aJoint wakeBodies.
	^ aJoint
]

{ #category : 'fixed joints' }
CFPhysicsWorld >> fixedJointsUsingBody: aBodyState [
	^ self fixedJoints select: [ :each | each includesBody: aBodyState ]
]

{ #category : 'fixed joints' }
CFPhysicsWorld >> removeFixedJoint: aJoint [
	(fixedJoints includes: aJoint) ifTrue: [
		aJoint release.
		fixedJoints remove: aJoint ].
	^ aJoint
]

{ #category : 'fixed joints' }
CFPhysicsWorld >> removeFixedJointsUsingBody: aBodyState [
	(fixedJoints select: [ :each | each includesBody: aBodyState ]) copy do: [ :each |
		self removeFixedJoint: each ]
]

{ #category : 'rail joints' }
CFPhysicsWorld >> railJoints [
	^ railJoints asArray sorted: [ :first :second |
		first orderingKey < second orderingKey ]
]

{ #category : 'rail joints' }
CFPhysicsWorld >> addRailJoint: aJoint [
	aJoint endpointPair world == self
		ifFalse: [ self error: 'Rail joint endpoints must belong to this physics world' ].
	(aJoint firstBody notNil or: [ aJoint secondBody notNil ])
		ifFalse: [ self error: 'A rail joint requires at least one body endpoint' ].
	aJoint sequence: nextRailJointSequence.
	nextRailJointSequence := nextRailJointSequence + 1.
	railJoints add: aJoint.
	aJoint wakeBodies.
	^ aJoint
]

{ #category : 'rail joints' }
CFPhysicsWorld >> railJointsUsingBody: aBodyState [
	^ self railJoints select: [ :each | each includesBody: aBodyState ]
]

{ #category : 'rail joints' }
CFPhysicsWorld >> removeRailJoint: aJoint [
	(railJoints includes: aJoint) ifTrue: [
		aJoint release.
		railJoints remove: aJoint ].
	^ aJoint
]

{ #category : 'rail joints' }
CFPhysicsWorld >> removeRailJointsUsingBody: aBodyState [
	(railJoints select: [ :each | each includesBody: aBodyState ]) copy do: [ :each |
		self removeRailJoint: each ]
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
