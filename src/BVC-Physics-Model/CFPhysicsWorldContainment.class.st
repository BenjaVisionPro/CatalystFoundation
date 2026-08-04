"
I configure containment for a Physics world.

I am enabled by default. My material and margin describe the internal static boundary chain that the world geometry will build. I do not move bodies or participate in stepping; containment enters the normal broadphase, contact and solver pipeline.
"
Class {
	#name : 'CFPhysicsWorldContainment',
	#superclass : 'Object',
	#instVars : [ 'enabled', 'margin', 'material' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsWorldContainment >> initialize [
	super initialize.
	enabled := true.
	margin := 0.0.
	material := CFPhysicsMaterial new
]

{ #category : 'controlling' }
CFPhysicsWorldContainment >> enable [
	enabled := true.
	^ self
]

{ #category : 'controlling' }
CFPhysicsWorldContainment >> disable [
	enabled := false.
	^ self
]

{ #category : 'testing' }
CFPhysicsWorldContainment >> isEnabled [
	^ enabled
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> margin [
	^ margin
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> margin: aNumber [
	margin := aNumber asFloat max: 0.0
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> material [
	^ material
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> friction [
	^ material friction
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> friction: aNumber [
	material friction: aNumber
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> restitution [
	^ material restitution
]

{ #category : 'accessing' }
CFPhysicsWorldContainment >> restitution: aNumber [
	material restitution: ((aNumber asFloat max: 0.0) min: 1.0)
]
