Class {
	#name : 'CFPhysicsStageMetric',
	#superclass : 'Object',
	#instVars : [ 'stageClass', 'capacity', 'executions' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsStageMetric class >> forStageClass: aStageClass capacity: anInteger [
	^ self new
		stageClass: aStageClass;
		capacity: anInteger;
		yourself
]

{ #category : 'initialization' }
CFPhysicsStageMetric >> initialize [
	super initialize.
	capacity := 300.
	executions := OrderedCollection new
]

{ #category : 'accessing' }
CFPhysicsStageMetric >> stageClass [ ^ stageClass ]
{ #category : 'accessing' }
CFPhysicsStageMetric >> stageClass: aClass [ stageClass := aClass ]
{ #category : 'accessing' }
CFPhysicsStageMetric >> name [ ^ stageClass name ]
{ #category : 'accessing' }
CFPhysicsStageMetric >> capacity [ ^ capacity ]
{ #category : 'accessing' }
CFPhysicsStageMetric >> capacity: anInteger [
	capacity := anInteger max: 1.
	[ executions size > capacity ] whileTrue: [ executions removeFirst ].
	^ self
]
{ #category : 'accessing' }
CFPhysicsStageMetric >> executions [ ^ executions asArray ]
{ #category : 'accessing' }
CFPhysicsStageMetric >> sampleCount [ ^ executions size ]
{ #category : 'accessing' }
CFPhysicsStageMetric >> latestExecution [
	^ executions ifEmpty: [ nil ] ifNotEmpty: [ executions last ]
]
{ #category : 'accessing' }
CFPhysicsStageMetric >> latest [
	^ self latestExecution
		ifNil: [ 0.0 ]
		ifNotNil: [ :execution | execution durationMilliseconds ifNil: [ 0.0 ] ]
]
{ #category : 'recording' }
CFPhysicsStageMetric >> recordExecution: anExecution [
	executions add: anExecution.
	[ executions size > capacity ] whileTrue: [ executions removeFirst ].
	^ anExecution
]
{ #category : 'recording' }
CFPhysicsStageMetric >> reset [ executions removeAll. ^ self ]
{ #category : 'statistics' }
CFPhysicsStageMetric >> durationValues [
	^ self executions collect: [ :each | each durationMilliseconds ifNil: [ 0.0 ] ]
]
{ #category : 'statistics' }
CFPhysicsStageMetric >> average [
	| values |
	values := self durationValues.
	^ values ifEmpty: [ 0.0 ] ifNotEmpty: [ values average asFloat ]
]
{ #category : 'statistics' }
CFPhysicsStageMetric >> minimum [
	| values |
	values := self durationValues.
	^ values ifEmpty: [ 0.0 ] ifNotEmpty: [ values min ]
]
{ #category : 'statistics' }
CFPhysicsStageMetric >> maximum [
	| values |
	values := self durationValues.
	^ values ifEmpty: [ 0.0 ] ifNotEmpty: [ values max ]
]
{ #category : 'statistics' }
CFPhysicsStageMetric >> percentile: aFraction [
	| values index |
	values := self durationValues sorted.
	values ifEmpty: [ ^ 0.0 ].
	index := ((values size * aFraction) ceiling max: 1) min: values size.
	^ values at: index
]
{ #category : 'statistics' }
CFPhysicsStageMetric >> p95 [ ^ self percentile: 0.95 ]
