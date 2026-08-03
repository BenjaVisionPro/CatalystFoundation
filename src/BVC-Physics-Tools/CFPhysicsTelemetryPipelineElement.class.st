"I present the live telemetry analysis for one Physics world. I own the controls, asynchronous analysis and pipeline visualisation used by the telemetry inspector."
Class {
	#name : 'CFPhysicsTelemetryPipelineElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'world',
		'stageLabelWidth',
		'telemetryUpdatesStream',
		'controls',
		'windowToggleGroup',
		'samplesLabel',
		'summaryLabel',
		'contactsSummaryLabel',
		'manifoldsSummaryLabel',
		'pointsSummaryLabel',
		'changesSummaryLabel',
		'bodiesSummaryLabel',
		'sleepSummaryLabel',
		'graph'
	],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsTelemetryPipelineElement class >> world: aWorld [
	^ self new
		world: aWorld;
		build;
		yourself
]

{ #category : 'initialization' }
CFPhysicsTelemetryPipelineElement >> initialize [
	super initialize.
	self
		hMatchParent;
		vFitContent;
		cellSpacing: 4;
		padding: (BlInsets all: 12)
]

{ #category : 'accessing' }
CFPhysicsTelemetryPipelineElement >> world: aWorld [
	world := aWorld.
	telemetryUpdatesStream := CFPhysicsTelemetryStream on: world.
	self withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anElement :aSink |
				aSink peek ifSome: [ anElement updateGraph ] ];
			forwardStream: telemetryUpdatesStream ]
]

