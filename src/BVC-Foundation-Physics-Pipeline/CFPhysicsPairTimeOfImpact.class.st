Class {
	#name : 'CFPhysicsPairTimeOfImpact',
	#superclass : 'Object',
	#instVars : [ 'pair', 'timeOfImpactResult' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsPairTimeOfImpact class >> pair: aPair result: aTimeOfImpactResult [
	^ self new
		pair: aPair;
		timeOfImpactResult: aTimeOfImpactResult;
		yourself
]

{ #category : 'accessing' }
CFPhysicsPairTimeOfImpact >> pair [
	^ pair
]

{ #category : 'accessing' }
CFPhysicsPairTimeOfImpact >> pair: aPair [
	pair := aPair
]

{ #category : 'accessing' }
CFPhysicsPairTimeOfImpact >> timeOfImpactResult [
	^ timeOfImpactResult
]

{ #category : 'accessing' }
CFPhysicsPairTimeOfImpact >> timeOfImpactResult: aTimeOfImpactResult [
	timeOfImpactResult := aTimeOfImpactResult
]

{ #category : 'accessing' }
CFPhysicsPairTimeOfImpact >> fraction [
	^ timeOfImpactResult fraction
]
