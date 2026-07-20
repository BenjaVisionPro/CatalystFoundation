Extension { #name : 'CFPhysicsWorld' }

{ #category : '*BVC-Foundation-Physics-Motion - presenting' }
CFPhysicsWorld >> present [
	CFPhysicsWorldMotionIntegration for: self present.
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion - presenting' }
CFPhysicsWorld >> presentAtAlpha: aNumber [
	(CFPhysicsWorldMotionIntegration for: self) presentAtAlpha: aNumber.
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion - presenting' }
CFPhysicsWorld >> stepAndPresent [
	^ (CFPhysicsWorldMotionIntegration for: self) stepAndPresent
]

{ #category : '*BVC-Foundation-Physics-Motion - continuous stepping' }
CFPhysicsWorld >> startStepping [
	^ (CFPhysicsWorldMotionIntegration for: self) startStepping
]

{ #category : '*BVC-Foundation-Physics-Motion - continuous stepping' }
CFPhysicsWorld >> pauseStepping [
	(CFPhysicsWorldMotionIntegration for: self) pauseStepping.
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion - continuous stepping' }
CFPhysicsWorld >> resumeStepping [
	(CFPhysicsWorldMotionIntegration for: self) resumeStepping.
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion - continuous stepping' }
CFPhysicsWorld >> stopStepping [
	(CFPhysicsWorldMotionIntegration for: self) stopStepping.
	^ self
]

{ #category : '*BVC-Foundation-Physics-Motion - testing' }
CFPhysicsWorld >> isStepping [
	^ (CFPhysicsWorldMotionIntegration existingFor: self)
		ifNil: [ false ]
		ifNotNil: [ :anIntegration | anIntegration isStepping ]
]

{ #category : '*BVC-Foundation-Physics-Motion - private - lifecycle' }
CFPhysicsWorld >> physicsOwnerWillChange [
	CFPhysicsWorldMotionIntegration releaseFor: self
]
