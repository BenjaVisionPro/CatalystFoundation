Extension { #name : 'TelemetrySignal' }

{ #category : '*BVC-Foundation-Physics-Tools' }
TelemetrySignal >> physicsData [
	^ self data
		at: #physicsFrame
		ifAbsent: [ self data at: #physicsPresentation ifAbsent: [ nil ] ]
]

{ #category : '*BVC-Foundation-Physics-Tools' }
TelemetrySignal >> gtPhysicsTimingTreeFor: aView [
	<gtView>
	self physicsData ifNil: [ ^ aView empty ].
	^ aView columnedTree
		title: 'Timing tree';
		priority: 14;
		items: [ { self ping } ];
		children: [ :each | each tasks ];
		column: 'Span' text: #name;
		column: 'Duration (ms)' text: [ :each | each durationInMilliseconds ];
		column: 'GC (ms)' text: [ :each | each gcDurationInMilliseconds ];
		send: [ :each | each ]
]

{ #category : '*BVC-Foundation-Physics-Tools' }
TelemetrySignal >> gtPhysicsDataFor: aView [
	<gtView>
	self physicsData ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Physics data';
		priority: 15;
		object: [ self physicsData ];
		view: #gtItemsFor:
]

{ #category : '*BVC-Foundation-Physics-Tools' }
TelemetrySignal >> gtMapFor: aView [
	"Forward to the Map view supplied by the installed Pharo Telemetry/GT integration.
	The public tab is titled Map, but its defining selector is not part of the
	Telemetry model API and differs from the selector assumed by the Physics view."
	| mapView |
	self class allMethods do: [ :method |
		(mapView isNil
			and: [ method selector ~= #gtMapFor:
			and: [ method numArgs = 1
			and: [ method hasPragmaNamed: #gtView ] ] ]) ifTrue: [
			[ | candidate |
			candidate := self perform: method selector with: aView.
			(candidate notNil and: [ candidate title = 'Map' ])
				ifTrue: [ mapView := candidate ] ]
				on: Error
				do: [ :error | "A different GT view may not be applicable to this signal." ] ] ].
	^ mapView ifNil: [ aView empty ]
]
