"
I represent a Box2D-style chain macro object.

I own ordered local vertices and the chain-segment shapes built from them. Chains are massless collision geometry intended for static bodies.
"
Class {
	#name : 'CFPhysicsChain',
	#superclass : 'Object',
	#instVars : [ 'vertices', 'segments', 'material', 'collisionFilter', 'loop' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsChain >> initialize [
	super initialize.
	vertices := #().
	segments := #().
	loop := false
]

{ #category : 'accessing' }
CFPhysicsChain >> collisionFilter [ ^ collisionFilter ]

{ #category : 'accessing' }
CFPhysicsChain >> collisionFilter: aFilter [ collisionFilter := aFilter ]

{ #category : 'testing' }
CFPhysicsChain >> isLoop [ ^ loop ]

{ #category : 'accessing' }
CFPhysicsChain >> loop: aBoolean [ loop := aBoolean ]

{ #category : 'accessing' }
CFPhysicsChain >> material [ ^ material ]

{ #category : 'accessing' }
CFPhysicsChain >> material: aMaterial [ material := aMaterial ]

{ #category : 'accessing' }
CFPhysicsChain >> segments [ ^ segments ]

{ #category : 'accessing' }
CFPhysicsChain >> segments: aCollection [ segments := aCollection asArray copy ]

{ #category : 'accessing' }
CFPhysicsChain >> vertices [ ^ vertices ]

{ #category : 'accessing' }
CFPhysicsChain >> vertices: aCollection [ vertices := aCollection asArray copy ]
