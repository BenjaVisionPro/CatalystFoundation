"
I manage the retained joint diagnostics for one Physics overlay. My responsibility is to reconcile the world's joints with their visual representations and resolve joint selections from those visuals.
"
Class {
	#name : 'CFPhysicsJointOverlay',
	#superclass : 'Object',
	#instVars : [
		'root',
		'world',
		'context',
		'visualsByJoint'
	],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsJointOverlay class >> in: aRoot world: aWorld context: aContext [
	^ self new
		root: aRoot;
		world: aWorld;
		context: aContext;
		initializeOverlay;
		yourself
]

{ #category : 'controlling' }
CFPhysicsJointOverlay >> clear [
	visualsByJoint valuesDo: #release.
	visualsByJoint removeAll.
	^ self
]

{ #category : 'accessing' }
CFPhysicsJointOverlay >> context: aContext [ context := aContext
]

{ #category : 'initialization' }
CFPhysicsJointOverlay >> initializeOverlay [
	visualsByJoint := IdentityDictionary new
]

{ #category : 'testing' }
CFPhysicsJointOverlay >> jointForEventTarget: anElement [
	| visual |
	visual := self visualForEventTarget: anElement.
	^ visual ifNil: [ nil ] ifNotNil: [ visual joint ]
]

{ #category : 'controlling' }
CFPhysicsJointOverlay >> release [ ^ self clear
]

{ #category : 'accessing' }
CFPhysicsJointOverlay >> root: anElement [ root := anElement
]

{ #category : 'updating' }
CFPhysicsJointOverlay >> update [
	^ self updateFrom: (world joints reject: [ :joint |
		(joint isKindOf: CFPhysicsDistanceJoint) and: [ joint springEnabled ] ])
]

{ #category : 'updating' }
CFPhysicsJointOverlay >> updateFrom: joints [
	| live |
	live := IdentitySet new.
	live addAll: joints.
	(visualsByJoint keys reject: [ :each | live includes: each ]) do: [ :joint |
		(visualsByJoint removeKey: joint) release ].
	joints do: [ :joint |
		visualsByJoint at: joint ifAbsentPut: [
			(CFPhysicsJointVisual diagnosticOn: joint context: context)
				addTo: root;
				yourself ] ].
	self updateGeometry.
	^ self
]

{ #category : 'updating' }
CFPhysicsJointOverlay >> updateGeometry [
	visualsByJoint valuesDo: #update.
	^ self
]

{ #category : 'testing' }
CFPhysicsJointOverlay >> visualForEventTarget: anElement [
	^ visualsByJoint values
		detect: [ :each | each includesEventTarget: anElement ]
		ifNone: [ nil ]
]

{ #category : 'accessing' }
CFPhysicsJointOverlay >> visuals [ ^ visualsByJoint values asArray
]

{ #category : 'accessing' }
CFPhysicsJointOverlay >> world: aWorld [ world := aWorld
]
