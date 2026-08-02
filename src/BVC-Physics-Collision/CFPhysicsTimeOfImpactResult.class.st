"
I describe the outcome of a continuous collision time-of-impact query.

I record the status, swept fraction, final distance result and iteration count so the pipeline can distinguish impact, overlap, separation and algorithm failure.
"
Class {
	#name : 'CFPhysicsTimeOfImpactResult',
	#superclass : 'Object',
	#instVars : [ 'status', 'fraction', 'distanceResult', 'iterations' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
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
CFPhysicsTimeOfImpactResult >> isFailed [
	^ status = #failed
]

{ #category : 'testing' }
CFPhysicsTimeOfImpactResult >> isOverlapped [
	^ status = #overlapped
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
