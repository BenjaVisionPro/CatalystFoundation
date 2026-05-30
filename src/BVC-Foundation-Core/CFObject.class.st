Class {
	#name : 'CFObject',
	#superclass : 'Object',
	#instVars : [
		'icon'
	],
	#category : 'BVC-Foundation-Core',
	#package : 'BVC-Foundation-Core'
}

{ #category : 'defaults' }
CFObject class >> defaultIcon [
	^ #questionCircle
]

{ #category : 'defaults' }
CFObject >> defaultIcon [
	^ self class defaultIcon
]

{ #category : 'accessing' }
CFObject >> icon [
	^ icon
]

{ #category : 'accessing' }
CFObject >> icon: anObject [
	icon := anObject
]

{ #category : 'as yet unclassified' }
CFObject >> iconDescription [
	<magritteDescription>
	^ FontAwesomeIconDescription new
		accessor: #icon;
		label: 'Icon';
		default: self defaultIcon;
		priority: 5;
		iconHeight: 32;
		yourself
]
