Class {
	#name : 'CFMotionAptitude',
	#superclass : 'BrAptitude',
	#instVars : [ 'hoveredEffect', 'unhoveredEffect', 'pressedEffect', 'releasedEffect', 'enterHandler', 'leaveHandler', 'downHandler', 'upHandler', 'activeOperation' ],
	#category : 'BVC-Foundation-Motion-Effects',
	#package : 'BVC-Foundation-Motion-Effects'
}

{ #category : 'configuration' }
CFMotionAptitude >> hoveredEffect: anEffectRecipe [
	hoveredEffect := anEffectRecipe.
	^ self
]

{ #category : 'configuration' }
CFMotionAptitude >> pressedEffect: anEffectRecipe [ pressedEffect := anEffectRecipe. ^ self ]

{ #category : 'configuration' }
CFMotionAptitude >> releasedEffect: anEffectRecipe [ releasedEffect := anEffectRecipe. ^ self ]

{ #category : 'accessing' }
CFMotionAptitude >> activeOperation [ ^ activeOperation ]

{ #category : 'testing' }
CFMotionAptitude >> hasInstalledHandlers [
	^ enterHandler notNil and: [ leaveHandler notNil ]
]

{ #category : 'configuration' }
CFMotionAptitude >> unhoveredEffect: anEffectRecipe [
	unhoveredEffect := anEffectRecipe.
	^ self
]

{ #category : 'lifecycle' }
CFMotionAptitude >> onInstalledIn: anElement [
	super onInstalledIn: anElement.
	enterHandler := BlEventHandler
		on: BlMouseEnterEvent
		do: [ :anEvent | self play: hoveredEffect on: anElement ].
	leaveHandler := BlEventHandler
		on: BlMouseLeaveEvent
		do: [ :anEvent | self play: unhoveredEffect on: anElement ].
	anElement addEventHandler: enterHandler.
	anElement addEventHandler: leaveHandler.
	downHandler := BlEventHandler on: BlMouseDownEvent do: [ :anEvent | self play: pressedEffect on: anElement ].
	upHandler := BlEventHandler on: BlMouseUpEvent do: [ :anEvent | self play: releasedEffect on: anElement ].
	anElement addEventHandler: downHandler.
	anElement addEventHandler: upHandler
]

{ #category : 'lifecycle' }
CFMotionAptitude >> onUninstalledIn: anElement [
	activeOperation ifNotNil: [ activeOperation cancelAndRestore ].
	activeOperation := nil.
	enterHandler ifNotNil: [ anElement removeEventHandler: enterHandler ].
	leaveHandler ifNotNil: [ anElement removeEventHandler: leaveHandler ].
	downHandler ifNotNil: [ anElement removeEventHandler: downHandler ].
	upHandler ifNotNil: [ anElement removeEventHandler: upHandler ].
	enterHandler := nil.
	leaveHandler := nil.
	downHandler := nil.
	upHandler := nil.
	super onUninstalledIn: anElement
]

{ #category : 'private - playing' }
CFMotionAptitude >> play: anEffectRecipe on: anElement [
	activeOperation ifNotNil: [ activeOperation isRunning ifTrue: [ activeOperation cancelAndRestore ] ].
	anEffectRecipe ifNotNil: [
		activeOperation := anEffectRecipe
			playOn: anElement
			duration: 120 milliSeconds
			easing: (BlDecelerateInterpolator factor: 1.4) ]
]
