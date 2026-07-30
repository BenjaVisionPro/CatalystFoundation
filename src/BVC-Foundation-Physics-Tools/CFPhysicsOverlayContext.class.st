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
	into overlay-local coordinates. Physics positions describe the owner's child
	coordinate system; a Mondrian root may scale or translate that system for its
	graph presentation. Apply that children transformation before crossing into
	the overlay's sibling coordinate system."
	^ self overlayPointInHost: (host childrenPointToLocal: aPoint)
]

{ #category : 'geometry' }
CFPhysicsOverlayContext >> overlayPointFromWorld: aPoint attachedTo: aBody [
	"Resolve a solver-world point through the body that owns it when one is
	available. Invert CFPhysicsBody>>worldPointForLocalPoint: exactly here rather
	than using the shape-state collision-space conversion, which rotates around
	the shape centre and causes retained diagnostics to drift as the body rotates.
	World anchors deliberately remain in world coordinates."
	| localPoint |
	aBody ifNil: [ ^ self overlayPointFromWorld: aPoint ].
	localPoint := aBody shapeState
		rotateVector: aPoint - aBody position
		by: aBody rotation negated.
	^ self overlayPoint: localPoint from: aBody element
]

{ #category : 'geometry' }
CFPhysicsOverlayContext >> overlayPointInHost: aPoint [
	"Convert a point expressed in the displayed Physics host child coordinates into
	overlay-local coordinates."
	^ overlay root globalPointToLocal: (host localPointToGlobal: aPoint)
]
