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
	| analysis root spans |
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
	self addChild: (self title: 'Physics step statistics — ', analysis sampleCount asString, ' samples').
	self addChild: (self mapFor: spans root: root statistic: #average title: 'Average').
	self addChild: (self mapFor: spans root: root statistic: #p95 title: 'P95').
	self addChild: (self stageTableFor: spans)
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
CFPhysicsTelemetryStatisticsElement >> mapFor: spans root: root statistic: statistic title: aTitle [
	| pane row total index |
	pane := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets top: 12);
		cellSpacing: 5;
		yourself.
	pane addChild: (self subtitle:
		aTitle, ' step — ',
		(((self durationOf: root statistic: statistic) / 1000.0)
			printShowingDecimalPlaces: 3),
		' ms').
	row := BrHorizontalPane new
		hMatchParent;
		vExact: 42;
		cellSpacing: 2;
		yourself.
	total := (spans sum: [ :span | self durationOf: span statistic: statistic ]) max: 1.
	index := 0.
	spans do: [ :span |
		| duration block |
		index := index + 1.
		duration := self durationOf: span statistic: statistic.
		block := self mapBlockFor: span index: index duration: duration.
		block constraintsDo: [ :c |
			c vertical matchParent.
			c linear weight: (duration max: 1) / total ].
		row addChild: block ].
	pane addChild: row.
	^ pane
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> mapBlockFor: span index: index duration: duration [
	^ BlElement new
		layout: BlFrameLayout new;
		background: (Color gray alpha: 0.22 + ((index \ 4) * 0.08));
		border: (BlBorder paint: (Color gray alpha: 0.45) width: 1);
		addChild: (BrLabel new
			fitContent;
			padding: (BlInsets all: 4);
			aptitude: (BrGlamorousLabelAptitude new foreground: Color black);
			text: index asString;
			constraintsDo: [ :c |
				c frame horizontal alignCenter.
				c frame vertical alignCenter ];
			yourself);
		yourself
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> stageTableFor: spans [
	| pane index |
	pane := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets top: 16);
		cellSpacing: 3;
		yourself.
	pane addChild: (self subtitle: 'Pipeline stages').
	pane addChild: self stageTableHeader.
	index := 0.
	spans do: [ :span |
		index := index + 1.
		pane addChild: (self stageRowFor: span index: index) ].
	^ pane
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> stageTableHeader [
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
CFPhysicsTelemetryStatisticsElement >> stageRowFor: span index: index [
	| row average p95 ratio |
	average := span averageDuration / 1000.0.
	p95 := span p95Duration / 1000.0.
	ratio := average = 0
		ifTrue: [ 0 ]
		ifFalse: [ p95 / average ].
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
