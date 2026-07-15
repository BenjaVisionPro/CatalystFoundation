Class {
	#name : 'CFMotionEffectRecipe',
	#superclass : 'Object',
	#instVars : [ 'name', 'startBlock' ],
	#category : 'BVC-Foundation-Motion-Effects',
	#package : 'BVC-Foundation-Motion-Effects'
}

{ #category : 'instance creation' }
CFMotionEffectRecipe class >> named: aSymbol start: aBlock [
	^ self new name: aSymbol; startBlock: aBlock; yourself
]

{ #category : 'accessing' }
CFMotionEffectRecipe >> name [ ^ name ]

{ #category : 'accessing' }
CFMotionEffectRecipe >> name: aSymbol [ name := aSymbol ]

{ #category : 'playing' }
CFMotionEffectRecipe >> playOn: anElement duration: aDuration easing: anInterpolator [
	^ startBlock value: anElement value: aDuration value: anInterpolator
]

{ #category : 'accessing' }
CFMotionEffectRecipe >> startBlock: aBlock [ startBlock := aBlock ]
