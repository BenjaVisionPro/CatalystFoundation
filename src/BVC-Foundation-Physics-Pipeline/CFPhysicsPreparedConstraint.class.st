Class {
	#name : 'CFPhysicsPreparedConstraint',
	#superclass : 'Object',
	#instVars : [ 'contact', 'bodyStateA', 'bodyStateB', 'normal', 'tangent', 'friction', 'restitution', 'points' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'writing back' }
CFPhysicsPreparedConstraint >> writeImpulsesBack [
	points do: [ :point | point writeImpulsesBack ]
]

{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> contact [ ^ contact ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> contact: anObject [ contact := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> bodyStateA [ ^ bodyStateA ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> bodyStateA: anObject [ bodyStateA := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> bodyStateB [ ^ bodyStateB ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> bodyStateB: anObject [ bodyStateB := anObject ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> normal [ ^ normal ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> normal: aPoint [ normal := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> tangent [ ^ tangent ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> tangent: aPoint [ tangent := aPoint ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> friction [ ^ friction ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> friction: aNumber [ friction := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> restitution [ ^ restitution ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> restitution: aNumber [ restitution := aNumber ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> points [ ^ points ]
{ #category : 'accessing' }
CFPhysicsPreparedConstraint >> points: aCollection [ points := aCollection ]
