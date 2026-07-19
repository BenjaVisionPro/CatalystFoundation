"
I compose every active Motion transform contribution for one BlElement within one CFMotionCoordinator.

I capture the element's existing transformation when my first presentation registers. I retain presentations in stable registration order and rebuild one composite transformation whenever any contribution changes. Releasing one presentation removes only that contribution; releasing the last restores the transformation that existed before Motion took ownership.

I also detect external replacement of the element transformation. In that case I abandon all presentations rather than overwrite application state I no longer own. A coordinator owns at most one of me per element and removes me when I become empty.
"
Class {
	#name : 'CFMotionTransformChannel',
	#superclass : 'Object',
	#instVars : [ 'element', 'baseTransformation', 'appliedTransformation', 'presentations', 'onEmptyDo' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionTransformChannel class >> on: anElement [
	^ self new element: anElement; yourself
]

{ #category : 'initialization' }
CFMotionTransformChannel >> initialize [
	super initialize.
	presentations := OrderedCollection new
]

{ #category : 'private - applying' }
CFMotionTransformChannel >> apply [
	| composite |
	presentations isEmpty ifTrue: [ ^ false ].
	(appliedTransformation notNil and: [ self ownsCurrentTransformation not ]) ifTrue: [
		self abandon.
		^ false ].
	composite := BlElementCompositeTransformation new.
	composite add: baseTransformation asElementTransformation.
	presentations do: [ :each | each addContributionTo: composite ].
	appliedTransformation := composite asCachedTransformation.
	element transformation: appliedTransformation.
	^ true
]

{ #category : 'private - controlling' }
CFMotionTransformChannel >> abandon [
	| abandoned |
	abandoned := presentations asArray.
	presentations removeAll.
	appliedTransformation := nil.
	baseTransformation := nil.
	abandoned do: [ :each | each relinquishOwnership ].
	self notifyEmpty
]

{ #category : 'controlling' }
CFMotionTransformChannel >> adopt: aPresentation [
	| index frozenContribution |
	index := presentations indexOf: aPresentation ifAbsent: [ ^ false ].
	self ownsCurrentTransformation ifFalse: [
		self abandon.
		^ false ].
	frozenContribution := CFMotionFrozenTransformContribution
		scale: aPresentation scale
		rotation: aPresentation rotation
		translation: aPresentation translation.
	frozenContribution transformOrigin: aPresentation transformOrigin.
	presentations at: index put: frozenContribution.
	self hasActivePresentations
		ifTrue: [ self apply ]
		ifFalse: [ self bakeCurrentPresentation ].
	^ true
]

{ #category : 'accessing' }
CFMotionTransformChannel >> baseTransformation [ ^ baseTransformation ]

{ #category : 'accessing' }
CFMotionTransformChannel >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionTransformChannel >> element: anElement [ element := anElement ]

{ #category : 'testing' }
CFMotionTransformChannel >> isEmpty [ ^ presentations isEmpty ]

{ #category : 'private - controlling' }
CFMotionTransformChannel >> bakeCurrentPresentation [
	baseTransformation := appliedTransformation.
	presentations removeAll.
	appliedTransformation := nil.
	self notifyEmpty
]

{ #category : 'testing' }
CFMotionTransformChannel >> hasActivePresentations [
	^ presentations anySatisfy: [ :each | each isActive ]
]

{ #category : 'private - controlling' }
CFMotionTransformChannel >> notifyEmpty [
	presentations isEmpty ifTrue: [ onEmptyDo ifNotNil: [ onEmptyDo cull: self ] ]
]

{ #category : 'testing' }
CFMotionTransformChannel >> ownsCurrentTransformation [
	^ appliedTransformation notNil and: [ element transformation == appliedTransformation ]
]

{ #category : 'controlling' }
CFMotionTransformChannel >> register: aPresentation [
	presentations isEmpty ifTrue: [
		baseTransformation := element transformation ]
	ifFalse: [
		self ownsCurrentTransformation ifFalse: [
			self abandon.
			^ false ] ].
	presentations add: aPresentation.
	^ self apply
]

{ #category : 'controlling' }
CFMotionTransformChannel >> release: aPresentation [
	(presentations includes: aPresentation) ifFalse: [ ^ self ].
	self ownsCurrentTransformation
		ifFalse: [
			self abandon.
			^ self ].
	presentations remove: aPresentation.
	presentations ifEmpty: [
			element transformation: baseTransformation.
			appliedTransformation := nil.
			baseTransformation := nil.
			self notifyEmpty.
			^ self ].
	self hasActivePresentations
		ifTrue: [ self apply ]
		ifFalse: [ self bakeCurrentPresentation ]
]

{ #category : 'accessing' }
CFMotionTransformChannel >> whenEmptyDo: aBlock [ onEmptyDo := aBlock ]
