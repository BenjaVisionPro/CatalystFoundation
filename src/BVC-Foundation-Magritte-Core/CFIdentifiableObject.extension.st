Extension { #name : #CFIdentifiableObject }

{ #category : '*BVC-Foundation-Magritte-Core' }
CFIdentifiableObject >> identifierDescription [
	<magritteDescription>
	^ MASymbolDescription new
		accessor: #identifier;
		label: 'Identifier';
		priority: 10;
		beRequired;
		cfSerializable: true;
		yourself
]
