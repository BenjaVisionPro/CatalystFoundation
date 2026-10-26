Extension { #name : #CFLabelledObject }

{ #category : '*BVC-Foundation-Magritte-Core' }
CFLabelledObject >> labelDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #label;
		label: 'Label';
		priority: 10;
		beRequired;
		cfSerializable: true;
		yourself
]
