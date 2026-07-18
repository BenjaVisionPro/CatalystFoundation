Class {
	#name : 'CFPhysicsWorld',
	#superclass : 'Object',
	#instVars : [ 'owner', 'members', 'bodyStates', 'gravity', 'stepDuration', 'nextBodySequence', 'restitutionThreshold', 'substepCount', 'contactHertz', 'contactDampingRatio', 'activeContacts', 'lastStepResult', 'stepPipeline' ],
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
	| bodies |
	self synchroniseMembership.
	bodies := self bodyStatesInOrder.
	lastStepResult := stepPipeline
		stepBodies: bodies
		fromContacts: activeContacts
		step: self newStep
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
CFPhysicsWorld >> wakeAll [
	bodyStates valuesDo: [ :each | each wake ]
]
