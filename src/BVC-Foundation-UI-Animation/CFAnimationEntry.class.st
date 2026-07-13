Class {
	#name : 'CFAnimationEntry',
	#superclass : 'Object',
	#instVars : [
		'animation',
		'factory',
		'looping',
		'finishRequested',
		'finishAction'
	],
	#category : 'BVC-Foundation-UI-Animation',
	#package : 'BVC-Foundation-UI-Animation'
}

{ #category : 'accessing' }
CFAnimationEntry >> animation [ ^ animation ]

{ #category : 'accessing' }
CFAnimationEntry >> animation: anAnimation [ animation := anAnimation ]

{ #category : 'accessing' }
CFAnimationEntry >> factory [ ^ factory ]

{ #category : 'accessing' }
CFAnimationEntry >> factory: aBlock [ factory := aBlock ]

{ #category : 'accessing' }
CFAnimationEntry >> finishAction [ ^ finishAction ]

{ #category : 'accessing' }
CFAnimationEntry >> finishAction: aBlock [ finishAction := aBlock ]

{ #category : 'testing' }
CFAnimationEntry >> finishRequested [ ^ finishRequested ifNil: [ false ] ]

{ #category : 'accessing' }
CFAnimationEntry >> finishRequested: aBoolean [ finishRequested := aBoolean ]

{ #category : 'testing' }
CFAnimationEntry >> looping [ ^ looping ifNil: [ false ] ]

{ #category : 'accessing' }
CFAnimationEntry >> looping: aBoolean [ looping := aBoolean ]
