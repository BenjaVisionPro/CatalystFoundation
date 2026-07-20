Class {
	#name : 'CFPhysicsContinuousImpactLoopResult',
	#superclass : 'Object',
	#instVars : [ 'impacts', 'impactSolveResults', 'bodyStates', 'remainingTime', 'iterationLimitReached' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContinuousImpactLoopResult class >> impacts: impacts impactSolveResults: solveResults bodyStates: aDictionary remainingTime: seconds iterationLimitReached: aBoolean [
	^ self new
		impacts: impacts;
		impactSolveResults: solveResults;
		bodyStates: aDictionary;
		remainingTime: seconds;
		iterationLimitReached: aBoolean;
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
