Class {
	#name : 'CFPhysicsWorld',
	#superclass : 'Object',
	#instVars : [ 'owner', 'members', 'bodyStates', 'gravity', 'stepDuration', 'nextBodySequence', 'restitutionThreshold', 'substepCount', 'contactHertz', 'contactDampingRatio', 'activeContacts', 'lastStepResult', 'stepPipeline', 'pointerConstraints', 'springConstraints', 'containmentConstraints' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
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
	containmentConstraints := IdentitySet new.
	stepPipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsBlocManifoldBuilder
			manifoldBetweenBody: pair firstBody
			andBody: pair secondBody ]
]

{ #category : 'accessing' }
CFPhysicsWorld >> owner [ ^ owner ]

{ #category : 'accessing' }
CFPhysicsWorld >> owner: anElement [ owner := anElement ]

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
		self removeContainmentsUsingBody: body.
		activeContacts := activeContacts reject: [ :contact |
			contact firstBody == body or: [ contact secondBody == body ] ].
		body release ]
]

{ #category : 'stepping' }
CFPhysicsWorld >> newStep [
	^ CFPhysicsStep
		timeStep: stepDuration asMilliSeconds / 1000.0
		substeps: substepCount
		contactHertz: contactHertz
		dampingRatio: contactDampingRatio
]

{ #category : 'stepping' }
CFPhysicsWorld >> step [
	| bodies step |
	self synchroniseMembership.
	bodies := self bodyStatesInOrder.
	step := self newStep.
	self prepareSpringConstraintsForStep: step timeStep.
	self prepareContainmentConstraintsForStep.
	self preparePointerConstraintsForStep: step timeStep.
	lastStepResult := stepPipeline
		stepBodies: bodies
		fromContacts: activeContacts
		step: step
		gravity: gravity
		restitutionThreshold: restitutionThreshold.
	activeContacts := lastStepResult activeContacts.
	bodies do: [ :each | each present ].
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


{ #category : 'spring interaction' }
CFPhysicsWorld >> springConstraints [
	^ springConstraints asArray sorted: [ :first :second |
		first orderingKey < second orderingKey ]
]

{ #category : 'spring interaction' }
CFPhysicsWorld >> addSpringConstraint: aConstraint [
	(aConstraint firstBody world == self and: [ aConstraint secondBody world == self ])
		ifFalse: [ self error: 'Both spring bodies must belong to this physics world' ].
	springConstraints add: aConstraint.
	^ aConstraint
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
			ifTrue: [ each prepareForBounds: (0 @ 0 extent: owner extent) ]
			ifFalse: [ containmentConstraints remove: each ifAbsent: [ ] ] ]
]
