Extension { #name : 'CFPhysicsWorld' }

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysicsWorld >> present [
	CFPhysicsWorldMotionIntegration for: self present.
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysicsWorld >> presentAtAlpha: aNumber [
	(CFPhysicsWorldMotionIntegration for: self) presentAtAlpha: aNumber.
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysicsWorld >> stepAndPresent [
	^ (CFPhysicsWorldMotionIntegration for: self) stepAndPresent
]

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysicsWorld >> startStepping [
	^ (CFPhysicsWorldMotionIntegration for: self) startStepping
]

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysicsWorld >> pauseStepping [
	(CFPhysicsWorldMotionIntegration for: self) pauseStepping.
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysicsWorld >> resumeStepping [
	(CFPhysicsWorldMotionIntegration for: self) resumeStepping.
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysicsWorld >> stopStepping [
	(CFPhysicsWorldMotionIntegration for: self) stopStepping.
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysicsWorld >> isStepping [
	^ (CFPhysicsWorldMotionIntegration existingFor: self)
		ifNil: [ false ]
		ifNotNil: [ :anIntegration | anIntegration isStepping ]
]

{ #category : '*BVC-Foundation-Physics-Motion' }
CFPhysicsWorld >> physicsOwnerWillChange [
	CFPhysicsWorldMotionIntegration releaseFor: self
]
