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
	(presentations includes: aPresentation) ifFalse: [ ^ false ].
	self ownsCurrentTransformation ifFalse: [
		self abandon.
		^ false ].
	presentations size = 1 ifFalse: [
		self error: 'A shared transform channel cannot preserve one contribution independently' ].
	baseTransformation := appliedTransformation.
	presentations remove: aPresentation.
	appliedTransformation := nil.
	self notifyEmpty.
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
			presentations remove: aPresentation.
			self notifyEmpty.
			^ self ].
	presentations remove: aPresentation.
	presentations
		ifEmpty: [
			element transformation: baseTransformation.
			appliedTransformation := nil.
			baseTransformation := nil.
			self notifyEmpty ]
		ifNotEmpty: [ self apply ]
]

{ #category : 'accessing' }
CFMotionTransformChannel >> whenEmptyDo: aBlock [ onEmptyDo := aBlock ]