{ #category : 'building' }
CFPhysicsTelemetryPipelineElement >> build [
	self removeChildren.
	controls := self buildControls.
	graph := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 4;
		yourself.
	graph withAsyncFutureDo: [ :anElementFuture |
		anElementFuture
			executionConfiguration: (AsyncFutureExecutionConfiguration new
				customGroup: #'Physics Telemetry Inspector');
			cancelSoft;
			whenSuccess: [ :anElement :analysis | self renderAnalysis: analysis ];
			whenError: [ :anElement :anError |
				anError class = AsyncFutureCancelled
					ifFalse: [ anElement showNotification: anError asNotification ] ] ].
	summaryLabel := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 2;
		yourself.
	contactsSummaryLabel := self profileSummaryLabel.
	manifoldsSummaryLabel := self profileSummaryLabel.
	pointsSummaryLabel := self profileSummaryLabel.
	changesSummaryLabel := self profileSummaryLabel.
	bodiesSummaryLabel := self profileSummaryLabel.
	sleepSummaryLabel := self profileSummaryLabel.
	summaryLabel
		addChild: contactsSummaryLabel;
		addChild: manifoldsSummaryLabel;
		addChild: pointsSummaryLabel;
		addChild: changesSummaryLabel;
		addChild: bodiesSummaryLabel;
		addChild: sleepSummaryLabel.
	self updateSummaryLabelsWith: Dictionary new.
	self
		addChild: controls;
		addChild: summaryLabel;
		addChild: graph.
	self updateGraph
]

{ #category : 'private - updating' }
CFPhysicsTelemetryPipelineElement >> updateGraph [
	| recordings windowSeconds |
	recordings := world telemetryRecordings.
	windowSeconds := world telemetryAnalysisWindowSeconds.
	graph asyncFuture future: [
		Processor activeProcess name: 'Physics Profile Analysis'.
		CFPhysicsTelemetryAnalysis
			recordings: recordings
			windowSeconds: windowSeconds ] asAsyncFuture
]

{ #category : 'private - updating' }
CFPhysicsTelemetryPipelineElement >> renderAnalysis: analysis [
	| root pipeline maximumEnd scale |
	samplesLabel text: analysis sampleCount asString, ' samples'.
	self updateSummaryFrom: analysis.
	graph removeChildren.
	root := analysis rootStatistics.
	root ifNil: [
		graph addChild: (self emptyLabel: 'Record at least one Physics step to see pipeline statistics.').
		^ self ].
	pipeline := root children
		detect: [ :each | each name asString = 'Pipeline' ]
		ifNone: [ nil ].
	pipeline ifNil: [
		graph addChild: (self emptyLabel: 'No Pipeline span was found in the recorded Physics steps.').
		^ self ].
	stageLabelWidth := self stageLabelWidthFor: pipeline children.
	maximumEnd := pipeline children
		inject: pipeline p95Duration
		into: [ :maximum :span | maximum max: span p95End ].
	maximumEnd := world telemetryStepStatisticsMaximumMicrosecondsFor: (maximumEnd max: 1).
	scale := GtPlotterLinearScale new
		domainFrom: 0 to: maximumEnd;
		rangeFrom: 0 to: 1;
		tickFormat: [ :value | self formattedMillisecondsForMicroseconds: value ];
		yourself.
	graph addChild: (self axisRowFor: scale).
	pipeline children do: [ :span |
		graph addChild: (self stageRowFor: span scale: scale) ]
]



{ #category : 'private - updating' }
CFPhysicsTelemetryPipelineElement >> updateSummaryFrom: analysis [
	| stepRecordings data |
	stepRecordings := analysis stepRecordings.
	data := stepRecordings
		ifEmpty: [ Dictionary new ]
		ifNotEmpty: [ stepRecordings last physicsData ].
	self updateSummaryLabelsWith: data
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> profileSummaryLabel [
	^ BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.72));
		yourself
]

{ #category : 'private - updating' }
CFPhysicsTelemetryPipelineElement >> updateSummaryLabelsWith: data [
	| printer valueFor |
	printer := GRPrinter new.
	valueFor := [ :key |
		printer
			pad: (data at: key ifAbsent: [ 0 ]) printString
			left: Character space
			to: 6 ].
	contactsSummaryLabel text: (String streamContents: [ :stream |
		stream
			nextPutAll: 'Contacts     Persistent';
			nextPutAll: (valueFor value: #persistentContactCount);
			nextPutAll: '   Began';
			nextPutAll: (valueFor value: #beganContactCount);
			nextPutAll: '   Continued';
			nextPutAll: (valueFor value: #continuedContactCount);
			nextPutAll: '   Ended';
			nextPutAll: (valueFor value: #endedContactCount) ]).
	manifoldsSummaryLabel text: (String streamContents: [ :stream |
		stream
			nextPutAll: 'Manifolds    Stable';
			nextPutAll: (valueFor value: #stablePreparedManifoldCount);
			nextPutAll: '   Changed';
			nextPutAll: (valueFor value: #changedPreparedManifoldCount) ]).
	pointsSummaryLabel text: (String streamContents: [ :stream |
		stream
			nextPutAll: 'Points       Reused';
			nextPutAll: (valueFor value: #reusablePreparedContactPointCount);
			nextPutAll: '   New';
			nextPutAll: (valueFor value: #newPreparedContactPointCount) ]).
	changesSummaryLabel text: (String streamContents: [ :stream |
		stream
			nextPutAll: 'Changes      Id';
			nextPutAll: (valueFor value: #featureIdChangedPreparedManifoldCount);
			nextPutAll: '   Normal';
			nextPutAll: (valueFor value: #normalChangedPreparedManifoldCount);
			nextPutAll: '   Count';
			nextPutAll: (valueFor value: #pointCountChangedPreparedManifoldCount);
			nextPutAll: '   Order';
			nextPutAll: (valueFor value: #pointOrderChangedPreparedManifoldCount);
			nextPutAll: '   Sep';
			nextPutAll: (valueFor value: #separationChangedPreparedManifoldCount) ]).
	bodiesSummaryLabel text: (String streamContents: [ :stream |
		stream
			nextPutAll: 'Bodies       Awake';
			nextPutAll: (valueFor value: #activeBodyCount);
			nextPutAll: '   Sleeping';
			nextPutAll: (valueFor value: #sleepingBodyCount) ]).
	sleepSummaryLabel text: (String streamContents: [ :stream |
		stream
			nextPutAll: 'Sleep        Accepted';
			nextPutAll: (valueFor value: #sleepMotionAcceptedBodyCount);
			nextPutAll: '   Rejected';
			nextPutAll: (valueFor value: #sleepMotionRejectedBodyCount);
			nextPutAll: '   Disabled';
			nextPutAll: (valueFor value: #sleepDisabledBodyCount);
			nextPutAll: '   Max ratio ';
			nextPutAll: ((data at: #maximumSleepThresholdRatio ifAbsent: [ 0.0 ]) asFloat printShowingDecimalPlaces: 2);
			nextPutAll: 'x   Min time ';
			nextPutAll: ((data at: #minimumSleepTime ifAbsent: [ 0.0 ]) asFloat printShowingDecimalPlaces: 3);
			nextPutAll: ' s' ])
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> axisRowFor: scale [
	| row stageSpace axis statisticsHeadings labels |
	row := BrHorizontalPane new
		hMatchParent;
		vExact: 34;
		cellSpacing: 6;
		yourself.
	stageSpace := BlElement new
		size: stageLabelWidth @ 1;
		yourself.
	axis := BrFrame new
		hMatchParent;
		vExact: 34;
		clipChildren: false;
		yourself.
	labels := GtPlotterHorizontalTickLabelsElement new
		scale: scale;
		labels: 8;
		labelFormat: [ :value |
			(self formattedMillisecondsForMicroseconds: value), ' ms' ];
		labelStyle: [ :anElement |
			anElement constraintsDo: [ :c |
				c frame vertical alignBottom.
				c horizontal fitContent.
				c vertical fitContent ] ];
		yourself.
	axis addChild: labels.
	statisticsHeadings := self statisticsHeadings.
	row
		addChild: stageSpace;
		addChild: axis;
		addChild: statisticsHeadings.
	^ row
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> stageRowFor: span scale: scale [
	| row stageLabel chart statistics |
	row := BrHorizontalPane new
		hMatchParent;
		vExact: 34;
		cellSpacing: 6;
		yourself.
	stageLabel := self stageLabelFor: span.
	chart := self candleFor: span scale: scale.
	statistics := self statisticsFor: span.
	row
		addChild: stageLabel;
		addChild: chart;
		addChild: statistics.
	^ row
]


{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> stageLabelFor: span [
	^ BrLabel new
		hExact: stageLabelWidth;
		vExact: 30;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.78));
		text: span readableName;
		yourself
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> candleFor: span scale: scale [
	| frame grid wick candle medianBar averageMarker leftCap rightCap p05 p25 medianStart medianEnd p75 p95 averageMidpoint |
	p05 := scale map: span p05Start.
	p25 := scale map: span p25Start.
	p75 := scale map: span p75End.
	p95 := scale map: span p95End.
	medianStart := scale map: span medianStart.
	medianEnd := scale map: span medianEnd.
	averageMidpoint := scale map: ((span averageStart + span averageEnd) / 2).
	p25 := p25 max: p05.
	p75 := p75 max: p25.
	p95 := p95 max: p75.
	medianStart := medianStart max: p25.
	medianEnd := (medianEnd max: medianStart) min: p75.
	frame := BrFrame new
		hMatchParent;
		vExact: 30;
		layout: BlFrameLayout new;
		background: (Color gray alpha: 0.035);
		clipChildren: false;
		yourself.
	grid := GtPlotterHorizontalTicksElement new
		scale: scale;
		ticks: 8;
		weight: 1;
		tickStyle: [ :anElement |
			anElement
				background: (Color gray alpha: 0.12);
				width: 1 ];
		yourself.
	wick := self horizontalElementFrom: p05 to: p95 height: 1 color: (Color gray alpha: 0.65) verticalCenter: 0.5.
	candle := self horizontalElementFrom: p25 to: p75 height: 14 color: (Color gray alpha: 0.24) verticalCenter: 0.5.
	candle border: (BlBorder paint: (Color gray alpha: 0.5) width: 1).
	medianBar := self horizontalElementFrom: medianStart to: medianEnd height: 7 color: (Color gray alpha: 0.78) verticalCenter: 0.5.
	leftCap := self verticalMarkerAt: p05 height: 12 color: (Color gray alpha: 0.65).
	rightCap := self verticalMarkerAt: p95 height: 12 color: (Color gray alpha: 0.65).
	averageMarker := self verticalMarkerAt: averageMidpoint height: 18 color: (Color black alpha: 0.55).
	frame
		addChild: grid;
		addChild: wick;
		addChild: leftCap;
		addChild: rightCap;
		addChild: candle;
		addChild: medianBar;
		addChild: averageMarker;
		addAptitude: (BrGlamorousWithExplicitTooltipAptitude text: (self tooltipFor: span));
		when: BlClickEvent do: [ :event |
			event consumed: true.
			event currentTarget phlow spawnObject: span ].
	^ frame
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> horizontalElementFrom: startPercentage to: endPercentage height: aHeight color: aColor verticalCenter: verticalPercentage [
	| safeStart safeEnd |
	safeStart := startPercentage max: 0.
	safeEnd := (endPercentage max: safeStart + 0.0005) min: 1.
	^ BlElement new
		background: aColor;
		constraintsDo: [ :c |
			c vertical exact: aHeight.
			c horizontal matchParent.
			c frame vertical alignCenterAt: verticalPercentage.
			c frame horizontal alignLeftAt: safeStart.
			c frame horizontal weight: safeEnd - safeStart ];
		yourself
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> verticalMarkerAt: aPercentage height: aHeight color: aColor [
	^ BlElement new
		background: aColor;
		constraintsDo: [ :c |
			c horizontal exact: 1.
			c vertical exact: aHeight.
			c frame vertical alignCenterAt: 0.5.
			c frame horizontal alignCenterAt: ((aPercentage max: 0) min: 1) ];
		yourself
]

{ #category : 'private - formatting' }
CFPhysicsTelemetryPipelineElement >> formattedMillisecondsForMicroseconds: microseconds [
	| milliseconds rounded |
	milliseconds := microseconds / 1000.0.
	rounded := milliseconds rounded.
	^ milliseconds = rounded
		ifTrue: [ rounded asString ]
		ifFalse: [ milliseconds printShowingDecimalPlaces: 1 ]
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> stageLabelWidthFor: spans [
	| longestCharacterCount |
	longestCharacterCount := spans
		inject: 0
		into: [ :maximum :span | maximum max: span readableName size ].
	^ ((longestCharacterCount * 8) + 8) max: 96
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> statisticsHeadings [
	| pane |
	pane := BrHorizontalPane new
		hExact: 300;
		vExact: 30;
		cellSpacing: 8;
		yourself.
	pane
		addChild: (self statisticsHeading: 'Avg' width: 62);
		addChild: (self statisticsHeading: 'P95' width: 62);
		addChild: (self statisticsHeading: 'P95/Avg' width: 58);
		addChild: (self statisticsHeading: 'Jitter' width: 62).
	^ pane
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> statisticsHeading: aString width: aWidth [
	^ BrLabel new
		hExact: aWidth;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.58));
		text: aString;
		yourself
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> statisticsFor: span [
	| pane |
	pane := BrHorizontalPane new
		hExact: 300;
		vExact: 30;
		cellSpacing: 8;
		yourself.
	pane
		addChild: (self numericLabel: span averageMilliseconds width: 62 decimals: 3 suffix: '');
		addChild: (self numericLabel: span p95Milliseconds width: 62 decimals: 3 suffix: '');
		addChild: (self numericLabel: span p95ToAverageRatio width: 58 decimals: 2 suffix: 'x');
		addChild: (self numericLabel: span startJitterMilliseconds width: 62 decimals: 3 suffix: '').
	^ pane
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> numericLabel: aNumber width: aWidth decimals: decimalPlaces suffix: suffixString [
	^ BrLabel new
		hExact: aWidth;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.75));
		text: (aNumber printShowingDecimalPlaces: decimalPlaces), suffixString;
		yourself
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> tooltipFor: span [
	^ span readableName, String cr,
		'Average ', (span averageMilliseconds printShowingDecimalPlaces: 3), ' ms', String cr,
		'P95 ', (span p95Milliseconds printShowingDecimalPlaces: 3), ' ms', String cr,
		'P95 / average ', (span p95ToAverageRatio printShowingDecimalPlaces: 2), 'x', String cr,
		'Median interval ', (((span medianEnd - span medianStart) / 1000.0) printShowingDecimalPlaces: 3), ' ms', String cr,
		'Average midpoint ', ((((span averageStart + span averageEnd) / 2) / 1000.0) printShowingDecimalPlaces: 3), ' ms', String cr,
		'Start jitter ', (span startJitterMilliseconds printShowingDecimalPlaces: 3), ' ms'
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> emptyLabel: aString [
	^ BrLabel new
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.70));
		text: aString;
		yourself
]


{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> buildControls [
	| row liveLabel |
	row := BrHorizontalPane new
		hMatchParent;
		vExact: 32;
		cellSpacing: 6;
		yourself.
	liveLabel := BrLabel new
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.72));
		text: 'Rolling window';
		yourself.
	windowToggleGroup := self buildWindowToggleGroup.
	samplesLabel := BrLabel new
		hMatchParent;
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.58));
		text: '0 samples';
		yourself.
	row
		addChild: liveLabel;
		addChild: windowToggleGroup;
		addChild: samplesLabel.
	^ row
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> buildWindowToggleGroup [
	| toggleGroup |
	toggleGroup := BrToggleGroup new
		aptitude: BrGlamorousToggleGroupAptitude new;
		yourself.
	#(1 5 10 30) do: [ :seconds |
		toggleGroup addToggle: (self windowToggleForSeconds: seconds) ].
	^ toggleGroup
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> windowToggleForSeconds: seconds [
	| toggle |
	toggle := BrToggle new
		aptitude: BrGlamorousToggleWithLabelAptitude new;
		label: seconds asString, ' s';
		yourself.
	toggle viewModel model: seconds.
	world telemetryAnalysisWindowSeconds = seconds
		ifTrue: [ toggle activate ].
	toggle
		when: BrToggleActivatedEvent
		do: [ :anEvent |
			world telemetryAnalysisWindowSeconds: anEvent model.
			self updateGraph ].
	^ toggle
]


{ #category : 'hooks - scene graph' }
CFPhysicsTelemetryPipelineElement >> onRemovedFromSceneGraph [
	super onRemovedFromSceneGraph.
	graph ifNotNil: [ graph asyncFuture interrupt ]
]
