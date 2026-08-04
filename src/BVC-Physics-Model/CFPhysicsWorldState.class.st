"
I represent a Physics world captured at one step boundary.

My responsibility is to provide the isolated bodies, contacts, joints and configuration consumed by the pipeline.
"
Class {
	#name : 'CFPhysicsWorldState',
	#superclass : 'Object',
	#instVars : [ 'bodies', 'contacts', 'calculationContacts', 'joints', 'step', 'gravity', 'restitutionThreshold', 'collisionSuppressedBodyPairs', 'bodyStates', 'orderedBodyStates', 'world', 'lifetimeGeneration', 'topologyRevision', 'solveTicket', 'calculationVisualState', 'islandBodyGroups' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsWorldState >> initialize [
	super initialize.
	bodies := #().
	contacts := #().
	calculationContacts := #().
	joints := #().
	collisionSuppressedBodyPairs := #().
	bodyStates := IdentityDictionary new.
	orderedBodyStates := #().
	islandBodyGroups := #()
]

{ #category : 'accessing' }
CFPhysicsWorldState >> bodies [ ^ bodies ]

{ #category : 'accessing' }
CFPhysicsWorldState >> bodies: aCollection [ bodies := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsWorldState >> contacts [ ^ contacts ]

{ #category : 'accessing' }
CFPhysicsWorldState >> contacts: aCollection [ contacts := aCollection asArray ]


{ #category : 'accessing' }
CFPhysicsWorldState >> calculationContacts [ ^ calculationContacts ]

{ #category : 'accessing' }
CFPhysicsWorldState >> calculationContacts: aCollection [ calculationContacts := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsWorldState >> joints [ ^ joints ]

{ #category : 'accessing' }
CFPhysicsWorldState >> joints: aCollection [ joints := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsWorldState >> step [ ^ step ]

{ #category : 'accessing' }
CFPhysicsWorldState >> step: aPhysicsStep [ step := aPhysicsStep ]

{ #category : 'accessing' }
CFPhysicsWorldState >> gravity [
	"Gravitational acceleration in physics length units per second squared."
	^ gravity
]

{ #category : 'accessing' }
CFPhysicsWorldState >> gravity: aPoint [ gravity := aPoint ]

{ #category : 'accessing' }
CFPhysicsWorldState >> restitutionThreshold [
	"Minimum collision speed for restitution in physics length units per second."
	^ restitutionThreshold
]

{ #category : 'accessing' }
CFPhysicsWorldState >> restitutionThreshold: aNumber [ restitutionThreshold := aNumber ]

{ #category : 'accessing' }
CFPhysicsWorldState >> collisionSuppressedBodyPairs [ ^ collisionSuppressedBodyPairs ]

{ #category : 'accessing' }
CFPhysicsWorldState >> collisionSuppressedBodyPairs: aCollection [
	collisionSuppressedBodyPairs := aCollection asArray
]

{ #category : 'accessing' }
CFPhysicsWorldState >> bodyStates [ ^ bodyStates ]

{ #category : 'accessing' }
CFPhysicsWorldState >> bodyStates: aDictionary [ bodyStates := aDictionary ]

{ #category : 'accessing' }
CFPhysicsWorldState >> orderedBodyStates [ ^ orderedBodyStates ]

{ #category : 'accessing' }
CFPhysicsWorldState >> orderedBodyStates: aCollection [
	orderedBodyStates := aCollection asArray
]


{ #category : 'accessing - solution identity' }
CFPhysicsWorldState >> world [ ^ world ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldState >> world: aWorld [ world := aWorld ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldState >> lifetimeGeneration [ ^ lifetimeGeneration ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldState >> lifetimeGeneration: anInteger [ lifetimeGeneration := anInteger ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldState >> topologyRevision [ ^ topologyRevision ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldState >> topologyRevision: anInteger [ topologyRevision := anInteger ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldState >> solveTicket [ ^ solveTicket ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldState >> solveTicket: anInteger [ solveTicket := anInteger ]


{ #category : 'accessing - visual state' }
CFPhysicsWorldState >> calculationVisualState [
	^ calculationVisualState
]

{ #category : 'accessing - visual state' }
CFPhysicsWorldState >> calculationVisualState: aVisualState [
	calculationVisualState := aVisualState
]

{ #category : 'accessing - islands' }
CFPhysicsWorldState >> islandBodyGroups [
	"Detached body-membership snapshots of the persistent islands captured for this solve."
	^ islandBodyGroups
]

{ #category : 'accessing - islands' }
CFPhysicsWorldState >> islandBodyGroups: aCollection [
	islandBodyGroups := aCollection collect: [ :group | group asArray ]
]

