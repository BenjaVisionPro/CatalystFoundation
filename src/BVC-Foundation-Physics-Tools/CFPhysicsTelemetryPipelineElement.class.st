Class {
	#name : 'CFPhysicsTelemetryPipelineElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'world',
		'trackWidth'
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
	trackWidth := 320.
	self
		hMatchParent;
		vFitContent;
		cellSpacing: 8;
		padding: (BlInsets all: 12)
]

{ #category : 'accessing' }
CFPhysicsTelemetryPipelineElement >> world: aWorld [
	world := aWorld
]

{ #category : 'building' }
CFPhysicsTelemetryPipelineElement >> build [
	| analysis root pipeline scale |
	self removeChildren.
	analysis := CFPhysicsTelemetryAnalysis world: world.
	root := analysis rootStatistics.
	root ifNil: [
		self addChild: (self label: 'Record at least one Physics step to see pipeline statistics.' emphasis: false).
		^ self ].
	pipeline := root children
		detect: [ :each | each name asString = 'Pipeline' ]
		ifNone: [ nil ].
	pipeline ifNil: [
		self addChild: (self label: 'No Pipeline span was found in the recorded Physics steps.' emphasis: false).
		^ self ].
	scale := pipeline p95Duration max: pipeline averageDuration.
	scale := scale max: 1.
	self addChild: (self headerFor: analysis pipeline: pipeline).
	self addChild: (self timelineHeaderForScale: scale).
	pipeline children do: [ :span |
		self addChild: (self stageRowFor: span pipeline: pipeline scale: scale) ]
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> headerFor: analysis pipeline: pipeline [
	| pane |
	pane := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 3;
		yourself.
	pane addChild: (self label: 'Physics pipeline timing' emphasis: true).
	pane addChild: (self label:
		analysis sampleCount asString, ' steps  ·  Average ',
		(pipeline averageMilliseconds printShowingDecimalPlaces: 3), ' ms  ·  P95 ',
		(pipeline p95Milliseconds printShowingDecimalPlaces: 3), ' ms'
		emphasis: false).
	^ pane
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> timelineHeaderForScale: scale [
	| row nameSpace mapHeader statisticsHeader |
	row := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 8;
		yourself.
	nameSpace := self label: 'Stage' emphasis: true.
	nameSpace hExact: 150.
	mapHeader := BrVerticalPane new
		hExact: trackWidth;
		vFitContent;
		cellSpacing: 2;
		addChild: (self label: 'Aligned timeline' emphasis: true);
		addChild: (BrHorizontalPane new
			hExact: trackWidth;
			vFitContent;
			addChild: ((self label: '0 ms' emphasis: false) hExact: trackWidth / 2; yourself);
			addChild: ((self label: ((scale / 1000.0) printShowingDecimalPlaces: 3), ' ms' emphasis: false) hExact: trackWidth / 2; yourself);
			yourself);
		yourself.
	statisticsHeader := self label: 'Average       P95       Ratio' emphasis: true.
	statisticsHeader hExact: 210.
	row
		addChild: nameSpace;
		addChild: mapHeader;
		addChild: statisticsHeader.
	^ row
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> stageRowFor: span pipeline: pipeline scale: scale [
	| row name maps statistics |
	row := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 8;
		padding: (BlInsets top: 3 right: 0 bottom: 3 left: 0);
		yourself.
	name := self label: span readableName emphasis: false.
	name hExact: 150.
	maps := BrVerticalPane new
		hExact: trackWidth;
		vFitContent;
		cellSpacing: 3;
		addChild: (self timelineFor: span pipeline: pipeline scale: scale statistic: #average);
		addChild: (self timelineFor: span pipeline: pipeline scale: scale statistic: #p95);
		yourself.
	statistics := BrVerticalPane new
		hExact: 210;
		vFitContent;
		cellSpacing: 3;
		addChild: (self statisticsLineFor: span statistic: #average);
		addChild: (self statisticsLineFor: span statistic: #p95);
		yourself.
	row
		addChild: name;
		addChild: maps;
		addChild: statistics.
	^ row
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> timelineFor: span pipeline: pipeline scale: scale statistic: statistic [
	| start duration relativeStart offset width remainder track leading bar trailing |
	statistic = #average
		ifTrue: [
			start := span averageStart.
			duration := span averageDuration.
			relativeStart := start - pipeline averageStart ]
		ifFalse: [
			start := span p95Start.
			duration := span p95Duration.
			relativeStart := start - pipeline p95Start ].
	relativeStart := relativeStart max: 0.
	offset := ((relativeStart / scale) * trackWidth) min: trackWidth.
	width := ((duration / scale) * trackWidth) max: 2.
	width := width min: (trackWidth - offset max: 0).
	remainder := (trackWidth - offset - width) max: 0.
	track := BrHorizontalPane new
		hExact: trackWidth;
		vExact: 14;
		background: (Color gray alpha: 0.10);
		yourself.
	leading := BlElement new
		size: offset @ 14;
		yourself.
	bar := BlElement new
		size: width @ 14;
		background: (statistic = #average
			ifTrue: [ Color gray alpha: 0.48 ]
			ifFalse: [ Color gray alpha: 0.78 ]);
		border: (BlBorder paint: (Color gray alpha: 0.65) width: 1);
		yourself.
	trailing := BlElement new
		size: remainder @ 14;
		yourself.
	track
		addChild: leading;
		addChild: bar;
		addChild: trailing.
	^ track
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> statisticsLineFor: span statistic: statistic [
	| text |
	text := statistic = #average
		ifTrue: [
			'Avg  ', (span averageMilliseconds printShowingDecimalPlaces: 3), ' ms' ]
		ifFalse: [
			'P95  ', (span p95Milliseconds printShowingDecimalPlaces: 3), ' ms   ',
			(span p95ToAverageRatio printShowingDecimalPlaces: 2), 'x' ].
	^ self label: text emphasis: false
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> label: aString emphasis: isEmphasized [
	^ BrLabel new
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (isEmphasized
				ifTrue: [ Color black ]
				ifFalse: [ Color black alpha: 0.70 ]));
		text: aString;
		yourself
]
