Class {
	#name : 'CFPhysicsTelemetrySpanStatistics',
	#superclass : 'Object',
	#instVars : [ 'name', 'depth', 'averageStart', 'averageDuration', 'p95Start', 'p95Duration', 'children' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> name [ ^ name ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> name: anObject [ name := anObject ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> depth [ ^ depth ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> depth: anInteger [ depth := anInteger ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> averageStart [ ^ averageStart ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> averageStart: aNumber [ averageStart := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> averageDuration [ ^ averageDuration ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> averageDuration: aNumber [ averageDuration := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p95Start [ ^ p95Start ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p95Start: aNumber [ p95Start := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p95Duration [ ^ p95Duration ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p95Duration: aNumber [ p95Duration := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> children [ ^ children ifNil: [ #() ] ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> children: aCollection [ children := aCollection ]

{ #category : 'enumerating' }
CFPhysicsTelemetrySpanStatistics >> allSpansDo: aBlock [
	aBlock value: self.
	self children do: [ :each | each allSpansDo: aBlock ]
]


{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> readableName [
	| value |
	value := self name asString.
	value := value copyReplaceAll: 'CFPhysics' with: ''.
	value := value copyReplaceAll: 'Stage' with: ''.
	^ value
]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> averageMilliseconds [
	^ self averageDuration / 1000.0
]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> p95Milliseconds [
	^ self p95Duration / 1000.0
]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> p95ToAverageRatio [
	^ self averageDuration = 0
		ifTrue: [ 0 ]
		ifFalse: [ self p95Duration / self averageDuration ]
]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> averageShareOf: aRootSpan [
	^ aRootSpan averageDuration = 0
		ifTrue: [ 0 ]
		ifFalse: [ self averageDuration / aRootSpan averageDuration ]
]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> p95ShareOf: aRootSpan [
	^ aRootSpan p95Duration = 0
		ifTrue: [ 0 ]
		ifFalse: [ self p95Duration / aRootSpan p95Duration ]
]
