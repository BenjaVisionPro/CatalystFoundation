Class {
	#name : 'CFPhysicsTelemetryStatisticsElement',
	#superclass : 'BlElement',
	#instVars : [ 'world' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsTelemetryStatisticsElement class >> world: aWorld [
	^ self new world: aWorld; build; yourself
]

{ #category : 'accessing' }
CFPhysicsTelemetryStatisticsElement >> world: aWorld [ world := aWorld ]

{ #category : 'building' }
CFPhysicsTelemetryStatisticsElement >> build [
	| analysis root spans scale maps |
	self removeChildren.
	self
		layout: BlLinearLayout vertical;
		padding: (BlInsets all: 12);
		constraintsDo: [ :c | c horizontal matchParent. c vertical matchParent ].
	analysis := CFPhysicsTelemetryAnalysis world: world.
	root := analysis rootStatistics.
	root ifNil: [
		self addChild: (self label: 'No Physics step recordings yet. Start telemetry recording and let the world run.').
		^ self ].
	spans := self pipelineSpansFrom: root.
	scale := (spans collect: #p95Duration) max max: 1.
	self addChild: (self title: 'Physics step statistics — ', analysis sampleCount asString, ' samples').
	self addChild: (self summaryFor: root).
	maps := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets top: 12);
		cellSpacing: 16;
		yourself.
	maps addChild: (self timingMapFor: spans statistic: #average title: 'Average' scale: scale).
	maps addChild: (self timingMapFor: spans statistic: #p95 title: 'P95' scale: scale).
	self addChild: maps.
	self addChild: (self hotspotTableFor: spans)
]

{ #category : 'private - accessing' }
CFPhysicsTelemetryStatisticsElement >> pipelineSpansFrom: root [
	| pipeline |
	pipeline := root children
		detect: [ :each | each name asString = 'Pipeline' ]
		ifNone: [ nil ].
	^ pipeline
		ifNil: [ root children ]
		ifNotNil: [ pipeline children ]
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> summaryFor: root [
	| row average p95 ratio |
	average := root averageDuration / 1000.0.
	p95 := root p95Duration / 1000.0.
	ratio := average = 0 ifTrue: [ 0 ] ifFalse: [ p95 / average ].
	row := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets top: 8);
		cellSpacing: 18;
		yourself.
	row addChild: (self metricLabel: 'Average step' value: (average printShowingDecimalPlaces: 3), ' ms').
	row addChild: (self metricLabel: 'P95 step' value: (p95 printShowingDecimalPlaces: 3), ' ms').
	row addChild: (self metricLabel: 'P95 / average' value: (ratio printShowingDecimalPlaces: 2), '×').
	^ row
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> timingMapFor: spans statistic: statistic title: aTitle scale: scale [
	| pane |
	pane := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 4;
		yourself.
	pane addChild: (self subtitle: aTitle, ' pipeline — shared P95 scale').
	spans do: [ :span |
		pane addChild: (self timingRowFor: span statistic: statistic scale: scale) ].
	^ pane
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> timingRowFor: span statistic: statistic scale: scale [
	| row duration nameLabel track fill remainder valueLabel |
	duration := self durationOf: span statistic: statistic.
	row := BrHorizontalPane new
		hMatchParent;
		vExact: 28;
		cellSpacing: 6;
		yourself.
	nameLabel := self tableLabel: (self readableNameOf: span) width: 170 bold: false.
	track := BrHorizontalPane new
		hMatchParent;
		vExact: 18;
		background: (Color gray alpha: 0.08);
		yourself.
	fill := BlElement new
		background: (Color gray alpha: 0.42);
		border: (BlBorder paint: (Color gray alpha: 0.5) width: 1);
		yourself.
	remainder := BlElement new yourself.
	fill constraintsDo: [ :c |
		c vertical matchParent.
		c linear weight: duration max: 0.0001 ].
	remainder constraintsDo: [ :c |
		c vertical matchParent.
		c linear weight: (scale - duration) max: 0.0001 ].
	track addChild: fill.
	track addChild: remainder.
	valueLabel := self tableLabel:
		((duration / 1000.0) printShowingDecimalPlaces: 3), ' ms'
		width: 78
		bold: false.
	row addChild: nameLabel.
	row addChild: track.
	row addChild: valueLabel.
	^ row
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> hotspotTableFor: spans [
	| pane ordered |
	ordered := spans sorted: [ :left :right | left p95Duration > right p95Duration ].
	pane := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets top: 18);
		cellSpacing: 3;
		yourself.
	pane addChild: (self subtitle: 'P95 hotspots').
	pane addChild: self hotspotTableHeader.
	ordered withIndexDo: [ :span :index |
		pane addChild: (self hotspotRowFor: span index: index) ].
	^ pane
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> hotspotTableHeader [
	| row |
	row := BrHorizontalPane new hMatchParent; vExact: 28; yourself.
	row addChild: (self tableLabel: '#' width: 34 bold: true).
	row addChild: (self tableLabel: 'Stage' width: 270 bold: true).
	row addChild: (self tableLabel: 'Average' width: 90 bold: true).
	row addChild: (self tableLabel: 'P95' width: 90 bold: true).
	row addChild: (self tableLabel: 'P95 / Avg' width: 90 bold: true).
	^ row
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> hotspotRowFor: span index: index [
	| row average p95 ratio |
	average := span averageDuration / 1000.0.
	p95 := span p95Duration / 1000.0.
	ratio := average = 0 ifTrue: [ 0 ] ifFalse: [ p95 / average ].
	row := BrHorizontalPane new
		hMatchParent;
		vExact: 30;
		background: (Color gray alpha: (index even ifTrue: [ 0.06 ] ifFalse: [ 0.02 ]));
		yourself.
	row addChild: (self tableLabel: index asString width: 34 bold: false).
	row addChild: (self tableLabel: (self readableNameOf: span) width: 270 bold: false).
	row addChild: (self tableLabel: (average printShowingDecimalPlaces: 3), ' ms' width: 90 bold: false).
	row addChild: (self tableLabel: (p95 printShowingDecimalPlaces: 3), ' ms' width: 90 bold: false).
	row addChild: (self tableLabel: (ratio printShowingDecimalPlaces: 2), '×' width: 90 bold: false).
	^ row
]

{ #category : 'private - accessing' }
CFPhysicsTelemetryStatisticsElement >> readableNameOf: span [
	| name |
	name := span name asString.
	name := name copyReplaceAll: 'CFPhysics' with: ''.
	name := name copyReplaceAll: 'Stage' with: ''.
	^ name
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> metricLabel: aName value: aValue [
	| text |
	text := aName, ': ', aValue.
	^ BrLabel new
		fitContent;
		padding: (BlInsets top: 4 right: 8 bottom: 4 left: 8);
		background: (Color gray alpha: 0.08);
		aptitude: (BrGlamorousLabelAptitude new foreground: Color black);
		text: text;
		yourself
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> tableLabel: aString width: aWidth bold: shouldBeBold [
	| text |
	text := aString asRopedText.
	shouldBeBold ifTrue: [ text bold ].
	^ BrLabel new
		hExact: aWidth;
		vMatchParent;
		padding: (BlInsets left: 5 right: 5);
		aptitude: (BrGlamorousLabelAptitude new foreground: Color black);
		text: text;
		yourself
]

{ #category : 'private - accessing' }
CFPhysicsTelemetryStatisticsElement >> durationOf: span statistic: statistic [
	^ statistic = #average ifTrue: [ span averageDuration ] ifFalse: [ span p95Duration ]
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> title: aString [
	^ BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: Color black);
		text: aString asRopedText bold;
		yourself
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> subtitle: aString [
	^ BrLabel new
		fitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.7));
		text: aString;
		yourself
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> label: aString [
	^ BrLabel new
		fitContent;
		aptitude: BrGlamorousLabelAptitude new;
		text: aString;
		yourself
]
