Class {
	#name : 'CFPhysicsTimeOfImpactResult',
	#superclass : 'Object',
	#instVars : [ 'status', 'fraction', 'distanceResult', 'iterations' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsTimeOfImpactResult class >> status: aSymbol fraction: aNumber distanceResult: aDistanceResult iterations: anInteger [
	^ self new
		status: aSymbol;
		fraction: aNumber;
		distanceResult: aDistanceResult;
		iterations: anInteger;
		yourself
]

{ #category : 'accessing' }
CFPhysicsTimeOfImpactResult >> distanceResult [
	^ distanceResult
]

{ #category : 'accessing' }
CFPhysicsTimeOfImpactResult >> distanceResult: aDistanceResult [
	distanceResult := aDistanceResult
]

{ #category : 'accessing' }
CFPhysicsTimeOfImpactResult >> fraction [
	^ fraction
]

{ #category : 'accessing' }
CFPhysicsTimeOfImpactResult >> fraction: aNumber [
	fraction := aNumber
]

{ #category : 'testing' }
CFPhysicsTimeOfImpactResult >> hasImpact [
	^ status = #impact
]

{ #category : 'accessing' }
CFPhysicsTimeOfImpactResult >> iterations [
	^ iterations
]

{ #category : 'accessing' }
CFPhysicsTimeOfImpactResult >> iterations: anInteger [
	iterations := anInteger
]

{ #category : 'testing' }
CFPhysicsTimeOfImpactResult >> isIterationLimit [
	^ status = #iterationLimit
]

{ #category : 'testing' }
CFPhysicsTimeOfImpactResult >> isSeparated [
	^ status = #separated
]

{ #category : 'accessing' }
CFPhysicsTimeOfImpactResult >> status [
	^ status
]

{ #category : 'accessing' }
CFPhysicsTimeOfImpactResult >> status: aSymbol [
	status := aSymbol
]
