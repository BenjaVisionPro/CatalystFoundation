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
	| analysis root |
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
	self addChild: (self title: 'Physics step statistics — ', analysis sampleCount asString, ' samples').
	self addChild: (self mapFor: root statistic: #average title: 'Average').
	self addChild: (self mapFor: root statistic: #p95 title: 'P95')
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> mapFor: root statistic: statistic title: aTitle [
	| pane depths |
	pane := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets top: 12);
		cellSpacing: 4;
		yourself.
	pane addChild: (self subtitle:
		aTitle, ' — ',
		(((self durationOf: root statistic: statistic) / 1000.0)
			printShowingDecimalPlaces: 3),
		' ms').
	depths := self spansByDepthFrom: root.
	depths keys sorted do: [ :depth |
		pane addChild: (self rowFor: (depths at: depth) root: root statistic: statistic) ].
	^ pane
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> rowFor: spans root: root statistic: statistic [
	| row cursor total |
	row := BrHorizontalPane new
		hMatchParent;
		vExact: 34;
		cellSpacing: 1;
		yourself.
	cursor := 0.
	total := (self durationOf: root statistic: statistic) max: 1.
	spans do: [ :span |
		| start duration gap block |
		start := self startOf: span statistic: statistic.
		duration := self durationOf: span statistic: statistic.
		gap := (start - cursor) max: 0.
		gap > 0 ifTrue: [ row addChild: (self spacerWeight: gap / total) ].
		block := self blockFor: span duration: duration statistic: statistic.
		block constraintsDo: [ :c | c linear weight: (duration max: 1) / total ].
		row addChild: block.
		cursor := start + duration ].
	cursor < total ifTrue: [ row addChild: (self spacerWeight: (total - cursor) / total) ].
	^ row
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> blockFor: span duration: duration statistic: statistic [
	^ BlElement new
		layout: BlFrameLayout new;
		background: (Color gray alpha: (0.18 + (span depth * 0.08) min: 0.62));
		border: (BlBorder paint: (Color gray alpha: 0.35) width: 1);
		constraintsDo: [ :c | c vertical matchParent ];
		addChild: (BrLabel new
			fitContent;
			padding: (BlInsets all: 4);
			aptitude: (BrGlamorousLabelAptitude new foreground: Color black);
			text: span name asString, ' ',
			(((duration / 1000.0) printShowingDecimalPlaces: 3)),
			'ms';
			constraintsDo: [ :c | c frame horizontal alignCenter. c frame vertical alignCenter ];
			yourself);
		yourself
]

{ #category : 'private - building' }
CFPhysicsTelemetryStatisticsElement >> spacerWeight: aWeight [
	^ BlElement new
		constraintsDo: [ :c | c vertical matchParent. c linear weight: aWeight ];
		yourself
]

{ #category : 'private - accessing' }
CFPhysicsTelemetryStatisticsElement >> spansByDepthFrom: root [
	| dictionary |
	dictionary := Dictionary new.
	root allSpansDo: [ :span |
		(dictionary at: span depth ifAbsentPut: [ OrderedCollection new ]) add: span ].
	^ dictionary
]

{ #category : 'private - accessing' }
CFPhysicsTelemetryStatisticsElement >> startOf: span statistic: statistic [
	^ statistic = #average ifTrue: [ span averageStart ] ifFalse: [ span p95Start ]
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
