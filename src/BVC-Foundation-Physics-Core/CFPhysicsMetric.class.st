Class {
	#name : 'CFPhysicsMetric',
	#superclass : 'Object',
	#instVars : [ 'name', 'unit', 'selector', 'capacity', 'values' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsMetric class >> named: aString unit: aUnitString selector: aSelector capacity: anInteger [
	^ self new
		name: aString;
		unit: aUnitString;
		selector: aSelector;
		capacity: anInteger;
		yourself
]

{ #category : 'initialization' }
CFPhysicsMetric >> initialize [
	super initialize.
	capacity := 300.
	values := OrderedCollection new
]

{ #category : 'accessing' }
CFPhysicsMetric >> name [ ^ name ]
{ #category : 'accessing' }
CFPhysicsMetric >> name: aString [ name := aString ]
{ #category : 'accessing' }
CFPhysicsMetric >> unit [ ^ unit ]
{ #category : 'accessing' }
CFPhysicsMetric >> unit: aString [ unit := aString ]
{ #category : 'accessing' }
CFPhysicsMetric >> selector [ ^ selector ]
{ #category : 'accessing' }
CFPhysicsMetric >> selector: aSelector [ selector := aSelector ]
{ #category : 'accessing' }
CFPhysicsMetric >> capacity [ ^ capacity ]
{ #category : 'accessing' }
CFPhysicsMetric >> capacity: anInteger [
	capacity := anInteger max: 1.
	[ values size > capacity ] whileTrue: [ values removeFirst ].
	^ self
]
{ #category : 'accessing' }
CFPhysicsMetric >> values [ ^ values asArray ]
{ #category : 'accessing' }
CFPhysicsMetric >> sampleCount [ ^ values size ]
{ #category : 'accessing' }
CFPhysicsMetric >> latest [ ^ values ifEmpty: [ 0 ] ifNotEmpty: [ values last ] ]
{ #category : 'recording' }
CFPhysicsMetric >> recordFrame: aFrameMetrics [
	^ self recordValue: (aFrameMetrics perform: selector)
]
{ #category : 'recording' }
CFPhysicsMetric >> recordValue: aNumber [
	values add: aNumber.
	[ values size > capacity ] whileTrue: [ values removeFirst ].
	^ aNumber
]
{ #category : 'recording' }
CFPhysicsMetric >> reset [ values removeAll. ^ self ]
{ #category : 'statistics' }
CFPhysicsMetric >> average [
	| snapshot |
	snapshot := self values.
	^ snapshot ifEmpty: [ 0.0 ] ifNotEmpty: [ snapshot average asFloat ]
]
{ #category : 'statistics' }
CFPhysicsMetric >> minimum [
	| snapshot |
	snapshot := self values.
	^ snapshot ifEmpty: [ 0 ] ifNotEmpty: [ snapshot min ]
]
{ #category : 'statistics' }
CFPhysicsMetric >> maximum [
	| snapshot |
	snapshot := self values.
	^ snapshot ifEmpty: [ 0 ] ifNotEmpty: [ snapshot max ]
]
{ #category : 'statistics' }
CFPhysicsMetric >> percentile: aFraction [
	| sorted index |
	sorted := self values sorted.
	sorted ifEmpty: [ ^ 0 ].
	index := ((sorted size * aFraction) ceiling max: 1) min: sorted size.
	^ sorted at: index
]
{ #category : 'statistics' }
CFPhysicsMetric >> p95 [ ^ self percentile: 0.95 ]
