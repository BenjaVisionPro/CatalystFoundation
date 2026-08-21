"I describe how a Foundation presentation should treat a field's semantic icon. Size is a relative Foundation size; chrome and background are presentation hints, not pixel geometry."

Class {
	#name : 'CFMaFieldIconConfiguration',
	#superclass : 'Object',
	#instVars : [
		'small',
		'medium',
		'large',
		'chromed',
		'backgroundColor'
	],
	#category : 'BVC-Foundation-Magritte-Core-Field',
	#package : 'BVC-Foundation-Magritte-Core',
	#tag : 'Field'
}

{ #category : 'initialization' }
CFMaFieldIconConfiguration >> initialize [
	super initialize.
	small := false.
	medium := false.
	large := false.
	chromed := nil.
	backgroundColor := nil
]

{ #category : 'private' }
CFMaFieldIconConfiguration >> clearSize [
	small := false.
	medium := false.
	large := false
]

{ #category : 'configuration - size' }
CFMaFieldIconConfiguration >> beSmall [
	self clearSize.
	small := true
]

{ #category : 'configuration - size' }
CFMaFieldIconConfiguration >> beMedium [
	self clearSize.
	medium := true
]

{ #category : 'configuration - size' }
CFMaFieldIconConfiguration >> beLarge [
	self clearSize.
	large := true
]

{ #category : 'testing - size' }
CFMaFieldIconConfiguration >> isSmall [
	^ small
]

{ #category : 'testing - size' }
CFMaFieldIconConfiguration >> isMedium [
	^ medium
]

{ #category : 'testing - size' }
CFMaFieldIconConfiguration >> isLarge [
	^ large
]

{ #category : 'configuration - chrome' }
CFMaFieldIconConfiguration >> beChromed [
	chromed := true
]

{ #category : 'configuration - chrome' }
CFMaFieldIconConfiguration >> beUnadorned [
	chromed := false
]

{ #category : 'testing - chrome' }
CFMaFieldIconConfiguration >> isChromed [
	^ chromed = true
]

{ #category : 'testing - chrome' }
CFMaFieldIconConfiguration >> isUnadorned [
	^ chromed = false
]

{ #category : 'accessing' }
CFMaFieldIconConfiguration >> backgroundColor [
	^ backgroundColor
]

{ #category : 'accessing' }
CFMaFieldIconConfiguration >> backgroundColor: aColor [
	backgroundColor := aColor
]
