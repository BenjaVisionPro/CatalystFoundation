Class {
	#name : 'CFPhysicsIslandSleepDecision',
	#superclass : 'Object',
	#instVars : [ 'island', 'wokeBodies', 'eligible', 'minimumSleepTime', 'slept' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsIslandSleepDecision >> initialize [
	super initialize.
	wokeBodies := #().
	eligible := false.
	minimumSleepTime := 0.0.
	slept := false
]

{ #category : 'accessing' }
CFPhysicsIslandSleepDecision >> island [ ^ island ]
{ #category : 'accessing' }
CFPhysicsIslandSleepDecision >> island: anIsland [ island := anIsland ]
{ #category : 'accessing' }
CFPhysicsIslandSleepDecision >> wokeBodies [ ^ wokeBodies ]
{ #category : 'accessing' }
CFPhysicsIslandSleepDecision >> wokeBodies: aCollection [ wokeBodies := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsIslandSleepDecision >> eligible [ ^ eligible ]
{ #category : 'accessing' }
CFPhysicsIslandSleepDecision >> eligible: aBoolean [ eligible := aBoolean ]
{ #category : 'accessing' }
CFPhysicsIslandSleepDecision >> minimumSleepTime [ ^ minimumSleepTime ]
{ #category : 'accessing' }
CFPhysicsIslandSleepDecision >> minimumSleepTime: aNumber [ minimumSleepTime := aNumber ]
{ #category : 'accessing' }
CFPhysicsIslandSleepDecision >> slept [ ^ slept ]
{ #category : 'accessing' }
CFPhysicsIslandSleepDecision >> slept: aBoolean [ slept := aBoolean ]
