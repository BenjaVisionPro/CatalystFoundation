"
I represent a Physics world.

My responsibility is to own authoritative simulation state and advance it through the configured step pipeline. I coordinate bodies, forces, joints, contacts, Behaviours, telemetry and committed solutions for my member elements.
"
Class {
	#name : 'CFPhysicsWorld',
	#superclass : 'Object',
	#instVars : [ 'owner', 'members', 'bodyStates', 'containmentBody', 'containmentChain', 'containmentGeometry', 'containmentExtent', 'containmentMargin', 'containmentFriction', 'containmentRestitution', 'lengthUnitsPerMetre', 'gravity', 'stepDuration', 'nextBodySequence', 'restitutionThreshold', 'hitEventThreshold', 'maximumContactPushSpeed', 'maximumLinearSpeed', 'substepCount', 'contactHertz', 'contactDampingRatio', 'contacts', 'activeContacts', 'calculationContacts', 'lastStepResult', 'stepPipeline', 'joints', 'forces', 'containment', 'nextJointSequence', 'previousTimeStep', 'warmStarting', 'simulationTime', 'stepNumber', 'behaviours', 'telemetryEnabled', 'telemetryLogger', 'telemetryCapacity', 'telemetryAnnouncer', 'telemetryAnalysisWindowSeconds', 'telemetryStepStatisticsMaximumMicroseconds', 'telemetryAnalysisInBackground', 'backgroundStepping', 'lifetimeGeneration', 'topologyRevision', 'nextSolveTicket', 'activeSolveTicket', 'visualStateConsumers', 'committedVisualState', 'calculationVisualState', 'manifoldGenerator', 'persistentIslandGraph', 'geometrySignaturesByBody', 'released' ],
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
	geometrySignaturesByBody := IdentityDictionary new.
	nextBodySequence := 1.
	lengthUnitsPerMetre := 100.0.
	gravity := 0 @ 10.0.
	stepDuration := 16 milliseconds.
	restitutionThreshold := 1.0.
	hitEventThreshold := 1.0.
	maximumContactPushSpeed := 3.0.
	maximumLinearSpeed := 400.0.
	substepCount := 4.
	contactHertz := 30.0.
	contactDampingRatio := 10.0.
	contacts := #().
	activeContacts := #().
	calculationContacts := #().
	joints := OrderedCollection new.
	forces := OrderedCollection new.
	nextJointSequence := 1.
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
	released := false.
	telemetryAnnouncer := Announcer new.
	lifetimeGeneration := 1.
	topologyRevision := 0.
	nextSolveTicket := 1.
	activeSolveTicket := nil.
	visualStateConsumers := 0.
	committedVisualState := CFPhysicsWorldVisualState new.
	calculationVisualState := CFPhysicsWorldVisualState new.
	containment := CFPhysicsWorldContainment new.
	containmentBody := nil.
	containmentChain := nil.
	containmentGeometry := nil.
	containmentExtent := nil.
	containmentMargin := nil.
	containmentFriction := nil.
	containmentRestitution := nil.
	manifoldGenerator := CFPhysicsManifoldGenerator new.
	persistentIslandGraph := CFPhysicsPersistentIslandGraph new.
	stepPipeline := CFPhysicsStepPipeline manifoldGenerator: manifoldGenerator
]


