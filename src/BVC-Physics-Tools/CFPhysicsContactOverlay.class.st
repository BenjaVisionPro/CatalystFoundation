"
I manage the contact diagnostics for one Physics overlay. My responsibility is to reconcile transient committed contact state with the contact visuals shown for the current frame.
"
Class {
	#name : 'CFPhysicsContactOverlay',
	#superclass : 'Object',
	#instVars : [
		'root',
		'context',
		'visualsByKey',
		'lastVisualState',
		'lastScopeBodies'
	],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsContactOverlay class >> in: anOverlayRoot context: aContext [
	^ self new root: anOverlayRoot; context: aContext; initializeOverlay; yourself
]

{ #category : 'controlling' }
CFPhysicsContactOverlay >> clear [
	visualsByKey valuesDo: #remove.
	visualsByKey removeAll.
	lastVisualState := nil.
	lastScopeBodies := nil.
	^ self
]

{ #category : 'private - initialization' }
CFPhysicsContactOverlay >> context: aContext [ context := aContext
]

{ #category : 'initialization' }
CFPhysicsContactOverlay >> initializeOverlay [
	visualsByKey := Dictionary new.
	lastVisualState := nil.
	lastScopeBodies := nil
]

{ #category : 'updating' }
CFPhysicsContactOverlay >> reconcileFrom: aWorldVisualState scopedToBodies: scopeBodies [
	| live states |
	lastVisualState := aWorldVisualState.
	lastScopeBodies := scopeBodies.
	states := scopeBodies
		ifNil: [ aWorldVisualState contacts ]
		ifNotNil: [ aWorldVisualState contacts select: [ :state |
			(scopeBodies includes: state firstBody) or: [ scopeBodies includes: state secondBody ] ] ].
	live := Set new.
	states do: [ :state |
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
	self clear
]

{ #category : 'private - initialization' }
CFPhysicsContactOverlay >> root: anElement [ root := anElement
]

{ #category : 'updating' }
CFPhysicsContactOverlay >> updateFrom: aWorldVisualState [
	^ self updateFrom: aWorldVisualState scopedToBodies: nil
]

{ #category : 'updating' }
CFPhysicsContactOverlay >> updateFrom: aWorldVisualState scopedToBodies: scopeBodies [
	^ self reconcileFrom: aWorldVisualState scopedToBodies: scopeBodies
]

{ #category : 'updating' }
CFPhysicsContactOverlay >> updateGeometry [
	visualsByKey valuesDo: #update.
	^ self
]

{ #category : 'accessing' }
CFPhysicsContactOverlay >> visuals [ ^ visualsByKey values asArray
]
