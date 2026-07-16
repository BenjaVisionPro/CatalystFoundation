Class {
	#name : 'CFMotionEffectRecipe',
	#superclass : 'Object',
	#instVars : [ 'name', 'startBlock', 'options', 'duration', 'easing' ],
	#category : 'BVC-Foundation-Motion-Effects',
	#package : 'BVC-Foundation-Motion-Effects'
}

{ #category : 'instance creation' }
CFMotionEffectRecipe class >> named: aSymbol start: aBlock [
	^ self new name: aSymbol; startBlock: aBlock; yourself
]

{ #category : 'configuration' }
CFMotionEffectRecipe >> distance: aNumber [
	options at: #distance put: aNumber.
	^ self
]

{ #category : 'configuration' }
CFMotionEffectRecipe >> continuation: aBlock [
	options at: #continuation put: aBlock.
	^ self
]

{ #category : 'accessing' }
CFMotionEffectRecipe >> distance [ ^ options at: #distance ]

{ #category : 'configuration' }
CFMotionEffectRecipe >> duration: aDuration [
	duration := aDuration.
	^ self
]

{ #category : 'accessing' }
CFMotionEffectRecipe >> duration [ ^ duration ]

{ #category : 'accessing' }
CFMotionEffectRecipe >> easing [ ^ easing ]

{ #category : 'configuration' }
CFMotionEffectRecipe >> easing: anInterpolator [
	easing := anInterpolator.
	^ self
]

{ #category : 'initialization' }
CFMotionEffectRecipe >> initialize [
	super initialize.
	options := Dictionary new
]

{ #category : 'accessing' }
CFMotionEffectRecipe >> name [ ^ name ]

{ #category : 'accessing' }
CFMotionEffectRecipe >> name: aSymbol [ name := aSymbol ]

{ #category : 'playing' }
CFMotionEffectRecipe >> playOn: anElement duration: aDuration easing: anInterpolator [
	^ startBlock
		value: anElement
		value: (duration ifNil: [ aDuration ])
		value: (easing ifNil: [ anInterpolator ])
		value: self
]

{ #category : 'playing' }
CFMotionEffectRecipe >> playAfter: aPreviousOperation on: anElement duration: aDuration easing: anInterpolator [
	| continuationBlock |
	continuationBlock := options at: #continuation ifAbsent: [ ^ self playOn: anElement duration: aDuration easing: anInterpolator ].
	^ continuationBlock
		value: aPreviousOperation
		value: anElement
		value: (duration ifNil: [ aDuration ])
		value: (easing ifNil: [ anInterpolator ])
]

{ #category : 'accessing' }
CFMotionEffectRecipe >> scale [ ^ options at: #scale ]

{ #category : 'configuration' }
CFMotionEffectRecipe >> scale: aPoint [
	options at: #scale put: aPoint.
	^ self
]

{ #category : 'accessing' }
CFMotionEffectRecipe >> startBlock: aBlock [ startBlock := aBlock ]
