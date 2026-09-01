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
	^ #circleQuestion
]

{ #category : 'accessing' }
CFObject class >> icon [
	"Answer an icon stencil, not an icon element."
	^ [ (FontAwesomeIcons defaultStyle icon: self defaultIcon) height: 16 ] asStencil
]

{ #category : 'configuration lifecycle' }
CFObject >> addToRelationInContext: aContext [
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
CFObject >> icon: anIcon [
	icon := anIcon
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
		beReadOnly;
		cfSerializable: true;
		yourself
]

{ #category : 'configuration lifecycle' }
CFObject >> initializeInContext: aContext [
]

{ #category : 'configuration lifecycle' }
CFObject >> removeFromRelationInContext: aContext [
]

{ #category : 'descriptions' }
CFObject >> compactIdentityReference [
	^ self iconDescription asContainer
]

