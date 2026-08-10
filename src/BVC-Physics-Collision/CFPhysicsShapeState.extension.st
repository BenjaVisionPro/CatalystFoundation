Extension { #name : 'CFPhysicsShapeState' }

{ #category : '*BVC-Physics-Collision' }
CFPhysicsShapeState >> distanceProxy [
	| anExtent centre cornerRadius |
	anExtent := self extent.
	centre := anExtent / 2.0.
	self isCircle ifTrue: [
		^ CFPhysicsDistanceProxy points: { 0 @ 0 } radius: self radius ].
	self isRoundedRectangle ifTrue: [
		cornerRadius := self roundedRectangleRadius.
		^ CFPhysicsDistanceProxy
			points: {
				(cornerRadius @ cornerRadius) - centre.
				((anExtent x - cornerRadius) @ cornerRadius) - centre.
				((anExtent x - cornerRadius) @ (anExtent y - cornerRadius)) - centre.
				(cornerRadius @ (anExtent y - cornerRadius)) - centre }
			radius: cornerRadius ].
	^ CFPhysicsDistanceProxy
		points: (self localCollisionVertices collect: [ :each | each - centre ])
		radius: 0.0
]
