Class {
	#name : 'CFPhysicsTelemetrySpanStatistics',
	#superclass : 'Object',
	#instVars : [
		'name',
		'depth',
		'averageStart',
		'averageEnd',
		'averageDuration',
		'p05Start',
		'p25Start',
		'medianStart',
		'medianEnd',
		'p75End',
		'p95Start',
		'p95End',
		'p95Duration',
		'samples',
		'children'
	],
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
CFPhysicsTelemetrySpanStatistics >> averageEnd [ ^ averageEnd ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> averageEnd: aNumber [ averageEnd := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> averageDuration [ ^ averageDuration ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> averageDuration: aNumber [ averageDuration := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p05Start [ ^ p05Start ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p05Start: aNumber [ p05Start := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p25Start [ ^ p25Start ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p25Start: aNumber [ p25Start := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> medianStart [ ^ medianStart ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> medianStart: aNumber [ medianStart := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> medianEnd [ ^ medianEnd ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> medianEnd: aNumber [ medianEnd := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p75End [ ^ p75End ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p75End: aNumber [ p75End := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p95Start [ ^ p95Start ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p95Start: aNumber [ p95Start := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p95End [ ^ p95End ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p95End: aNumber [ p95End := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p95Duration [ ^ p95Duration ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> p95Duration: aNumber [ p95Duration := aNumber ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> samples [ ^ samples ifNil: [ #() ] ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> samples: aCollection [ samples := aCollection ]

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
CFPhysicsTelemetrySpanStatistics >> sampleCount [ ^ self samples size ]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> averageMilliseconds [
	^ self averageDuration / 1000.0
]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> medianMilliseconds [
	| sorted rank |
	self samples ifEmpty: [ ^ 0 ].
	sorted := (self samples collect: #duration) sorted.
	rank := ((sorted size * 0.5) ceiling max: 1) min: sorted size.
	^ (sorted at: rank) / 1000.0
]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> p95Milliseconds [
	^ self p95Duration / 1000.0
]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> minimumMilliseconds [
	| durations |
	durations := self samples collect: #duration.
	^ durations ifEmpty: [ 0 ] ifNotEmpty: [ durations min / 1000.0 ]
]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> maximumMilliseconds [
	| durations |
	durations := self samples collect: #duration.
	^ durations ifEmpty: [ 0 ] ifNotEmpty: [ durations max / 1000.0 ]
]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> p95ToAverageRatio [
	^ self averageDuration = 0
		ifTrue: [ 0 ]
		ifFalse: [ self p95Duration / self averageDuration ]
]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> startJitterMilliseconds [
	^ (self p95Start - self p05Start) / 1000.0
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

{ #category : 'accessing' }
CFPhysicsTelemetrySpanStatistics >> executionsByDuration [
	^ self samples sorted: [ :a :b | a duration > b duration ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtSummaryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Summary';
		priority: 10;
		items: [ {
			'Span' -> self readableName.
			'Samples' -> self sampleCount.
			'Average (ms)' -> self averageMilliseconds.
			'Median (ms)' -> self medianMilliseconds.
			'P95 (ms)' -> self p95Milliseconds.
			'Minimum (ms)' -> self minimumMilliseconds.
			'Maximum (ms)' -> self maximumMilliseconds.
			'P95 / average' -> self p95ToAverageRatio.
			'Start jitter (ms)' -> self startJitterMilliseconds } ];
		column: 'Statistic' text: #key;
		column: 'Value' text: #value;
		send: #value
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtDurationTrendFor: aView [
	<gtView>
	^ aView explicit
		title: 'Duration trend';
		priority: 11;
		disableAsync;
		stencil: [
			| values data chart |
			values := self samples collect: [ :sample | sample sequence -> sample durationMilliseconds ].
			data := GtPlotterDataGroup new values: values.
			chart := GtPlotterLineChart new
				with: data;
				valueX: #key;
				scaleX: GtPlotterLinearScale new;
				labelFormatX: [ :aSequence |
					aSequence asInteger asString asRopedText foreground: Color darkGray ];
				titleX: 'Recorded step';
				valueY: #value;
				scaleY: GtPlotterLinearScale new;
				labelFormatY: [ :aDuration |
					(aDuration printShowingDecimalPlaces: 3) asRopedText foreground: Color darkGray ];
				titleY: 'Duration (ms)';
				ticksX: 8;
				ticksY: 6.
			chart asElement ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtExecutionsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Executions';
		priority: 15;
		items: [ self executionsByDuration ];
		column: 'Step' text: [ :sample | sample stepNumber ifNil: [ sample sequence ] ];
		column: 'Duration (ms)' text: [ :sample | sample durationMilliseconds ];
		column: 'Start (ms)' text: [ :sample | sample startMilliseconds ];
		column: 'End (ms)' text: [ :sample | sample endMilliseconds ];
		column: 'GC (ms)' text: [ :sample | sample ping gcDurationInMilliseconds ];
		column: 'Bodies' text: [ :sample | sample bodyCount ifNil: [ '' ] ];
		column: 'Contacts' text: [ :sample | sample contactCount ifNil: [ '' ] ];
		send: [ :sample | sample signal ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtSourcesFor: aView [
	<gtView>
	| methods |
	methods := (self samples collect: #sender) reject: #isNil.
	methods := methods asSet asArray.
	^ aView list
		title: 'Sources';
		priority: 16;
		items: [ methods ]
]

{ #category : 'statistics' }
CFPhysicsTelemetrySpanStatistics >> durationHistogramWithBins: requestedBinCount [
	| durations minimum maximum binCount width counts |
	durations := self samples collect: #durationMilliseconds.
	durations ifEmpty: [ ^ #() ].
	minimum := durations min.
	maximum := durations max.
	binCount := (requestedBinCount min: durations size) max: 1.
	width := maximum = minimum
		ifTrue: [ 1.0 ]
		ifFalse: [ (maximum - minimum) / binCount ].
	counts := Array new: binCount withAll: 0.
	durations do: [ :duration |
		| index |
		index := maximum = minimum
			ifTrue: [ 1 ]
			ifFalse: [ (((duration - minimum) / width) floor + 1) min: binCount ].
		counts at: index put: (counts at: index) + 1 ].
	^ (1 to: binCount) collect: [ :index |
		| lower upper |
		lower := minimum + ((index - 1) * width).
		upper := index = binCount
			ifTrue: [ maximum ]
			ifFalse: [ lower + width ].
		{ lower. upper. counts at: index } ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtDurationDistributionFor: aView [
	<gtView>
	^ aView explicit
		title: 'Distribution';
		priority: 12;
		disableAsync;
		stencil: [
			| bins data maximumCount chart |
			bins := self durationHistogramWithBins: 12.
			bins ifEmpty: [
				BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					text: 'No recorded executions.';
					yourself ]
			ifNotEmpty: [
				data := GtPlotterDataGroup new values: bins.
				data := data labelled: [ :bin |
					(bin first printShowingDecimalPlaces: 3), '–',
					(bin second printShowingDecimalPlaces: 3) ].
				maximumCount := bins inject: 1 into: [ :maximum :bin | maximum max: bin third ].
				chart := GtPlotterVerticalBarChart new.
				chart
					barElement: [ :context |
						BlElement new
							aptitude: (BrGlamorousWithExplicitTooltipAptitude
								text: context originalValue third asString, ' executions');
							yourself ];
					barHeightScale: (GtPlotterLinearScale new domainFrom: 0 to: maximumCount);
					barWidthScale: (GtPlotterConstantScale new constant: 24);
					barHeightData: [ :bin | bin third ];
					amountOfTicks: 6;
					with: data.
				chart create ] ]
]

{ #category : 'private - gt views' }
CFPhysicsTelemetrySpanStatistics >> correlationChartFor: samples valueX: xBlock titleX: xTitle [
	| data chart |
	data := GtPlotterDataGroup new values: samples.
	chart := GtPlotterScatterChart new
		with: data;
		valueX: xBlock;
		scaleX: GtPlotterLinearScale new;
		labelFormatX: [ :aCount |
			aCount asInteger asString asRopedText foreground: Color darkGray ];
		titleX: xTitle;
		ticksX: 8;
		valueY: #durationMilliseconds;
		scaleY: GtPlotterLinearScale new;
		labelFormatY: [ :aDuration |
			(aDuration printShowingDecimalPlaces: 3) asRopedText foreground: Color darkGray ];
		titleY: 'Duration (ms)';
		ticksY: 8;
		withProjectionAxis;
		dotElement: [ :context |
			| sample |
			sample := context originalValue.
			BlElement new
				geometry: BlEllipseGeometry new;
				size: 7 asPoint;
				aptitude: (BrGlamorousWithExplicitTooltipAptitude
					text: 'Step ', (sample stepNumber ifNil: [ sample sequence ]) asString,
						' · ', (sample durationMilliseconds printShowingDecimalPlaces: 3), ' ms');
				when: BlClickEvent do: [ :event |
					event consumed: true.
					event currentTarget phlow spawnObject: sample signal ];
				yourself ].
	^ chart create
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtBodiesCorrelationFor: aView [
	<gtView>
	| available |
	available := self samples reject: [ :sample | sample bodyCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Bodies';
		priority: 13;
		disableAsync;
		stencil: [ self correlationChartFor: available valueX: #bodyCount titleX: 'Body count' ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtContactsCorrelationFor: aView [
	<gtView>
	| available |
	available := self samples reject: [ :sample | sample contactCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Contacts';
		priority: 14;
		disableAsync;
		stencil: [ self correlationChartFor: available valueX: #contactCount titleX: 'Contact count' ]
]
