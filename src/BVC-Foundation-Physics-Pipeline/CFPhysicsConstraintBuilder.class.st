Class {
	#name : 'CFPhysicsConstraintBuilder',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsConstraintBuilder >> constraintsFrom: contacts [
	^ contacts collect: [ :contact | CFPhysicsPreparedConstraint fromContact: contact ]
]
