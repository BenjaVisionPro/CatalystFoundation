"I present one explicit selected/unselected popup state during a Motion timeline."

Class {
    #name : 'CFMaDetailPopupSelectionMotionBehaviour',
    #superclass : 'CFMotionBehaviour',
    #instVars : [
        'element',
        'selected',
        'originSelected'
    ],
    #category : 'BVC-Foundation-Magritte-Detail',
    #package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'instance creation' }
CFMaDetailPopupSelectionMotionBehaviour class >> on: anElement selected: aBoolean [
    ^ self new
        element: anElement;
        selected: aBoolean;
        yourself
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionBehaviour >> animationTarget [
    ^ element
]

{ #category : 'private - presentation' }
CFMaDetailPopupSelectionMotionBehaviour >> applySelection [
    selected
        ifTrue: [ element states addState: BlElementState selected ]
        ifFalse: [ element states removeState: BlElementState selected ]
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> applyDestination [
    self applySelection
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> applyProgress: aProgress [
    self applySelection
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> captureOrigin [
    originSelected ifNil: [
        originSelected := element states hasState: BlElementState selected ]
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionBehaviour >> element: anElement [
    element := anElement
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionBehaviour >> propertyKey [
    ^ CFMotionPropertyKey
        element: element
        property: self class
]

{ #category : 'playing' }
CFMaDetailPopupSelectionMotionBehaviour >> restoreOrigin [
    originSelected ifNil: [ ^ self ].
    originSelected
        ifTrue: [ element states addState: BlElementState selected ]
        ifFalse: [ element states removeState: BlElementState selected ]
]

{ #category : 'controlling' }
CFMaDetailPopupSelectionMotionBehaviour >> reversed [
    ^ self class on: element selected: selected not
]

{ #category : 'accessing' }
CFMaDetailPopupSelectionMotionBehaviour >> selected: aBoolean [
    selected := aBoolean
]
