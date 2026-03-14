Class {
	#name : 'CFObject',
	#superclass : 'Object',
	#instVars : [
		'icon'
	],
	#category : 'BVC-Foundation-Core',
	#package : 'BVC-Foundation-Core'
}

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
	^ CFMaFontAwesomeIconDescription new
		accessor: #icon;
		label: 'Icon';
		default: #addressCard;
		priority: 5;
		styleName: 'light';
		iconSize: 32 @ 32;
		yourself
]
