Class {
	#name : 'CFPhysicsContactOverlay',
	#superclass : 'Object',
	#instVars : [ 'root', 'context', 'visualsByKey', 'lastVisualState' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsContactOverlay class >> in: anOverlayRoot context: aContext [
	^ self new root: anOverlayRoot; context: aContext; initializeOverlay; yourself
]

{ #category : 'private - initialization' }
CFPhysicsContactOverlay >> root: anElement [ root := anElement ]
{ #category : 'private - initialization' }
CFPhysicsContactOverlay >> context: aContext [ context := aContext ]

{ #category : 'initialization' }
CFPhysicsContactOverlay >> initializeOverlay [
	visualsByKey := Dictionary new.
	lastVisualState := nil
]

{ #category : 'accessing' }
CFPhysicsContactOverlay >> visuals [ ^ visualsByKey values asArray ]
{ #category : 'accessing' }
CFPhysicsContactOverlay >> elements [
	"Compatibility for existing inspector/tests: answer the retained contact visuals."
	^ self visuals
]

{ #category : 'updating' }
CFPhysicsContactOverlay >> updateFrom: aWorldVisualState [
	| live |
	lastVisualState == aWorldVisualState ifTrue: [ ^ self ].
	lastVisualState := aWorldVisualState.
	live := Set new.
	aWorldVisualState contacts do: [ :state |
		| visual |
		live add: state key.
		visual := visualsByKey at: state key ifAbsentPut: [ CFPhysicsContactVisual in: root context: context ].
		visual updateFrom: state ].
	(visualsByKey keys reject: [ :key | live includes: key ]) do: [ :key |
		(visualsByKey removeKey: key) remove ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsContactOverlay >> release [
	visualsByKey valuesDo: #remove.
	visualsByKey removeAll.
	lastVisualState := nil
]
