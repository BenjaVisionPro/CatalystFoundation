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
	"Convert displayed element geometry directly through Bloc's element-to-global
	transform. Mondrian may apply child presentation transforms that are not
	represented as ordinary coordinates in the Physics host, so this path must not
	round-trip through the host's local coordinate system."
	^ overlay root globalPointToLocal: (anElement localPointToGlobal: aPoint)
]

{ #category : 'geometry' }
CFPhysicsOverlayContext >> overlayPointFromWorld: aPoint [
	"Convert a Physics-world point from the world owner's local coordinate system
	into overlay-local coordinates. Mondrian fixes its root children presentation
	to identity while Physics is active, so no children transformation belongs in
	this path."
	^ self overlayPointInHost: aPoint
]

{ #category : 'geometry' }
CFPhysicsOverlayContext >> overlayPointInHost: aPoint [
	"Convert a point expressed in the Physics host's local coordinates into
	overlay-local coordinates."
	^ overlay root globalPointToLocal: (host localPointToGlobal: aPoint)
]
