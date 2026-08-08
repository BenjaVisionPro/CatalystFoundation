Extension { #name : 'CFPhysicsWorld' }

{ #category : '*BVC-Physics-Bloc' }
CFPhysicsWorld >> blocGlobalPointForWorldPoint: aPoint [
	"Convert a Physics world point into the point currently displayed by Bloc.
	Physics world coordinates are expressed in the owner's children coordinate
	system, so cross that boundary through Bloc rather than treating them as owner
	local coordinates."
	^ self owner localPointToGlobal: (self owner childrenPointToLocal: aPoint)
]

{ #category : '*BVC-Physics-Bloc' }
CFPhysicsWorld >> blocGlobalPointForWorldPoint: aPoint attachedTo: aBody [
	"Convert a Physics world point owned by a body into its currently displayed
	Bloc point. Ordinary bodies follow their element's presented transformation,
	which includes Motion interpolation. The containment body is world geometry:
	its chain is expressed directly in the owner's children coordinate system and
	must therefore use the world conversion path."
	| bodyLocalPoint elementLocalPoint |
	aBody ifNil: [ ^ self blocGlobalPointForWorldPoint: aPoint ].
	aBody == self containmentBoundaryBody ifTrue: [
		^ self blocGlobalPointForWorldPoint: aPoint ].
	bodyLocalPoint := aBody bodyLocalPointForWorldPoint: aPoint.
	elementLocalPoint := aBody shapeState
		elementLocalPointForBodyLocalPoint: bodyLocalPoint.
	^ aBody element localPointToGlobal: elementLocalPoint
]
