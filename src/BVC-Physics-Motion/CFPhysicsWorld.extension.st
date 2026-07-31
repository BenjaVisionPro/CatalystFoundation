Extension { #name : 'CFPhysicsWorld' }

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> present [
	(CFPhysicsWorldMotionIntegration for: self) present.
	^ self
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> presentAtAlpha: aNumber [
	(CFPhysicsWorldMotionIntegration for: self) presentAtAlpha: aNumber.
	^ self
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> stepAndPresent [
	^ (CFPhysicsWorldMotionIntegration for: self) stepAndPresent
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> startStepping [
	^ (CFPhysicsWorldMotionIntegration for: self) startStepping
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> pauseStepping [
	(CFPhysicsWorldMotionIntegration for: self) pauseStepping.
	^ self
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> resumeStepping [
	(CFPhysicsWorldMotionIntegration for: self) resumeStepping.
	^ self
]

{ #category : '*BVC-Physics-Motion' }
CFPhysicsWorld >> stopStepping [
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
	^ (CFPhysicsWorldMotionIntegration for: self) startBackgroundStep
]
