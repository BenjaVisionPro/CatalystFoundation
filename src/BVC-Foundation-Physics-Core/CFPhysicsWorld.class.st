"
I am the deterministic Physics simulation owned by one Bloc element.

I own body membership, solver configuration, constraints, contacts and the explicit #step operation. A step synchronises membership and advances the pipeline by one fixed #stepDuration. I do not schedule frames or own visual presentation resources.

Motion-backed presentation and continuous playback are optional integration capabilities supplied by BVC-Foundation-Physics-Motion.
"
Class {
	#name : 'CFPhysicsWorld',
	#superclass : 'Object',
	#instVars : [ 'owner', 'members', 'bodyStates', 'gravity', 'stepDuration', 'nextBodySequence', 'restitutionThreshold', 'substepCount', 'contactHertz', 'contactDampingRatio', 'activeContacts', 'lastStepResult', 'stepPipeline', 'pointerConstraints', 'springConstraints', 'attractionConstraints', 'repulsionConstraints', 'containmentConstraints', 'distanceJoints', 'revoluteJoints', 'nextSpringSequence', 'nextAttractionSequence', 'nextRepulsionSequence', 'nextDistanceJointSequence', 'nextRevoluteJointSequence', 'previousTimeStep', 'warmStarting' ],
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
	previousTimeStep := nil.
	warmStarting := true.
	containmentConstraints := IdentitySet new.
	distanceJoints := IdentitySet new.
	revoluteJoints := IdentitySet new.
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
	body := CFPhysicsBodyState element: anElement world: self.
	body sequence: nextBodySequence.
	nextBodySequence := nextBodySequence + 1.
	^ body
]

{ #category : 'membership' }
CFPhysicsWorld >> members [ ^ members asArray ]

{ #category : 'testing' }
CFPhysicsWorld >> includes: anElement [ ^ members includes: anElement ]

{ #category : 'membership' }
CFPhysicsWorld >> collectMembersFrom: anElement into: aSet [
	| physics |
	physics := anElement physics.
	physics owningWorld == self ifTrue: [ aSet add: anElement ].
	physics isWorld ifTrue: [ ^ self ].
	anElement children do: [ :each |
		self collectMembersFrom: each into: aSet ]
]

{ #category : 'membership' }
CFPhysicsWorld >> synchroniseMembership [
	| currentMembers |
	currentMembers := IdentitySet new.
	owner children do: [ :each |
		self collectMembersFrom: each into: currentMembers ].
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
		self removeSpringsUsingBody: body.
		self removeAttractionsUsingBody: body.
		self removeRepulsionsUsingBody: body.
		self removeDistanceJointsUsingBody: body.
		self removeRevoluteJointsUsingBody: body.
		self removeContainmentsUsingBody: body.
		activeContacts := activeContacts reject: [ :contact |
			contact firstBody == body or: [ contact secondBody == body ] ] ]
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
	step warmStartRatio: (warmStarting
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
	| bodies step |
	self synchroniseMembership.
	bodies := self bodyStatesInOrder.
	bodies do: #beginStep.
	step := self newStep.
	self prepareAttractionConstraintsForStep: step timeStep.
	self prepareRepulsionConstraintsForStep: step timeStep.
	self prepareSpringConstraintsForStep: step timeStep.
	self prepareContainmentConstraintsForStep.
	self preparePointerConstraintsForStep: step timeStep.
	lastStepResult := stepPipeline
		stepBodies: bodies
		fromContacts: activeContacts
		joints: self joints
		step: step
		gravity: gravity
		restitutionThreshold: restitutionThreshold.
	activeContacts := lastStepResult activeContacts.
	previousTimeStep := step timeStep.
	^ lastStepResult
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
	^ (self distanceJoints, self revoluteJoints) asArray sorted: [ :first :second |
		first orderingKey = second orderingKey
			ifTrue: [ first class name asString < second class name asString ]
			ifFalse: [ first orderingKey < second orderingKey ] ]
]

{ #category : 'collision filtering' }
CFPhysicsWorld >> distanceJointPreventsCollisionBetween: firstBody and: secondBody [
	^ distanceJoints anySatisfy: [ :joint |
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

{ #category : 'distance joints' }
CFPhysicsWorld >> wakeDistanceJointsUsingAnchor: anAnchor [
	self wakeJointsUsingAnchor: anAnchor
]

{ #category : 'joints' }
CFPhysicsWorld >> wakeJointsUsingAnchor: anAnchor [
	(self joints select: [ :each | each includesAnchor: anAnchor ]) do: #wakeBodies
]


{ #category : 'containment interaction' }
CFPhysicsWorld >> containmentExtent [
	^ (CFPhysicsShapeState on: owner) extent
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
CFPhysicsWorld >> prepareContainmentConstraintsForStep [
	containmentConstraints copy do: [ :each |
		each isActive
			ifTrue: [ each prepareForBounds: (0 @ 0 extent: self containmentExtent) ]
			ifFalse: [ containmentConstraints remove: each ifAbsent: [ ] ] ]
]


{ #category : 'anchors' }
CFPhysicsWorld >> anchorAt: aPoint [
	^ CFPhysicsWorldAnchor in: self at: aPoint
]
