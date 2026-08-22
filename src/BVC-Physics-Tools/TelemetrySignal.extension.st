Extension { #name : 'TelemetrySignal' }

{ #category : '*BVC-Physics-Tools' }
TelemetrySignal >> gtPhysicsDataFor: aView [
	<gtView>
	self physicsData ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Physics data';
		priority: 15;
		object: [ self physicsData ];
		view: #gtItemsFor:
]

{ #category : '*BVC-Physics-Tools' }
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

{ #category : '*BVC-Physics-Tools' }
TelemetrySignal >> physicsData [
	^ self data
		at: #physicsFrame
		ifAbsent: [ self data at: #physicsPresentation ifAbsent: [ nil ] ]
]
