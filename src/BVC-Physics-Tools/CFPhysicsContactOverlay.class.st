Class {
	#name : 'CFPhysicsContactOverlay',
	#superclass : 'Object',
	#instVars : [ 'root', 'context', 'visualsByKey', 'lastVisualState' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
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
{ #category : 'updating' }
CFPhysicsContactOverlay >> updateFrom: aWorldVisualState [
	| live |
	lastVisualState == aWorldVisualState ifTrue: [
		visualsByKey valuesDo: #update.
		^ self ].
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
CFPhysicsContactOverlay >> clear [
	visualsByKey valuesDo: #remove.
	visualsByKey removeAll.
	lastVisualState := nil.
	^ self
]

{ #category : 'controlling' }
CFPhysicsContactOverlay >> release [
	self clear
]
