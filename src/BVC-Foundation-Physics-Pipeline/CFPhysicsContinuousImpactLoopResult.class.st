Class {
	#name : 'CFPhysicsContinuousImpactLoopResult',
	#superclass : 'Object',
	#instVars : [ 'impacts', 'impactSolveResults', 'sensorContacts', 'bodyStates', 'remainingTime', 'iterationLimitReached', 'completedBodies' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContinuousImpactLoopResult class >> impacts: impacts impactSolveResults: solveResults sensorContacts: contacts bodyStates: aDictionary remainingTime: seconds iterationLimitReached: aBoolean completedBodies: bodies [
	^ self new
		impacts: impacts;
		impactSolveResults: solveResults;
		sensorContacts: contacts;
		bodyStates: aDictionary;
		remainingTime: seconds;
		iterationLimitReached: aBoolean;
		completedBodies: bodies;
		yourself
]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> impacts [ ^ impacts ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> impacts: aCollection [ impacts := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> impactSolveResults [ ^ impactSolveResults ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> impactSolveResults: aCollection [ impactSolveResults := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> sensorContacts [ ^ sensorContacts ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> sensorContacts: aCollection [ sensorContacts := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> bodyStates [ ^ bodyStates ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> bodyStates: aDictionary [ bodyStates := aDictionary ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> remainingTime [ ^ remainingTime ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> remainingTime: seconds [ remainingTime := seconds ]

{ #category : 'testing' }
CFPhysicsContinuousImpactLoopResult >> iterationLimitReached [ ^ iterationLimitReached ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> iterationLimitReached: aBoolean [ iterationLimitReached := aBoolean ]

{ #category : 'testing' }
CFPhysicsContinuousImpactLoopResult >> hasImpacts [ ^ impacts notEmpty ]

{ #category : 'testing' }
CFPhysicsContinuousImpactLoopResult >> hasImpact [
	^ self hasImpacts
]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> impact [
	^ impacts
		ifEmpty: [ nil ]
		ifNotEmpty: [ impacts last ]
]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> impactSolveResult [
	^ impactSolveResults
		ifEmpty: [ nil ]
		ifNotEmpty: [ impactSolveResults last ]
]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> fraction [
	^ impacts
		ifEmpty: [ nil ]
		ifNotEmpty: [ impacts first fraction ]
]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> completedBodies [ ^ completedBodies ]

{ #category : 'accessing' }
CFPhysicsContinuousImpactLoopResult >> completedBodies: aCollection [ completedBodies := aCollection asArray ]
