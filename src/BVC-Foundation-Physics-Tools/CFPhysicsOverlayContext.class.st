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
	"Convert displayed geometry from an element's local coordinates into the
	Physics host's coordinates, then use the one host-to-overlay boundary shared
	by all diagnostics."
	^ self overlayPointInHost:
		(host globalPointToLocal: (anElement localPointToGlobal: aPoint))
]

{ #category : 'geometry' }
CFPhysicsOverlayContext >> overlayPointFromWorld: aPoint [
	"Physics world coordinates are the owner's local coordinates. Contacts,
	joints and other world diagnostics therefore enter the same host-to-overlay
	boundary directly; they must not be routed through either body."
	^ self overlayPointInHost: aPoint
]

{ #category : 'geometry' }
CFPhysicsOverlayContext >> overlayPointInHost: aPoint [
	"The single conversion from Physics-host coordinates into overlay-local
	coordinates. Both displayed element geometry and world geometry finish here."
	^ overlay root globalPointToLocal: (host localPointToGlobal: aPoint)
]
