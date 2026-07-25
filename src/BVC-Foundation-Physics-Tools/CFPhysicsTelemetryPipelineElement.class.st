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
	trackWidth := 520.
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
	| analysis root pipeline origin scale |
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
	origin := pipeline p05Start.
	scale := (pipeline p95End - origin) max: 1.
	self addChild: (self headerFor: analysis pipeline: pipeline).
	self addChild: (self legendForScale: scale).
	pipeline children do: [ :span |
		self addChild: (self stageRowFor: span origin: origin scale: scale) ]
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> headerFor: analysis pipeline: pipeline [
	| pane |
	pane := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 3;
		yourself.
	pane addChild: (self label: 'Physics pipeline interval distribution' emphasis: true).
	pane addChild: (self label:
		analysis sampleCount asString, ' steps  ·  Average ',
		(pipeline averageMilliseconds printShowingDecimalPlaces: 3), ' ms  ·  P95 ',
		(pipeline p95Milliseconds printShowingDecimalPlaces: 3), ' ms'
		emphasis: false).
	pane addChild: (self label:
		'Whiskers: P05 start to P95 end  ·  Candle: P25 start to P75 end  ·  Dark bar: average interval'
		emphasis: false).
	^ pane
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> legendForScale: scale [
	| row nameSpace timeline statistics |
	row := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 8;
		yourself.
	nameSpace := self label: 'Stage' emphasis: true.
	nameSpace hExact: 165.
	timeline := BrVerticalPane new
		hExact: trackWidth;
		vFitContent;
		cellSpacing: 2;
		addChild: (self label: 'Pipeline interval candle' emphasis: true);
		addChild: (BrHorizontalPane new
			hExact: trackWidth;
			vFitContent;
			addChild: ((self label: '0 ms' emphasis: false) hExact: trackWidth / 2; yourself);
			addChild: ((self label: ((scale / 1000.0) printShowingDecimalPlaces: 3), ' ms' emphasis: false) hExact: trackWidth / 2; yourself);
			yourself);
		yourself.
	statistics := self label: 'Average       P95       Ratio       Start jitter' emphasis: true.
	statistics hExact: 310.
	row
		addChild: nameSpace;
		addChild: timeline;
		addChild: statistics.
	^ row
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> stageRowFor: span origin: origin scale: scale [
	| row name candle statistics |
	row := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 8;
		padding: (BlInsets top: 4 right: 0 bottom: 4 left: 0);
		yourself.
	name := self label: span readableName emphasis: false.
	name hExact: 165.
	candle := self candleFor: span origin: origin scale: scale.
	statistics := self statisticsFor: span.
	statistics hExact: 310.
	row
		addChild: name;
		addChild: candle;
		addChild: statistics.
	^ row
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> candleFor: span origin: origin scale: scale [
	| frame p05X p25X p75X p95X averageStartX averageEndX wick candle averageBar leftCap rightCap averageMarker |
	p05X := self xFor: span p05Start origin: origin scale: scale.
	p25X := self xFor: span p25Start origin: origin scale: scale.
	p75X := self xFor: span p75End origin: origin scale: scale.
	p95X := self xFor: span p95End origin: origin scale: scale.
	averageStartX := self xFor: span averageStart origin: origin scale: scale.
	averageEndX := self xFor: span averageEnd origin: origin scale: scale.
	p25X := p25X max: p05X.
	p75X := p75X max: p25X + 1.
	p95X := p95X max: p75X.
	averageEndX := averageEndX max: averageStartX + 1.
	frame := BrFrame new
		hExact: trackWidth;
		vExact: 26;
		layout: BlFrameLayout new;
		background: (Color gray alpha: 0.08);
		yourself.
	wick := BlElement new
		size: ((p95X - p05X) max: 1) @ 1;
		relocate: p05X @ 13;
		background: (Color gray alpha: 0.65);
		yourself.
	leftCap := BlElement new
		size: 1 @ 12;
		relocate: p05X @ 7;
		background: (Color gray alpha: 0.65);
		yourself.
	rightCap := BlElement new
		size: 1 @ 12;
		relocate: p95X @ 7;
		background: (Color gray alpha: 0.65);
		yourself.
	candle := BlElement new
		size: ((p75X - p25X) max: 2) @ 14;
		relocate: p25X @ 6;
		background: (Color gray alpha: 0.28);
		border: (BlBorder paint: (Color gray alpha: 0.55) width: 1);
		yourself.
	averageBar := BlElement new
		size: ((averageEndX - averageStartX) max: 2) @ 8;
		relocate: averageStartX @ 9;
		background: (Color gray alpha: 0.78);
		yourself.
	averageMarker := BlElement new
		size: 2 @ 18;
		relocate: averageStartX @ 4;
		background: (Color black alpha: 0.55);
		yourself.
	frame
		addChild: wick;
		addChild: leftCap;
		addChild: rightCap;
		addChild: candle;
		addChild: averageBar;
		addChild: averageMarker.
	^ frame
]

{ #category : 'private - geometry' }
CFPhysicsTelemetryPipelineElement >> xFor: aTime origin: origin scale: scale [
	| relative |
	relative := (aTime - origin) max: 0.
	^ (((relative / scale) * trackWidth) min: trackWidth) asFloat
]

{ #category : 'private - building' }
CFPhysicsTelemetryPipelineElement >> statisticsFor: span [
	^ self label:
		'Avg ', (span averageMilliseconds printShowingDecimalPlaces: 3), ' ms    ',
		'P95 ', (span p95Milliseconds printShowingDecimalPlaces: 3), ' ms    ',
		(span p95ToAverageRatio printShowingDecimalPlaces: 2), 'x    ',
		'Jitter ', (span startJitterMilliseconds printShowingDecimalPlaces: 3), ' ms'
		emphasis: false
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
