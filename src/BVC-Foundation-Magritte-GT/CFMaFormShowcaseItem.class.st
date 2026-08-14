"I represent a small related object used by the Foundation Magritte form showcase."

Class {
	#name : 'CFMaFormShowcaseItem',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'detail',
		'enabled',
		'score',
		'status'
	],
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples' }
CFMaFormShowcaseItem class >> exampleNamed: aString score: aNumber status: aSymbol [
	^ self new
		label: aString;
		detail: 'A nested object used to exercise Foundation relation presentation.';
		score: aNumber;
		status: aSymbol;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcaseItem >> detail [
	^ detail
]

{ #category : 'accessing' }
CFMaFormShowcaseItem >> detail: aString [
	detail := aString
]

{ #category : 'descriptions' }
CFMaFormShowcaseItem >> detailDescription [
	<magritteDescription>
	^ MAMemoDescription new
		accessor: #detail;
		label: 'Detail';
		comment: 'A multi-line field inside a related object.';
		group: 'Details';
		priority: 20;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcaseItem >> enabled [
	^ enabled
]

{ #category : 'accessing' }
CFMaFormShowcaseItem >> enabled: aBoolean [
	enabled := aBoolean
]

{ #category : 'descriptions' }
CFMaFormShowcaseItem >> enabledDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #enabled;
		label: 'Enabled';
		group: 'Details';
		priority: 30;
		yourself
]

{ #category : 'initialization' }
CFMaFormShowcaseItem >> initialize [
	super initialize.
	self label: 'Showcase item'.
	detail := 'A nested object used to exercise Foundation relation presentation.'.
	enabled := true.
	score := 50.
	status := #active
]

{ #category : 'accessing' }
CFMaFormShowcaseItem >> score [
	^ score
]

{ #category : 'accessing' }
CFMaFormShowcaseItem >> score: aNumber [
	score := aNumber
]

{ #category : 'descriptions' }
CFMaFormShowcaseItem >> scoreDescription [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #score;
		label: 'Score';
		group: 'Details';
		priority: 40;
		beRequired;
		addCondition: [ :aValue | aValue isNumber and: [ aValue between: 0 and: 100 ] ]
			labelled: 'Score must be between 0 and 100';
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcaseItem >> status [
	^ status
]

{ #category : 'accessing' }
CFMaFormShowcaseItem >> status: aSymbol [
	status := aSymbol
]

{ #category : 'descriptions' }
CFMaFormShowcaseItem >> statusDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		accessor: #status;
		label: 'Status';
		group: 'Details';
		priority: 50;
		options: #(draft active archived);
		beRequired;
		yourself
]
