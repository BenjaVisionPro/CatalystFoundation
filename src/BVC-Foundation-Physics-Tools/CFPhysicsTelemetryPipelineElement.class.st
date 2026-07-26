Class {
	#name : 'CFPhysicsTelemetryPipelineElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'world',
		'stageLabelWidth'
	],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
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
	world := aWorld
]

{ #category : 'building' }
CFPhysicsTelemetryPipelineElement >> build [
	| analysis root pipeline maximumEnd scale |
	self removeChildren.
	analysis := CFPhysicsTelemetryAnalysis world: world.
	root := analysis rootStatistics.
	root ifNil: [
		self addChild: (self emptyLabel: 'Record at least one Physics step to see pipeline statistics.').
		^ self ].
	pipeline := root children
		detect: [ :each | each name asString = 'Pipeline' ]
		ifNone: [ nil ].
	pipeline ifNil: [
		self addChild: (self emptyLabel: 'No Pipeline span was found in the recorded Physics steps.').
		^ self ].
	stageLabelWidth := self stageLabelWidthFor: pipeline children.
	maximumEnd := pipeline children
		inject: pipeline p95Duration
		into: [ :maximum :span | maximum max: span p95End ].
	maximumEnd := maximumEnd max: 1.
	scale := GtPlotterLinearScale new
		domainFrom: 0 to: maximumEnd;
		rangeFrom: 0 to: 1;
		tickFormat: [ :value | self formattedMillisecondsForMicroseconds: value ];
		yourself.
	self addChild: (self axisRowFor: scale).
	pipeline children do: [ :span |
		self addChild: (self stageRowFor: span scale: scale) ]
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
