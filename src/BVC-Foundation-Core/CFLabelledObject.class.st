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
		priority: 20;
		beRequired;
		yourself
]
