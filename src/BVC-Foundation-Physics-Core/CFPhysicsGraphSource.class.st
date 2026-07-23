"
I adapt a domain-specific graph to the small protocol required by force-directed Physics Behaviours.

My collections retain their supplied order. Blocks may be replaced independently so a changing domain model is observed at each physics step.
"
Class {
	#name : 'CFPhysicsGraphSource',
	#superclass : 'Object',
	#instVars : [ 'nodesBlock', 'edgesBlock', 'sourceBlock', 'targetBlock' ],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsGraphSource class >> nodes: aNodesBlock edges: anEdgesBlock source: aSourceBlock target: aTargetBlock [
	^ self new
		nodesBlock: aNodesBlock;
		edgesBlock: anEdgesBlock;
		sourceBlock: aSourceBlock;
		targetBlock: aTargetBlock;
		yourself
]

{ #category : 'initialization' }
CFPhysicsGraphSource >> initialize [
	super initialize.
	nodesBlock := [ #() ].
	edgesBlock := [ #() ].
	sourceBlock := [ :edge | edge key ].
	targetBlock := [ :edge | edge value ]
]

{ #category : 'accessing' }
CFPhysicsGraphSource >> nodes [ ^ nodesBlock value asArray ]

{ #category : 'accessing' }
CFPhysicsGraphSource >> edges [ ^ edgesBlock value asArray ]

{ #category : 'accessing' }
CFPhysicsGraphSource >> sourceForEdge: anEdge [ ^ sourceBlock value: anEdge ]

{ #category : 'accessing' }
CFPhysicsGraphSource >> targetForEdge: anEdge [ ^ targetBlock value: anEdge ]

{ #category : 'configuration' }
CFPhysicsGraphSource >> nodesBlock: aBlock [ nodesBlock := aBlock ]

{ #category : 'configuration' }
CFPhysicsGraphSource >> edgesBlock: aBlock [ edgesBlock := aBlock ]

{ #category : 'configuration' }
CFPhysicsGraphSource >> sourceBlock: aBlock [ sourceBlock := aBlock ]

{ #category : 'configuration' }
CFPhysicsGraphSource >> targetBlock: aBlock [ targetBlock := aBlock ]
