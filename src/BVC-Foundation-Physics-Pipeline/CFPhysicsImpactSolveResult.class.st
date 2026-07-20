Class {
	#name : 'CFPhysicsImpactSolveResult',
	#superclass : 'Object',
	#instVars : [ 'advancement', 'contact', 'constraints' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsImpactSolveResult class >> advancement: anAdvancement contact: aContact constraints: aCollection [
	^ self new
		advancement: anAdvancement;
		contact: aContact;
		constraints: aCollection;
		yourself
]

{ #category : 'accessing' }
CFPhysicsImpactSolveResult >> advancement [ ^ advancement ]

{ #category : 'accessing' }
CFPhysicsImpactSolveResult >> advancement: anObject [ advancement := anObject ]

{ #category : 'accessing' }
CFPhysicsImpactSolveResult >> contact [ ^ contact ]

{ #category : 'accessing' }
CFPhysicsImpactSolveResult >> contact: anObject [ contact := anObject ]

{ #category : 'accessing' }
CFPhysicsImpactSolveResult >> constraints [ ^ constraints ]

{ #category : 'accessing' }
CFPhysicsImpactSolveResult >> constraints: aCollection [ constraints := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsImpactSolveResult >> remainingTime [ ^ advancement remainingTime ]

{ #category : 'testing' }
CFPhysicsImpactSolveResult >> hasContact [ ^ contact notNil ]
