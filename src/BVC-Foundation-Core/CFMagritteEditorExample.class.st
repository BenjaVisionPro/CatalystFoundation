Class {
	#name : 'CFMagritteEditorExample',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'summary',
		'enabled',
		'priority',
		'status'
	],
	#category : 'BVC-Foundation-Core',
	#package : 'BVC-Foundation-Core'
}

{ #category : 'examples' }
CFMagritteEditorExample class >> exampleArchived [
	<gtExample>
	^ self new
		label: 'Archived example';
		enabled: false;
		priority: 10;
		status: #archived;
		yourself
]

{ #category : 'examples' }
CFMagritteEditorExample class >> exampleDefault [
	<gtExample>
	^ self new
]

{ #category : 'examples' }
CFMagritteEditorExample class >> exampleInvalidPriority [
	<gtExample>
	^ self new
		priority: 120;
		yourself
]

{ #category : 'accessing' }
CFMagritteEditorExample >> enabled [
	^ enabled
]

{ #category : 'accessing' }
CFMagritteEditorExample >> enabled: aBoolean [
	enabled := aBoolean
]

{ #category : 'descriptions' }
CFMagritteEditorExample >> enabledDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #enabled;
		label: 'Enabled';
		priority: 40;
		yourself
]

{ #category : 'initialization' }
CFMagritteEditorExample >> initialize [
	super initialize.
	self identifier: #magritteEditorExample.
	self label: 'Editor example'.
	summary ifNil: [ summary := 'A reference object for exercising the Catalyst Foundation Magritte editor pipeline across the common field types.' ].
	enabled ifNil: [ enabled := true ].
	priority ifNil: [ priority := 50 ].
	status ifNil: [ status := #draft ].
]

{ #category : 'accessing' }
CFMagritteEditorExample >> priority [
	^ priority
]

{ #category : 'accessing' }
CFMagritteEditorExample >> priority: aNumber [
	priority := aNumber
]

{ #category : 'descriptions' }
CFMagritteEditorExample >> priorityDescription [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #priority;
		label: 'Priority';
		priority: 50;
		beRequired;
		addCondition: [ :aValue | aValue isNumber and: [ aValue between: 0 and: 100 ] ] labelled: 'Priority must be between 0 and 100';
		yourself
]

{ #category : 'accessing' }
CFMagritteEditorExample >> slug [
	| stream previousWasDash |
	stream := String streamContents: [ :aStream |
		previousWasDash := false.
		(self label ifNil: [ '' ]) asLowercase do: [ :each |
			| nextCharacter |
			nextCharacter := (each isAlphaNumeric or: [ each = $- ])
				ifTrue: [ each ]
				ifFalse: [ $- ].
			(nextCharacter = $- and: [ previousWasDash ])
				ifFalse: [ aStream nextPut: nextCharacter ].
			previousWasDash := nextCharacter = $- ] ].
	^ stream trimBoth: [ :each | each = $- ]
]

{ #category : 'descriptions' }
CFMagritteEditorExample >> slugDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #slug;
		label: 'Slug';
		priority: 70;
		beReadOnly;
		yourself
]

{ #category : 'accessing' }
CFMagritteEditorExample >> status [
	^ status
]

{ #category : 'accessing' }
CFMagritteEditorExample >> status: aSymbol [
	status := aSymbol
]

{ #category : 'descriptions' }
CFMagritteEditorExample >> statusDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		accessor: #status;
		label: 'Status';
		priority: 60;
		options: self statusOptions;
		beRequired;
		yourself
]

{ #category : 'accessing' }
CFMagritteEditorExample >> statusOptions [
	^ #(draft active archived)
]

{ #category : 'accessing' }
CFMagritteEditorExample >> summary [
	^ summary
]

{ #category : 'accessing' }
CFMagritteEditorExample >> summary: aString [
	summary := aString
]

{ #category : 'descriptions' }
CFMagritteEditorExample >> summaryDescription [
	<magritteDescription>
	^ MAMemoDescription new
		accessor: #summary;
		label: 'Summary';
		priority: 30;
		yourself
]



{ #category : 'accessing' }
CFMagritteEditorExample >> cfOperationsViewModelClass [
	^ CFMagritteEditorExampleOperationsViewModel
]

{ #category : 'accessing' }
CFMagritteEditorExample class >> cfOperationsViewModelClass [
	^ CFMagritteEditorExampleOperationsViewModel
]
