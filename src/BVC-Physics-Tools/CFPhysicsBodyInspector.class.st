"I present the live diagnostic state of one Physics body."
Class {
	#name : 'CFPhysicsBodyInspector',
	#superclass : 'CFPhysicsOverlayInspector',
	#instVars : [ 'physics' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'accessing' }
CFPhysicsBodyInspector >> physics [ ^ physics ]

{ #category : 'initialization' }
CFPhysicsBodyInspector >> configureInspector [
	self addTitle: 'PHYSICS OBJECT'.
	self addGroup: 'Transform' fields: {
		#position -> 'Position'.
		#rotation -> 'Rotation' }.
	self addGroup: 'Motion' fields: {
		#velocity -> 'Linear velocity'.
		#angularVelocity -> 'Angular velocity' }.
	self addGroup: 'State' fields: {
		#bodyType -> 'Body type'.
		#awake -> 'Awake'.
		#sensor -> 'Sensor' }.
	self addGroup: 'Material' fields: {
		#density -> 'Density'.
		#friction -> 'Friction'.
		#restitution -> 'Restitution' }
]

{ #category : 'inspecting' }
CFPhysicsBodyInspector >> inspect: aPhysics [
	physics := aPhysics.
	self refresh.
	^ self
]

{ #category : 'clearing' }
CFPhysicsBodyInspector >> clear [
	physics := nil.
	self clearValues.
	^ self
]

{ #category : 'updating' }
CFPhysicsBodyInspector >> refresh [
	physics ifNil: [ ^ self ].
	self diagnosticPoint: physics position at: #position.
	self diagnosticNumber: physics rotation at: #rotation.
	self diagnosticPoint: physics velocity at: #velocity.
	self diagnosticNumber: physics angularVelocity at: #angularVelocity.
	self text: physics bodyTypeName at: #bodyType.
	self text: physics isAwake printString at: #awake.
	self text: physics isSensor printString at: #sensor.
	self diagnosticNumber: physics density at: #density.
	self diagnosticNumber: physics friction at: #friction.
	self diagnosticNumber: physics restitution at: #restitution.
	^ self
]
