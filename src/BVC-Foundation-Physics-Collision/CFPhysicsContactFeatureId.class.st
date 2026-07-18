Class {
	#name : 'CFPhysicsContactFeatureId',
	#superclass : 'Object',
	#instVars : [ 'featureA', 'indexA', 'featureB', 'indexB' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsContactFeatureId class >> featureA: firstFeature index: firstIndex featureB: secondFeature index: secondIndex [
	^ self new
		featureA: firstFeature;
		indexA: firstIndex;
		featureB: secondFeature;
		indexB: secondIndex;
		yourself
]

{ #category : 'comparing' }
CFPhysicsContactFeatureId >> = another [
	^ self class = another class
		and: [ featureA = another featureA
		and: [ indexA = another indexA
		and: [ featureB = another featureB
		and: [ indexB = another indexB ] ] ] ]
]

{ #category : 'comparing' }
CFPhysicsContactFeatureId >> hash [
	^ featureA hash bitXor: (indexA hash bitXor: (featureB hash bitXor: indexB hash))
]

{ #category : 'accessing' }
CFPhysicsContactFeatureId >> featureA [ ^ featureA ]
{ #category : 'accessing' }
CFPhysicsContactFeatureId >> featureA: anObject [ featureA := anObject ]
{ #category : 'accessing' }
CFPhysicsContactFeatureId >> indexA [ ^ indexA ]
{ #category : 'accessing' }
CFPhysicsContactFeatureId >> indexA: anInteger [ indexA := anInteger ]
{ #category : 'accessing' }
CFPhysicsContactFeatureId >> featureB [ ^ featureB ]
{ #category : 'accessing' }
CFPhysicsContactFeatureId >> featureB: anObject [ featureB := anObject ]
{ #category : 'accessing' }
CFPhysicsContactFeatureId >> indexB [ ^ indexB ]
{ #category : 'accessing' }
CFPhysicsContactFeatureId >> indexB: anInteger [ indexB := anInteger ]
