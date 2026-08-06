Extension { #name : 'CFPhysicsWorld' }

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> present [
	self assertNotReleased.
	(CFPhysicsWorldMotionIntegration for: self) present.
	^ self
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> presentAtAlpha: aNumber [
	self assertNotReleased.
	(CFPhysicsWorldMotionIntegration for: self) presentAtAlpha: aNumber.
	^ self
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> stepAndPresent [
	self assertNotReleased.
	^ (CFPhysicsWorldMotionIntegration for: self) stepAndPresent
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> startStepping [
	self assertNotReleased.
	^ (CFPhysicsWorldMotionIntegration for: self) startStepping
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> pauseStepping [
	self assertNotReleased.
	(CFPhysicsWorldMotionIntegration for: self) pauseStepping.
	^ self
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> resumeStepping [
	self assertNotReleased.
	(CFPhysicsWorldMotionIntegration for: self) resumeStepping.
	^ self
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> stopStepping [
	self assertNotReleased.
	(CFPhysicsWorldMotionIntegration for: self) stopStepping.
	^ self
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> isStepping [
	^ (CFPhysicsWorldMotionIntegration existingFor: self)
		ifNil: [ false ]
		ifNotNil: [ :anIntegration | anIntegration isStepping ]
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> physicsOwnerWillChange [
	CFPhysicsWorldMotionIntegration releaseFor: self
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> startBackgroundStep [
	self assertNotReleased.
	^ (CFPhysicsWorldBackgroundStep on: self) start
]
