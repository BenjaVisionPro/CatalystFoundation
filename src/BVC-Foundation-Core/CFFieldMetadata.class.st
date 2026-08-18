Class {
	#name : 'CFFieldMetadata',
	#superclass : 'Object',
	#instVars : [
		'icon',
		'badges',
		'information'
	],
	#category : 'BVC-Foundation-Core',
	#package : 'BVC-Foundation-Core'
}

{ #category : 'accessing' }
CFFieldMetadata >> icon [
	^ icon
]

{ #category : 'accessing' }
CFFieldMetadata >> icon: anIcon [
	icon := anIcon
]

{ #category : 'accessing' }
CFFieldMetadata >> badges [
	^ badges ifNil: [ #() ]
]

{ #category : 'accessing' }
CFFieldMetadata >> badges: aCollection [
	badges := aCollection
]

{ #category : 'accessing' }
CFFieldMetadata >> information [
	^ information
]

{ #category : 'accessing' }
CFFieldMetadata >> information: anObject [
	information := anObject
]
