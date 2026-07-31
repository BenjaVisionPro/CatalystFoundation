Extension { #name : 'TelemetryPing' }

{ #category : '*BVC-Physics-Tools' }
TelemetryPing >> gtTimingTreeFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'Timing tree';
		priority: 10;
		items: [ { self } ];
		children: [ :each | each tasks ];
		column: 'Span' text: #name;
		column: 'Duration (ms)' text: [ :each | each durationInMilliseconds ];
		column: 'GC (ms)' text: [ :each | each gcDurationInMilliseconds ];
		send: [ :each | each ]
]
