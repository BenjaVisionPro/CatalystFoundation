"I represent the aggregated measurements of one named telemetry span. I retain its samples, percentile statistics and child spans and provide the diagnostic views derived from them."
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
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
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
		column: 'Solved islands' text: [ :sample | sample solvedIslandCount ifNil: [ '' ] ];
		column: 'Largest island bodies' text: [ :sample | sample largestSolvedIslandBodyCount ifNil: [ '' ] ];
		column: 'Largest island constraints' text: [ :sample | sample largestSolvedIslandConstraintCount ifNil: [ '' ] ];
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


{ #category : 'testing' }
CFPhysicsTelemetrySpanStatistics >> isIslandSolverSpan [
	^ self name asString = CFPhysicsIslandSolverStage name asString
]

{ #category : 'private - solver evidence' }
CFPhysicsTelemetrySpanStatistics >> averageSampleValue: aBlock [
	| values |
	values := (self samples collect: aBlock) reject: #isNil.
	^ values ifEmpty: [ 0.0 ] ifNotEmpty: [ values average asFloat ]
]

{ #category : 'private - solver evidence' }
CFPhysicsTelemetrySpanStatistics >> maximumSampleValue: aBlock [
	| values |
	values := (self samples collect: aBlock) reject: #isNil.
	^ values ifEmpty: [ 0 ] ifNotEmpty: [ values max ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtIslandSolverEvidenceFor: aView [
	<gtView>
	self isIslandSolverSpan ifFalse: [ ^ aView empty ].
	^ aView columnedList
		title: 'Solver evidence';
		priority: 17;
		items: [ {
			'Average solved islands' -> (self averageSampleValue: #solvedIslandCount).
			'Maximum solved islands' -> (self maximumSampleValue: #solvedIslandCount).
			'Average largest island bodies' -> (self averageSampleValue: #largestSolvedIslandBodyCount).
			'Maximum largest island bodies' -> (self maximumSampleValue: #largestSolvedIslandBodyCount).
			'Average largest island dynamic bodies' -> (self averageSampleValue: #largestSolvedIslandDynamicBodyCount).
			'Maximum largest island dynamic bodies' -> (self maximumSampleValue: #largestSolvedIslandDynamicBodyCount).
			'Average largest island constraints' -> (self averageSampleValue: #largestSolvedIslandConstraintCount).
			'Maximum largest island constraints' -> (self maximumSampleValue: #largestSolvedIslandConstraintCount).
			'Average solved-island constraints' -> (self averageSampleValue: #solvedIslandConstraintCount).
			'Maximum solved-island constraints' -> (self maximumSampleValue: #solvedIslandConstraintCount).
			'Average contact constraints' -> (self averageSampleValue: #solverContactConstraintCount).
			'Maximum contact constraints' -> (self maximumSampleValue: #solverContactConstraintCount).
			'Average contact points' -> (self averageSampleValue: #solverContactPointCount).
			'Maximum contact points' -> (self maximumSampleValue: #solverContactPointCount).
			'Average warm-started points' -> (self averageSampleValue: #solverWarmStartedContactPointCount).
			'Maximum warm-started points' -> (self maximumSampleValue: #solverWarmStartedContactPointCount).
			'Average restitution candidates' -> (self averageSampleValue: #solverRestitutionCandidatePointCount).
			'Maximum restitution candidates' -> (self maximumSampleValue: #solverRestitutionCandidatePointCount).
			'Average joint constraints' -> (self averageSampleValue: #solverJointConstraintCount).
			'Maximum joint constraints' -> (self maximumSampleValue: #solverJointConstraintCount).
			'Average distance joints' -> (self averageSampleValue: #solverDistanceJointConstraintCount).
			'Average rail joints' -> (self averageSampleValue: #solverRailJointConstraintCount).
			'Average revolute joints' -> (self averageSampleValue: #solverRevoluteJointConstraintCount).
			'Average fixed joints' -> (self averageSampleValue: #solverFixedJointConstraintCount) } ];
		column: 'Measured fact' text: #key;
		column: 'Value' text: #value;
		send: #value
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtLargestIslandBodiesCorrelationFor: aView [
	<gtView>
	| available |
	self isIslandSolverSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample largestSolvedIslandBodyCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Largest island bodies';
		priority: 18;
		disableAsync;
		stencil: [
			self
				correlationChartFor: available
				valueX: #largestSolvedIslandBodyCount
				titleX: 'Largest solved island body count' ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtLargestIslandConstraintsCorrelationFor: aView [
	<gtView>
	| available |
	self isIslandSolverSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample largestSolvedIslandConstraintCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Largest island constraints';
		priority: 19;
		disableAsync;
		stencil: [
			self
				correlationChartFor: available
				valueX: #largestSolvedIslandConstraintCount
				titleX: 'Largest solved island constraint count' ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtSolvedIslandConstraintsCorrelationFor: aView [
	<gtView>
	| available |
	self isIslandSolverSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample solvedIslandConstraintCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Solver constraints';
		priority: 20;
		disableAsync;
		stencil: [
			self
				correlationChartFor: available
				valueX: #solvedIslandConstraintCount
				titleX: 'Solved-island constraint count' ]
]


{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtSolverContactPointsCorrelationFor: aView [
	<gtView>
	| available |
	self isIslandSolverSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample solverContactPointCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Contact points';
		priority: 21;
		disableAsync;
		stencil: [ self correlationChartFor: available valueX: #solverContactPointCount titleX: 'Contact points solved' ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtSolverWarmStartedPointsCorrelationFor: aView [
	<gtView>
	| available |
	self isIslandSolverSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample solverWarmStartedContactPointCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Warm-started points';
		priority: 22;
		disableAsync;
		stencil: [ self correlationChartFor: available valueX: #solverWarmStartedContactPointCount titleX: 'Warm-started contact points' ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtSolverRestitutionCorrelationFor: aView [
	<gtView>
	| available |
	self isIslandSolverSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample solverRestitutionCandidatePointCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Restitution';
		priority: 23;
		disableAsync;
		stencil: [ self correlationChartFor: available valueX: #solverRestitutionCandidatePointCount titleX: 'Restitution candidate points' ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtSolverJointConstraintsCorrelationFor: aView [
	<gtView>
	| available |
	self isIslandSolverSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample solverJointConstraintCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Joint constraints';
		priority: 24;
		disableAsync;
		stencil: [ self correlationChartFor: available valueX: #solverJointConstraintCount titleX: 'Joint constraints solved' ]
]

{ #category : 'testing' }
CFPhysicsTelemetrySpanStatistics >> isPairFinderSpan [
	^ self name asString = CFPhysicsPairFinderStage name asString
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtPairFinderEvidenceFor: aView [
	<gtView>
	self isPairFinderSpan ifFalse: [ ^ aView empty ].
	^ aView columnedList
		title: 'Pair finder evidence';
		priority: 17;
		items: [ {
			'Average bodies entered' -> (self averageSampleValue: #pairFinderEntryCount).
			'Maximum bodies entered' -> (self maximumSampleValue: #pairFinderEntryCount).
			'Average active-set comparisons' -> (self averageSampleValue: #pairFinderComparisonCount).
			'Maximum active-set comparisons' -> (self maximumSampleValue: #pairFinderComparisonCount).
			'Average accepted pairs' -> (self averageSampleValue: #pairFinderAcceptedPairCount).
			'Maximum accepted pairs' -> (self maximumSampleValue: #pairFinderAcceptedPairCount).
			'Average maximum active entries' -> (self averageSampleValue: #pairFinderMaximumActiveCount).
			'Maximum active entries' -> (self maximumSampleValue: #pairFinderMaximumActiveCount) } ];
		column: 'Measured fact' text: #key;
		column: 'Value' text: #value;
		send: #value
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtPairFinderComparisonsCorrelationFor: aView [
	<gtView>
	| available |
	self isPairFinderSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample pairFinderComparisonCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Pair comparisons';
		priority: 18;
		disableAsync;
		stencil: [
			self
				correlationChartFor: available
				valueX: #pairFinderComparisonCount
				titleX: 'Active-set comparisons' ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtPairFinderAcceptedPairsCorrelationFor: aView [
	<gtView>
	| available |
	self isPairFinderSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample pairFinderAcceptedPairCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Accepted pairs';
		priority: 19;
		disableAsync;
		stencil: [
			self
				correlationChartFor: available
				valueX: #pairFinderAcceptedPairCount
				titleX: 'Accepted pair count' ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtPairFinderActiveSetCorrelationFor: aView [
	<gtView>
	| available |
	self isPairFinderSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample pairFinderMaximumActiveCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Active set';
		priority: 20;
		disableAsync;
		stencil: [
			self
				correlationChartFor: available
				valueX: #pairFinderMaximumActiveCount
				titleX: 'Maximum active entries' ]
]



{ #category : 'testing' }
CFPhysicsTelemetrySpanStatistics >> isConstraintPreparationSpan [
	^ self name asString = CFPhysicsConstraintPreparationStage name asString
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtConstraintPreparationEvidenceFor: aView [
	<gtView>
	self isConstraintPreparationSpan ifFalse: [ ^ aView empty ].
	^ aView columnedList
		title: 'Preparation evidence';
		priority: 17;
		items: [ {
			'Average prepared contact constraints' -> (self averageSampleValue: #preparedContactConstraintCount).
			'Average continued contact constraints' -> (self averageSampleValue: #continuedPreparedContactConstraintCount).
			'Average began contact constraints' -> (self averageSampleValue: #beganPreparedContactConstraintCount).
			'Average prepared contact points' -> (self averageSampleValue: #preparedContactPointCount).
			'Average reusable contact points' -> (self averageSampleValue: #reusablePreparedContactPointCount).
			'Average new contact points' -> (self averageSampleValue: #newPreparedContactPointCount).
			'Average stable manifolds' -> (self averageSampleValue: #stablePreparedManifoldCount).
			'Average changed manifolds' -> (self averageSampleValue: #changedPreparedManifoldCount).
			'Average prepared joint constraints' -> (self averageSampleValue: #preparedJointConstraintCount).
			'Average prepared objects created' -> (self averageSampleValue: #preparedConstraintObjectCount).
			'Maximum prepared objects created' -> (self maximumSampleValue: #preparedConstraintObjectCount) } ];
		column: 'Measured fact' text: #key;
		column: 'Value' text: #value;
		send: #value
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtPreparedObjectsCorrelationFor: aView [
	<gtView>
	| available |
	self isConstraintPreparationSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample preparedConstraintObjectCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Prepared objects';
		priority: 18;
		disableAsync;
		stencil: [ self correlationChartFor: available valueX: #preparedConstraintObjectCount titleX: 'Prepared constraint objects created' ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtPreparedContactPointsCorrelationFor: aView [
	<gtView>
	| available |
	self isConstraintPreparationSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample preparedContactPointCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Prepared points';
		priority: 19;
		disableAsync;
		stencil: [ self correlationChartFor: available valueX: #preparedContactPointCount titleX: 'Contact points prepared' ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtReusableContactPointsCorrelationFor: aView [
	<gtView>
	| available |
	self isConstraintPreparationSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample reusablePreparedContactPointCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'Reusable points';
		priority: 20;
		disableAsync;
		stencil: [ self correlationChartFor: available valueX: #reusablePreparedContactPointCount titleX: 'Structurally reusable contact points' ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanStatistics >> gtNewContactPointsCorrelationFor: aView [
	<gtView>
	| available |
	self isConstraintPreparationSpan ifFalse: [ ^ aView empty ].
	available := self samples reject: [ :sample | sample newPreparedContactPointCount isNil ].
	available size < 2 ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'New points';
		priority: 21;
		disableAsync;
		stencil: [ self correlationChartFor: available valueX: #newPreparedContactPointCount titleX: 'New or changed contact points' ]
]
