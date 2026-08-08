"I provide the coordinate context shared by Physics overlay visuals. Physics-to-Bloc presentation conversion belongs to BVC-Physics-Bloc; I only adapt displayed Bloc points into overlay-local coordinates."
Class {
	#name : 'CFPhysicsOverlayContext',
	#superclass : 'Object',
	#instVars : [ 'host', 'world', 'overlay' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
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
	"Physics-to-Bloc presentation coordinates belong to the Bloc integration seam.
	The overlay only converts the resulting displayed global point into its own
	local coordinate system."
	^ overlay root globalPointToLocal:
		(CFPhysicsBlocPresentationCoordinates
			globalPointForWorldPoint: aPoint
			inWorld: world)
]

{ #category : 'geometry' }
CFPhysicsOverlayContext >> overlayPointFromWorld: aPoint attachedTo: aBody [
	"Body presentation, Motion interpolation and containment coordinate semantics
	are resolved by the Physics-Bloc seam, not by diagnostic tooling."
	^ overlay root globalPointToLocal:
		(CFPhysicsBlocPresentationCoordinates
			globalPointForWorldPoint: aPoint
			attachedTo: aBody
			inWorld: world)
]

