Class {
	#name : 'CFLabelledObject',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'label'
	],
	#category : 'BVC-Foundation-Core',
	#package : 'BVC-Foundation-Core'
}

{ #category : 'accessing' }
CFLabelledObject >> label [
	^ label
]

{ #category : 'accessing' }
CFLabelledObject >> label: anObject [
	label := anObject
]

{ #category : 'as yet unclassified' }
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

{ #category : 'printing' }
CFLabelledObject >> gtDisplayOn: aStream [
	| aLabelString |
	aLabelString := self label ifNotNil: [ :aLabel | aLabel asString ].

	(aLabelString isNil or: [ aLabelString isEmpty ])
		ifTrue: [ ^ super gtDisplayOn: aStream ].

	aStream nextPutAll: aLabelString
]
