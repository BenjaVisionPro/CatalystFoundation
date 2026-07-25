Extension { #name : 'CFPhysicsMetric' }

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsMetric >> gtSummaryFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Summary';
		priority: 1;
		items: [ {
			'Name' -> self name.
			'Unit' -> self unit.
			'Latest' -> self latest.
			'Average' -> self average.
			'Minimum' -> self minimum.
			'P95' -> self p95.
			'Maximum' -> self maximum.
			'Samples' -> self sampleCount } ];
		column: 'Property' text: #key;
		column: 'Value' text: [ :association | association value printString ];
		send: #value
]

{ #category : '*BVC-Foundation-Physics-Tools' }
CFPhysicsMetric >> gtSamplesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Samples';
		priority: 2;
		items: [ self values reversed ];
		column: 'Value' text: #printString
]
