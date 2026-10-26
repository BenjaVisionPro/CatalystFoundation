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

{ #category : 'configuration lifecycle' }
CFObject >> initializeInContext: aContext [
]

{ #category : 'configuration lifecycle' }
CFObject >> removeFromRelationInContext: aContext [
]
