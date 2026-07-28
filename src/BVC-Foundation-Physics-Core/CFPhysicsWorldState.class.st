Class {
	#name : 'CFPhysicsWorldState',
	#superclass : 'Object',
	#instVars : [ 'bodies', 'contacts', 'calculationContacts', 'joints', 'step', 'gravity', 'restitutionThreshold', 'explicitlyContainedBodies', 'collisionSuppressedBodyPairs', 'bodyStates', 'orderedBodyStates' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsWorldState >> initialize [
	super initialize.
	bodies := #().
	contacts := #().
	calculationContacts := #().
	joints := #().
	explicitlyContainedBodies := #().
	collisionSuppressedBodyPairs := #().
	bodyStates := IdentityDictionary new.
	orderedBodyStates := #()
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
CFPhysicsWorldState >> gravity [ ^ gravity ]

{ #category : 'accessing' }
CFPhysicsWorldState >> gravity: aPoint [ gravity := aPoint ]

{ #category : 'accessing' }
CFPhysicsWorldState >> restitutionThreshold [ ^ restitutionThreshold ]

{ #category : 'accessing' }
CFPhysicsWorldState >> restitutionThreshold: aNumber [ restitutionThreshold := aNumber ]

{ #category : 'accessing' }
CFPhysicsWorldState >> explicitlyContainedBodies [ ^ explicitlyContainedBodies ]

{ #category : 'accessing' }
CFPhysicsWorldState >> explicitlyContainedBodies: aCollection [
	explicitlyContainedBodies := aCollection asArray
]

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
