"I am a minimal test constraint used by focused island examples. I expose only the runtime endpoints required by the island graph and builder."
Class {
	#name : 'CFPhysicsTestConstraint',
	#superclass : 'Object',
	#instVars : [ 'bodyA', 'bodyB' ],
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'accessing' }
CFPhysicsTestConstraint >> bodyA [
	^ bodyA
]

{ #category : 'accessing' }
CFPhysicsTestConstraint >> bodyA: aBody [
	bodyA := aBody
]

{ #category : 'accessing' }
CFPhysicsTestConstraint >> bodyB [
	^ bodyB
]

{ #category : 'accessing' }
CFPhysicsTestConstraint >> bodyB: aBody [
	bodyB := aBody
]
