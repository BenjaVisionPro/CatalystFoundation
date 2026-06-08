Class {
	#name : 'CFObject',
	#superclass : 'Object',
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
CFObject class >> icon [
	"Answer an icon stencil, not an icon element."
	^ [ FontAwesomeIcons defaultStyle icon: self defaultIcon ] asStencil
]

{ #category : 'accessing' }
CFObject >> icon [
	"Answer an icon stencil, not an icon element."
	^ self class icon
]

{ #category : 'as yet unclassified' }
CFObject >> iconDescription [
	<magritteDescription>
	^ FontAwesomeIconDescription new
		accessor: #defaultIcon;
		label: 'Icon';
		default: self defaultIcon;
		priority: 5;
		iconHeight: 32;
		beReadOnly;
		yourself
]