{ #category : 'accessing' }
CFPhysicsWorld >> manifoldGenerator [ ^ manifoldGenerator ]

{ #category : 'islands' }
CFPhysicsWorld >> persistentIslandGraph [
	"Persistent runtime island connectivity. Solver islands continue to be built by the existing stage until this graph lifecycle is fully integrated."
	^ persistentIslandGraph
]

{ #category : 'accessing' }
CFPhysicsWorld >> owner [ ^ owner ]


{ #category : 'testing - lifecycle' }
CFPhysicsWorld >> isReleased [
	^ released
]

{ #category : 'private - lifecycle' }
CFPhysicsWorld >> assertNotReleased [
	released ifTrue: [
		self error: 'The Physics world has been released' ]
]

{ #category : 'accessing' }
CFPhysicsWorld >> owner: anElement [
	owner == anElement ifTrue: [ ^ self ].
	(self respondsTo: #physicsOwnerWillChange) ifTrue: [
		self physicsOwnerWillChange ].
	owner := anElement
]

{ #category : 'lifecycle' }
CFPhysicsWorld >> release [
	released ifTrue: [ ^ self ].
	released := true.
	self invalidateLifetime.
	"Release every resource owned by this world. My owner remains structurally
	unchanged; its Physics facade removes the world association separately."
	self telemetryEnabled: false.
	telemetryLogger := nil.
	behaviours copy do: [ :each | each stop ].
	joints copy do: #remove.
	forces copy do: #remove.
	bodyStates keys do: [ :each |
		each existingPhysics ifNotNil: [ :physics |
			physics retireBodyFromWorld: self ] ].
	bodyStates removeAll.
	members removeAll.
	contacts := #().
	activeContacts := #().
	calculationContacts := #().
	persistentIslandGraph := CFPhysicsPersistentIslandGraph new.
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
CFPhysicsWorld >> stepDuration: aDuration [
	(aDuration asMilliSeconds > 0) ifFalse: [
		self error: 'Physics step duration must be greater than zero' ].
	stepDuration := aDuration
]

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
CFPhysicsWorld >> maximumLinearSpeed [
	"Maximum body speed in metres per second. Box2D 3.1.1 defaults this to 400 m/s."
	maximumLinearSpeed ifNil: [ maximumLinearSpeed := 400.0 ].
	^ maximumLinearSpeed
]

{ #category : 'solver configuration' }
CFPhysicsWorld >> maximumLinearSpeed: aNumber [
	"Set the maximum body speed in metres per second. It is converted to physics length units for each step."
	maximumLinearSpeed := aNumber asFloat max: 0.0
]

{ #category : 'solver configuration' }
CFPhysicsWorld >> substepCount [ ^ substepCount ]

{ #category : 'solver configuration' }
CFPhysicsWorld >> substepCount: anInteger [
	(anInteger isInteger and: [ anInteger > 0 ]) ifFalse: [
		self error: 'Physics substep count must be a positive integer' ].
	substepCount := anInteger
]

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
CFPhysicsWorld >> contacts [ ^ contacts ]

{ #category : 'collision' }
CFPhysicsWorld >> activeContacts [ ^ activeContacts ]

{ #category : 'collision' }
CFPhysicsWorld >> endedContacts [
	^ lastStepResult
		ifNil: [ #() ]
		ifNotNil: [ lastStepResult endedContacts ]
]

{ #category : 'private - body states' }
CFPhysicsWorld >> bodyStateFor: anElement [
	^ bodyStates at: anElement ifAbsent: [ nil ]
]

{ #category : 'body states' }
CFPhysicsWorld >> bodyStatesInOrder [
	^ bodyStates values sorted: [ :first :second |
		first sequence < second sequence ]
]


{ #category : 'body types' }
CFPhysicsWorld >> changeBody: aBody toType: aBodyType [
	| attachedContacts attachedJoints |
	aBody bodyType class = aBodyType class ifTrue: [ ^ aBody ].
	self invalidateTopology.
	attachedContacts := contacts select: [ :contact |
		contact firstBody == aBody or: [ contact secondBody == aBody ] ].
	attachedJoints := self joints select: [ :joint | joint includesBody: aBody ].
	attachedContacts do: [ :contact |
		contact isSolid ifTrue: [ persistentIslandGraph unlinkConstraint: contact ] ].
	attachedJoints do: [ :joint | persistentIslandGraph unlinkConstraint: joint ].
	persistentIslandGraph removeBody: aBody.
	aBody installBodyType: aBodyType.
	persistentIslandGraph addBody: aBody.
	attachedJoints do: [ :joint | persistentIslandGraph linkConstraint: joint ].
	aBody wake.
	attachedJoints do: #wakeBodies.
	stepPipeline touchBroadphaseProxyFor: aBody.
	^ aBody
]

{ #category : 'body states' }
CFPhysicsWorld >> registerBodyFor: anElement [
	| body |
	body := anElement physics bodyForRegistrationInWorld: self.
	self invalidateTopology.
	body sequence: nextBodySequence.
	nextBodySequence := nextBodySequence + 1.
	persistentIslandGraph addBody: body.
	geometrySignaturesByBody at: body put: body shapeState collisionGeometrySignature.
	^ body
]

{ #category : 'membership' }
CFPhysicsWorld >> members [ ^ members asArray ]

{ #category : 'testing' }
CFPhysicsWorld >> includes: anElement [ ^ members includes: anElement ]

{ #category : 'private - membership' }
CFPhysicsWorld >> isValidMember: anElement [
	| physics |
	physics := anElement existingPhysics.
	^ physics notNil and: [ physics world == self ]
]

{ #category : 'private - membership' }
CFPhysicsWorld >> addElement: anElement [
	| body |
	(self includes: anElement) ifTrue: [ ^ bodyStates at: anElement ].
	(self isElementOwnedByWorld: anElement) ifFalse: [
		self error: 'The element is not contained by this physics world' ].
	body := self registerBodyFor: anElement.
	bodyStates at: anElement put: body.
	members add: anElement.
	^ body
]

{ #category : 'private - membership' }
CFPhysicsWorld >> isElementOwnedByWorld: anElement [
	^ anElement physics world == self
]

{ #category : 'private - membership' }
CFPhysicsWorld >> refreshExistingMembers [
	| retainedMembers |
	retainedMembers := members select: [ :each | self isValidMember: each ].
	self retireMembersAbsentFrom: retainedMembers.
	retainedMembers do: [ :each |
		self refreshCollisionGeometryFor: (bodyStates at: each) ].
	members := retainedMembers asIdentitySet.
	^ members
]

{ #category : 'private - membership' }
CFPhysicsWorld >> retireElement: anElement [
	| body |
	body := bodyStates at: anElement ifAbsent: [ ^ self ].
	self invalidateTopology.
	bodyStates removeKey: anElement.
	members remove: anElement ifAbsent: [ ].
	geometrySignaturesByBody removeKey: body ifAbsent: [ ].
	anElement existingPhysics ifNotNil: [ :physics |
		physics retireBodyFromWorld: self ].
	self removeForcesUsingBody: body.
	self removeJointsUsingBody: body.
	self removeContactsUsingBody: body.
	persistentIslandGraph removeBody: body.
	^ self
]

{ #category : 'private - membership' }
CFPhysicsWorld >> retireMembersAbsentFrom: currentMembers [
	(bodyStates keys reject: [ :each | currentMembers includes: each ])
		do: [ :each | self retireElement: each ]
]

{ #category : 'private - contacts' }
CFPhysicsWorld >> removeContactsUsingBody: aBody [
	| removedContacts |
	removedContacts := contacts select: [ :contact |
		contact firstBody == aBody or: [ contact secondBody == aBody ] ].
	removedContacts do: [ :contact |
		contact isSolid ifTrue: [ persistentIslandGraph unlinkConstraint: contact ] ].
	contacts := contacts reject: [ :contact |
		contact firstBody == aBody or: [ contact secondBody == aBody ] ].
	activeContacts := activeContacts reject: [ :contact |
		contact firstBody == aBody or: [ contact secondBody == aBody ] ].
	calculationContacts := calculationContacts reject: [ :contact |
		contact firstBody == aBody or: [ contact secondBody == aBody ] ]
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
CFPhysicsWorld >> includesBehaviour: aBehaviour [
	^ behaviours identityIncludes: aBehaviour
]

{ #category : 'behaviours' }
CFPhysicsWorld >> retireInvalidBehaviours [
	behaviours copy do: [ :behaviour |
		behaviour target physics world == self ifFalse: [ behaviour stop ] ]
]

{ #category : 'behaviours' }
CFPhysicsWorld >> updateBehavioursForStep: aPhysicsStep [
	behaviours copy do: [ :behaviour |
		(self includesBehaviour: behaviour) ifTrue: [
			behaviour step: aPhysicsStep ] ]
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
		maximumLinearSpeed: (self lengthUnitsForMetres: self maximumLinearSpeed);
		hitEventThreshold: (self lengthUnitsForMetres: hitEventThreshold);
		linearSlop: (self lengthUnitsForMetres: 0.005);
		speculativeDistance: (self lengthUnitsForMetres: 0.02);
		broadphaseAABBMargin: (self lengthUnitsForMetres: 0.05);
		warmStartRatio: (warmStarting ifTrue: [ 1.0 ] ifFalse: [ 0.0 ]).
	^ step
]

{ #category : 'stepping' }
CFPhysicsWorld >> step [
	self assertNotReleased.
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
	self prepareForStateCapture.
	^ self capturePreparedState
]

{ #category : 'private - stepping' }
CFPhysicsWorld >> prepareForStateCapture [
	self refreshExistingMembers.
	self refreshContainmentBoundary.
	self retireInvalidBehaviours
]

{ #category : 'private - stepping' }
CFPhysicsWorld >> capturePreparedState [
	| bodies step capturedBodyStates orderedBodyStates capturedJoints index solveTicket containmentState |
	bodies := self bodyStatesInOrder.
	bodies do: #beginStep.
	containmentBody ifNotNil: [ containmentBody beginStep ].
	step := self newStep.
	self updateBehavioursForStep: step.
	self applyForcesForStep: step timeStep.
	capturedBodyStates := IdentityDictionary new.
	orderedBodyStates := Array new: bodies size + (containmentBody isNil ifTrue: [ 0 ] ifFalse: [ 1 ]).
	capturedJoints := self joints collect: #capturedForStep.
	index := 0.
	bodies do: [ :body |
		| bodyState |
		bodyState := CFPhysicsBodyStepState on: body.
		capturedBodyStates at: body put: bodyState.
		orderedBodyStates at: (index := index + 1) put: bodyState ].
	containmentBody ifNotNil: [
		containmentState := CFPhysicsBodyStepState on: containmentBody.
		capturedBodyStates at: containmentBody put: containmentState.
		orderedBodyStates at: (index := index + 1) put: containmentState ].
	solveTicket := self beginSolveTicket.
	^ CFPhysicsWorldState new
		world: self;
		lifetimeGeneration: lifetimeGeneration;
		topologyRevision: topologyRevision;
		solveTicket: solveTicket;
		bodies: bodies;
		bodyStates: capturedBodyStates;
		orderedBodyStates: orderedBodyStates;
		contacts: contacts;
		calculationContacts: calculationContacts;
		joints: capturedJoints;
		collisionSuppressedBodyPairs: self collisionSuppressedBodyPairs;
		step: step;
		gravity: (self accelerationUnitsForMetresPerSecondSquared: gravity);
		restitutionThreshold: (self lengthUnitsForMetres: restitutionThreshold);
		islandBodyGroups: persistentIslandGraph solverBodyGroups;
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
	previousCommittedContacts := contacts.
	self updatePersistentIslandsFrom: pipelineResult.
	contacts := pipelineResult contacts.
	activeContacts := pipelineResult touchingContacts.
	calculationContacts := previousCommittedContacts.
	lastStepResult := pipelineResult.
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
	self dispatchContactEventsFrom: pipelineResult.
	^ pipelineResult
]

{ #category : 'private - islands' }
CFPhysicsWorld >> updatePersistentIslandsFrom: aPipelineResult [
	| previousContactsByKey |
	"Maintain persistent solver connectivity from committed contact lifecycle and classification changes. Sensors do not join solver islands."
	previousContactsByKey := Dictionary new.
	aPipelineResult previousContacts do: [ :contact |
		previousContactsByKey at: contact key put: contact ].
	aPipelineResult endedContacts do: [ :contact |
		contact isSolid ifTrue: [ persistentIslandGraph unlinkConstraint: contact ] ].
	aPipelineResult beganContacts do: [ :contact |
		contact isSolid ifTrue: [ persistentIslandGraph linkConstraint: contact ] ].
	aPipelineResult continuedContacts do: [ :contact |
		| previousContact |
		previousContact := previousContactsByKey at: contact key ifAbsent: [ nil ].
		previousContact ifNotNil: [
			(previousContact isSolid and: [ contact isSensor ]) ifTrue: [
				persistentIslandGraph unlinkConstraint: previousContact ].
			(previousContact isSensor and: [ contact isSolid ]) ifTrue: [
				persistentIslandGraph linkConstraint: contact ] ] ].
	persistentIslandGraph mergeIslands.
	"Box2D 3.1.1 splits at most one dirty island after sleep times have been committed. The sleepiest eligible body nominates its island."
	persistentIslandGraph splitSleepiestIslandEligibleAt: self timeToSleep
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
		self prepareForStateCapture ].
	state := ProcessTelemetry time: [ 'Preparation' ] during: [
		self capturePreparedState ].
	solution := ProcessTelemetry time: [ 'Pipeline' ] during: [
		stepPipeline solveWithTelemetry: state ].
	^ ProcessTelemetry time: [ 'Boundary' ] during: [
		self commit: solution ]
]

{ #category : 'private - telemetry' }
CFPhysicsWorld >> telemetryDataForStepResult: aStepResult [
	| solvedIslands dynamicBodyStates sleepConfiguration step sleepVelocities sleepThresholdRatios motionThresholdRatios correctionThresholdRatios worstState worstRatio worstMotionState worstMotionRatio worstCorrectionState worstCorrectionRatio worstMaximumVelocity worstCorrectionVelocity worstNormalImpulse worstTangentImpulse contactUpdater |
	dynamicBodyStates := aStepResult bodyStates values select: [ :each | each bodyType isDynamic ].
	step := aStepResult step.
	sleepConfiguration := stepPipeline sleepConfiguration.
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
		activeContacts do: [ :contact |
			(contact firstBody == worstState body or: [ contact secondBody == worstState body ]) ifTrue: [
				contact manifold ifNotNil: [ :manifold |
					manifold contactPoints do: [ :point |
						worstNormalImpulse := worstNormalImpulse + point normalImpulse.
						worstTangentImpulse := worstTangentImpulse + point tangentImpulse abs ] ] ] ] ].
	solvedIslands := aStepResult islands select: [ :island |
		island dynamicBodies anySatisfy: #isAwake ].
	contactUpdater := self contactUpdaterMeasurements.
	^ Dictionary new
		at: #physicsWorld put: self;
		at: #kind put: #step;
		at: #stepNumber put: stepNumber;
		at: #simulationTime put: simulationTime;
		at: #bodyCount put: bodyStates size;
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
		at: #contactCount put: activeContacts size;
		at: #persistentContactCount put: contacts size;
		at: #beganContactCount put: aStepResult beganContacts size;
		at: #continuedContactCount put: aStepResult continuedContacts size;
		at: #endedContactCount put: aStepResult endedContacts size;
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
		at: #pairFinderEntryCount put: self pairFinderMeasurements entryCount;
		at: #pairFinderComparisonCount put: self pairFinderMeasurements comparisonCount;
		at: #pairFinderAcceptedPairCount put: self pairFinderMeasurements acceptedPairCount;
		at: #pairFinderMaximumActiveCount put: self pairFinderMeasurements maximumActiveCount;
		at: #broadphaseProxyCount put: self pairFinderMeasurements proxyCount;
		at: #broadphaseMovedProxyCount put: self pairFinderMeasurements movedProxyCount;
		at: #broadphaseQueryVisitCount put: self pairFinderMeasurements queryVisitCount;
		at: #constraintCount put: aStepResult solverConstraints size;
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
		at: #solverMaximumInitialContactPenetration put: aStepResult solver maximumInitialContactPenetration;
		at: #solverMaximumFinalContactPenetration put: aStepResult solver maximumFinalContactPenetration;
		at: #solverAverageFinalContactPenetration put: aStepResult solver averageFinalContactPenetration;
		at: #solverMaximumBodyTranslation put: aStepResult solver maximumBodyTranslation;
		at: #solverTotalNormalImpulse put: aStepResult solver totalNormalImpulse;
		at: #solverTotalTangentImpulse put: aStepResult solver totalTangentImpulse;
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
		at: #featureIdChangedPreparedManifoldCount put: self constraintPreparationMeasurements featureIdChangedManifoldCount;
		at: #normalChangedPreparedManifoldCount put: self constraintPreparationMeasurements normalChangedManifoldCount;
		at: #pointCountChangedPreparedManifoldCount put: self constraintPreparationMeasurements pointCountChangedManifoldCount;
		at: #pointOrderChangedPreparedManifoldCount put: self constraintPreparationMeasurements pointOrderChangedManifoldCount;
		at: #separationChangedPreparedManifoldCount put: self constraintPreparationMeasurements separationChangedManifoldCount;
		at: #preparedJointConstraintCount put: self constraintPreparationMeasurements preparedJointConstraintCount;
		at: #preparedConstraintObjectCount put: self constraintPreparationMeasurements preparedObjectCount;
		yourself
]



{ #category : 'private - telemetry' }
CFPhysicsWorld >> contactUpdaterMeasurements [
	^ (stepPipeline stageOfType: CFPhysicsContactUpdateStage) contactUpdater
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
	(aPositiveInteger isInteger and: [ aPositiveInteger > 0 ]) ifFalse: [
		self error: 'Physics step count must be a positive integer' ].
	aPositiveInteger timesRepeat: [ self step ].
	^ lastStepResult
]



{ #category : 'sleeping' }
CFPhysicsWorld >> sleepConfiguration [ ^ stepPipeline sleepConfiguration ]


{ #category : 'sleeping' }
CFPhysicsWorld >> sleepConfiguration: aConfiguration [ stepPipeline sleepConfiguration: aConfiguration ]

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
	^ self joints select: [ :each | each class == CFPhysicsMouseJoint ]
]




{ #category : 'motor joints' }
CFPhysicsWorld >> motorJoints [
	^ self joints select: [ :each | each class == CFPhysicsMotorJoint ]
]

{ #category : 'motor joints' }
CFPhysicsWorld >> motorJointsUsingBody: aBody [
	^ self motorJoints select: [ :each | each includesBody: aBody ]
]

{ #category : 'filter joints' }
CFPhysicsWorld >> filterJoints [
	^ self joints select: [ :each | each class == CFPhysicsFilterJoint ]
]


{ #category : 'filter joints' }
CFPhysicsWorld >> filterJointsUsingBody: aBody [
	^ self filterJoints select: [ :each | each includesBody: aBody ]
]



{ #category : 'forces' }
CFPhysicsWorld >> forces [
	^ forces asArray
]

{ #category : 'forces' }
CFPhysicsWorld >> addForce: aForce [
	aForce validateForWorld: self.
	aForce addedToWorld: self.
	forces add: aForce.
	^ aForce
]

{ #category : 'forces' }
CFPhysicsWorld >> removeForce: aForce [
	(forces identityIncludes: aForce) ifTrue: [
		forces remove: aForce.
		aForce removedFromWorld ].
	^ aForce
]

{ #category : 'forces' }
CFPhysicsWorld >> forcesUsingBody: aBody [
	^ self forces select: [ :each | each includesBody: aBody ]
]

{ #category : 'forces' }
CFPhysicsWorld >> removeForcesUsingBody: aBody [
	(self forcesUsingBody: aBody) copy do: [ :force | force removeBody: aBody ]
]

{ #category : 'forces' }
CFPhysicsWorld >> applyForcesForStep: seconds [
	forces copy do: [ :each |
		(each world == self) ifTrue: [ each applyForStep: seconds ] ]
]

{ #category : 'forces' }
CFPhysicsWorld >> attractions [
	^ self forces select: [ :each | each isKindOf: CFPhysicsAttractionForce ]
]

{ #category : 'forces' }
CFPhysicsWorld >> attractionsUsingBody: aBody [
	^ self attractions select: [ :each | each includesBody: aBody ]
]

{ #category : 'forces' }
CFPhysicsWorld >> repulsions [
	^ self forces select: [ :each | each isKindOf: CFPhysicsRepulsionForce ]
]

{ #category : 'forces' }
CFPhysicsWorld >> repulsionsUsingBody: aBody [
	^ self repulsions select: [ :each | each includesBody: aBody ]
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
	^ self joints select: [ :each | each class == CFPhysicsDistanceJoint ]
]


{ #category : 'distance joints' }
CFPhysicsWorld >> distanceJointsUsingBody: aBodyState [
	^ self distanceJoints select: [ :each | each includesBody: aBodyState ]
]

{ #category : 'private - joints' }
CFPhysicsWorld >> wakeBodiesForJointCreation: aJoint [
	"Box2D 3.1.1 keeps a joint between sleeping/static bodies asleep. If either endpoint is awake, the sleeping endpoint's island is woken."
	| bodyA bodyB |
	bodyA := aJoint bodyA.
	bodyB := aJoint bodyB.
	((bodyA notNil and: [ bodyA isAwake ]) or: [
		bodyB notNil and: [ bodyB isAwake ] ]) ifFalse: [ ^ self ].
	bodyA ifNotNil: [ self wakeBody: bodyA ].
	bodyB ifNotNil: [ self wakeBody: bodyB ]
]


{ #category : 'joints' }
CFPhysicsWorld >> addJoint: aJoint [
	aJoint validateForWorld: self.
	aJoint addedToWorld: self.
	aJoint sequence: nextJointSequence.
	nextJointSequence := nextJointSequence + 1.
	self invalidateTopology.
	joints add: aJoint.
	persistentIslandGraph linkConstraint: aJoint.
	self wakeBodiesForJointCreation: aJoint.
	^ aJoint
]

{ #category : 'joints' }
CFPhysicsWorld >> removeJoint: aJoint [
	aJoint world == self ifFalse: [ ^ aJoint ].
	(joints includes: aJoint) ifFalse: [ ^ aJoint ].
	self invalidateTopology.
	persistentIslandGraph unlinkConstraint: aJoint.
	joints remove: aJoint.
	aJoint wakeBodies.
	aJoint removedFromWorld.
	^ aJoint
]

{ #category : 'joints' }
CFPhysicsWorld >> joints [
	^ joints asArray
]

{ #category : 'joints' }
CFPhysicsWorld >> jointsUsingBody: aBody [
	^ self joints select: [ :each | each includesBody: aBody ]
]

{ #category : 'joints' }
CFPhysicsWorld >> removeJointsUsingBody: aBody [
	(self jointsUsingBody: aBody) do: #remove
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



{ #category : 'revolute joints' }
CFPhysicsWorld >> revoluteJoints [
	^ self joints select: [ :each | each class == CFPhysicsRevoluteJoint ]
]


{ #category : 'revolute joints' }
CFPhysicsWorld >> revoluteJointsUsingBody: aBodyState [
	^ self revoluteJoints select: [ :each | each includesBody: aBodyState ]
]



{ #category : 'weld joints' }
CFPhysicsWorld >> weldJoints [
	^ self joints select: [ :each | each class == CFPhysicsWeldJoint ]
]


{ #category : 'weld joints' }
CFPhysicsWorld >> weldJointsUsingBody: aBodyState [
	^ self weldJoints select: [ :each | each includesBody: aBodyState ]
]



{ #category : 'prismatic joints' }
CFPhysicsWorld >> prismaticJoints [
	^ self joints select: [ :each | each class == CFPhysicsPrismaticJoint ]
]


{ #category : 'prismatic joints' }
CFPhysicsWorld >> prismaticJointsUsingBody: aBodyState [
	^ self prismaticJoints select: [ :each | each includesBody: aBodyState ]
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


{ #category : 'sleeping' }
CFPhysicsWorld >> wakeBody: aBody [
	| island |
	self invalidateTopology.
	persistentIslandGraph mergeIslands.
	island := persistentIslandGraph islandForBody: aBody.
	island
		ifNil: [ aBody wakeLocally ]
		ifNotNil: [ island bodies do: #wakeLocally ]
]

{ #category : 'sleeping' }
CFPhysicsWorld >> sleepBody: aBody [
	| island |
	self invalidateTopology.
	persistentIslandGraph mergeIslands.
	island := persistentIslandGraph islandForBody: aBody.
	island ifNil: [
		aBody sleepLocally.
		^ self ].
	island constraintRemoveCount > 0 ifTrue: [
		persistentIslandGraph splitIsland: island.
		island := persistentIslandGraph islandForBody: aBody ].
	island ifNotNil: [ island bodies do: #sleepLocally ]
]


{ #category : 'containment' }
CFPhysicsWorld >> containment [
	^ containment ifNil: [ containment := CFPhysicsWorldContainment new ]
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


{ #category : 'sensors' }
CFPhysicsWorld >> sensorClassificationChangedForBody: aBody [
	activeContacts do: [ :contact |
		(contact firstBody == aBody or: [ contact secondBody == aBody ]) ifTrue: [
			contact firstBody wake.
			contact secondBody wake ] ].
	self touchBroadphaseProxyFor: aBody.
	^ self
]

{ #category : 'collision filtering' }
CFPhysicsWorld >> collisionFilterChangedForBody: aBody [
	activeContacts do: [ :contact |
		((contact isSolid
			and: [ contact firstBody == aBody or: [ contact secondBody == aBody ] ])
			and: [ (contact pair firstShape allowsCollisionWith: contact pair secondShape) not ]) ifTrue: [
			contact firstBody wake.
			contact secondBody wake ] ].
	self touchBroadphaseProxyFor: aBody.
	^ self
]

{ #category : 'broadphase' }
CFPhysicsWorld >> touchBroadphaseProxyFor: aBody [
	stepPipeline touchBroadphaseProxyFor: aBody.
	^ self
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
	^ self joints select: [ :each | each class == CFPhysicsWheelJoint ]
]


{ #category : 'wheel joints' }
CFPhysicsWorld >> wheelJointsUsingBody: aBodyState [
	^ self wheelJoints select: [ :each | each includesBody: aBodyState ]
]



{ #category : 'containment - internal' }
CFPhysicsWorld >> containmentBoundaryBody [
	^ containmentBody
]

{ #category : 'containment - internal' }
CFPhysicsWorld >> containmentBoundaryChain [
	^ containmentChain
]

{ #category : 'containment - internal' }
CFPhysicsWorld >> refreshContainmentBoundary [
	| shapeState extent geometry vertices localVertices material filter changed |
	self containment isEnabled ifFalse: [
		self removeContainmentBoundary.
		^ self ].
	owner ifNil: [ ^ self ].
	shapeState := CFPhysicsShapeState on: owner.
	extent := shapeState extent.
	(extent x <= 0 or: [ extent y <= 0 ]) ifTrue: [
		self removeContainmentBoundary.
		^ self ].
	geometry := owner geometry.
	changed := containmentChain isNil
		or: [ containmentGeometry ~~ geometry
			or: [ containmentExtent ~= extent
				or: [ containmentMargin ~= self containment margin
					or: [ containmentFriction ~= self containment friction
						or: [ containmentRestitution ~= self containment restitution ] ] ] ] ].
	changed ifFalse: [ ^ self ].
	self removeContainmentBoundary.
	containmentBody := CFPhysicsBody element: owner world: self.
	containmentBody sequence: 0.
	containmentBody beStatic.
	containmentBody shapeCollection remove: containmentBody shapeState.
	vertices := CFPhysicsBlocGeometryBuilder
		boundaryVerticesFor: geometry
		extent: extent
		margin: self containment margin.
	localVertices := vertices collect: [ :each | each - (extent / 2.0) ].
	material := self containment material.
	filter := CFPhysicsCollisionFilter new.
	containmentChain := CFPhysicsChainBuilder
		inwardLoopFrom: localVertices
		material: material
		collisionFilter: filter
		body: containmentBody.
	containmentGeometry := geometry.
	containmentExtent := extent.
	containmentMargin := self containment margin.
	containmentFriction := self containment friction.
	containmentRestitution := self containment restitution.
	self invalidateTopology
]

{ #category : 'containment - internal' }
CFPhysicsWorld >> removeContainmentBoundary [
	containmentBody ifNil: [ ^ self ].
	contacts := contacts reject: [ :contact |
		contact firstBody == containmentBody or: [ contact secondBody == containmentBody ] ].
	activeContacts := activeContacts reject: [ :contact |
		contact firstBody == containmentBody or: [ contact secondBody == containmentBody ] ].
	calculationContacts := calculationContacts reject: [ :contact |
		contact firstBody == containmentBody or: [ contact secondBody == containmentBody ] ].
	containmentBody := nil.
	containmentChain := nil.
	containmentGeometry := nil.
	containmentExtent := nil.
	containmentMargin := nil.
	containmentFriction := nil.
	containmentRestitution := nil.
	self invalidateTopology
]


{ #category : 'geometry lifecycle' }
CFPhysicsWorld >> refreshCollisionGeometryFor: aBody [
	| signature previousSignature |
	signature := aBody shapeState collisionGeometrySignature.
	previousSignature := geometrySignaturesByBody
		at: aBody
		ifAbsentPut: [ signature ].
	previousSignature = signature ifTrue: [ ^ self ].
	geometrySignaturesByBody at: aBody put: signature.
	self collisionGeometryChangedForBody: aBody
]

{ #category : 'geometry lifecycle' }
CFPhysicsWorld >> collisionGeometryChangedForBody: aBody [
	| attachedContacts |
	self invalidateTopology.
	attachedContacts := contacts select: [ :contact |
		contact firstBody == aBody or: [ contact secondBody == aBody ] ].
	attachedContacts do: [ :contact |
		contact isSolid ifTrue: [ persistentIslandGraph unlinkConstraint: contact ].
		contact isTouching ifTrue: [
			contact firstBody wake.
			contact secondBody wake ] ].
	aBody shapeState advanceGeometryRevision.
	stepPipeline resetBroadphaseProxiesFor: aBody.
	^ self
]


{ #category : 'private - events' }
CFPhysicsWorld >> dispatchContactEventsFrom: aStepResult [
	aStepResult contactEvents do: [ :record |
		| eventClass contact |
		eventClass := record began
			ifTrue: [ CFPhysicsContactBeganEvent ]
			ifFalse: [ CFPhysicsContactEndedEvent ].
		contact := record contact.
		self dispatchContactEvent: eventClass contact: contact toBody: contact firstBody.
		self dispatchContactEvent: eventClass contact: contact toBody: contact secondBody ].
	aStepResult hitEvents do: [ :record |
		self dispatchHitEvent: record toBody: record contact firstBody.
		self dispatchHitEvent: record toBody: record contact secondBody ]
]

{ #category : 'private - events' }
CFPhysicsWorld >> dispatchContactEvent: anEventClass contact: aContact toBody: aBody [
	aBody element ifNotNil: [ :element |
		element dispatchEvent: (anEventClass contact: aContact forBody: aBody) ]
]

{ #category : 'private - events' }
CFPhysicsWorld >> dispatchHitEvent: aHitRecord toBody: aBody [
	aBody element ifNotNil: [ :element |
		element dispatchEvent: (CFPhysicsContactHitEvent record: aHitRecord forBody: aBody) ]
]
