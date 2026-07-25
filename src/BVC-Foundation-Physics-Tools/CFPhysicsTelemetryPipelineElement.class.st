Class {
	#name : 'CFPhysicsTelemetryPipelineElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'world'
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
	maximumEnd := pipeline children
		inject: pipeline p95Duration
		into: [ :maximum :span | maximum max: span p95End ].
	maximumEnd := maximumEnd max: 1.
	scale := GtPlotterLinearScale new
		domainFrom: 0 to: maximumEnd;
		rangeFrom: 0 to: 1;
		tickFormat: [ :value |
			(value / 1000.0) printShowingDecimalPlaces: 2 ];
		yourself.
	self addChild: (self axisRowFor: scale).
	pipeline children do: [ :span |
		self addChild: (self stageRowFor: span scale: scale) ]
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> axisRowFor: scale [
	| row axis statisticsSpace labels |
	row := BrHorizontalPane new
		hMatchParent;
		vExact: 34;
		cellSpacing: 12;
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
			((value / 1000.0) printShowingDecimalPlaces: 2), ' ms' ];
		labelStyle: [ :anElement |
			anElement constraintsDo: [ :c |
				c frame vertical alignBottom.
				c horizontal fitContent.
				c vertical fitContent ] ];
		yourself.
	axis addChild: labels.
	statisticsSpace := BlElement new
		size: 300 @ 1;
		yourself.
	row
		addChild: axis;
		addChild: statisticsSpace.
	^ row
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> stageRowFor: span scale: scale [
	| row chart statistics |
	row := BrHorizontalPane new
		hMatchParent;
		vExact: 34;
		cellSpacing: 12;
		yourself.
	chart := self candleFor: span scale: scale.
	statistics := self statisticsFor: span.
	row
		addChild: chart;
		addChild: statistics.
	^ row
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> candleFor: span scale: scale [
	| frame grid wick candle averageBar averageMarker leftCap rightCap p05 p25 p75 p95 averageStart averageEnd |
	p05 := scale map: span p05Start.
	p25 := scale map: span p25Start.
	p75 := scale map: span p75End.
	p95 := scale map: span p95End.
	averageStart := scale map: span averageStart.
	averageEnd := scale map: span averageEnd.
	p25 := p25 max: p05.
	p75 := p75 max: p25.
	p95 := p95 max: p75.
	averageEnd := averageEnd max: averageStart.
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
	averageBar := self horizontalElementFrom: averageStart to: averageEnd height: 7 color: (Color gray alpha: 0.78) verticalCenter: 0.5.
	leftCap := self verticalMarkerAt: p05 height: 12 color: (Color gray alpha: 0.65).
	rightCap := self verticalMarkerAt: p95 height: 12 color: (Color gray alpha: 0.65).
	averageMarker := self verticalMarkerAt: averageStart height: 18 color: (Color black alpha: 0.55).
	frame
		addChild: grid;
		addChild: wick;
		addChild: leftCap;
		addChild: rightCap;
		addChild: candle;
		addChild: averageBar;
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
			c frame horizontal alignCenterAt: (aPercentage max: 0) min: 1 ];
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
