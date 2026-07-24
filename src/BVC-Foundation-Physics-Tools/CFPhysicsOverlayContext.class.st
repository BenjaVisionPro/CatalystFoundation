Class {
	#name : 'CFPhysicsOverlayContext',
	#superclass : 'Object',
	#instVars : [ 'host', 'world', 'overlay' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsOverlayContext class >> host: aHostElement world: aWorld overlay: anOverlay [
	^ self new
		host: aHostElement;
		world: aWorld;
		overlay: anOverlay;
		yourself
]

{ #category : 'accessing' }
CFPhysicsOverlayContext >> host [ ^ host ]

{ #category : 'accessing' }
CFPhysicsOverlayContext >> host: anElement [ host := anElement ]

{ #category : 'accessing' }
CFPhysicsOverlayContext >> world [ ^ world ]

{ #category : 'accessing' }
CFPhysicsOverlayContext >> world: aWorld [ world := aWorld ]

{ #category : 'accessing' }
CFPhysicsOverlayContext >> overlay [ ^ overlay ]

{ #category : 'accessing' }
CFPhysicsOverlayContext >> overlay: anOverlay [ overlay := anOverlay ]

{ #category : 'geometry' }
CFPhysicsOverlayContext >> overlayPoint: aPoint from: anElement [
	^ overlay root globalPointToLocal: (anElement localPointToGlobal: aPoint)
]

{ #category : 'geometry' }
CFPhysicsOverlayContext >> overlayPointFromWorld: aPoint [
	^ overlay root globalPointToLocal: (host localPointToGlobal: aPoint)
]
