"
I build compact, read-only content for a Magritte relation reference.

I interpret the relation's reference descriptions against the related object. When a
reference description is also part of the related object's child memento, I observe that
memento value so the row reflects uncommitted edits. Specialized reference descriptions
that are not part of the child transaction are read directly from the related object.
"
Class {
	#name : 'CFMaReferenceElementBuilder',
	#superclass : 'MAVisitor',
	#instVars : [
		'object',
		'memento',
		'labelAptitude',
		'elements'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing' }
CFMaReferenceElementBuilder >> memento: aMemento [
	memento := aMemento
]

{ #category : 'accessing' }
CFMaReferenceElementBuilder >> object: anObject [
	object := anObject
]


{ #category : 'initialization' }
CFMaReferenceElementBuilder >> initialize [
	super initialize.
	labelAptitude := BrGlamorousLabelAptitude new
		glamorousRegularFont;
		foreground: (Color black alpha: 0.88);
		yourself
]

{ #category : 'accessing' }
CFMaReferenceElementBuilder >> labelAptitude: anAptitude [
	labelAptitude := anAptitude
]

{ #category : 'building' }
CFMaReferenceElementBuilder >> buildUsing: aReferenceDescription [
	| aContainer |
	elements := OrderedCollection new.
	self visit: aReferenceDescription asContainer.

	aContainer := BrHorizontalPane new
		hFitContent;
		vFitContent;
		cellSpacing: 6;
		padding: BlInsets empty;
		yourself.
	elements do: [ :anElement |
		anElement constraintsDo: [ :c | c linear vertical alignCenter ].
		aContainer addChild: anElement ].
	^ aContainer
]

{ #category : 'private - values' }
CFMaReferenceElementBuilder >> hasTransactionalValueFor: aDescription [
	memento ifNil: [ ^ false ].
	^ memento magritteDescription includes: aDescription
]

{ #category : 'private - values' }
CFMaReferenceElementBuilder >> staticValueFor: aDescription [
	^ aDescription read: object
]

{ #category : 'private - building' }
CFMaReferenceElementBuilder >> updateIconHost: aHost value: aValue description: aDescription transactional: isTransactional [
	| aStencil anIcon |
	aHost removeChildren.
	aValue ifNil: [ ^ self ].

	aStencil := aDescription blocStencil
		model: aValue;
		description: aDescription.
	isTransactional ifTrue: [ aStencil memento: memento ].
	anIcon := aStencil asElement.
	aHost addChild: anIcon
]

{ #category : 'private - building' }
CFMaReferenceElementBuilder >> updateLabel: aLabel value: aValue description: aDescription [
	| aString |
	aString := aDescription toString: aValue.
	aLabel
		text: aString asRopedText;
		visibility: (aString isEmpty
			ifTrue: [ BlVisibility gone ]
			ifFalse: [ BlVisibility visible ])
]

{ #category : 'visiting-description' }
CFMaReferenceElementBuilder >> visitContainer: aDescription [
	aDescription do: [ :each |
		each isVisible ifTrue: [ self visit: each ] ]
]

{ #category : 'visiting-description' }
CFMaReferenceElementBuilder >> visitElementDescription: aDescription [
	| aLabel |
	aLabel := BrLabel new
		aptitude: labelAptitude;
		fitContent;
		yourself.
	elements add: aLabel.

	(self hasTransactionalValueFor: aDescription)
		ifTrue: [
			self
				updateLabel: aLabel
				value: (memento readUsing: aDescription)
				description: aDescription.
			aLabel withAsyncSinkDo: [ :anElementSink |
				anElementSink
					sink: AsyncPeekSink new;
					whenUpdate: [ :theLabel :aSink |
						self
							updateLabel: theLabel
							value: aSink value currentValue
							description: aDescription ].
				(memento readObservableValueUsing: aDescription) observe: anElementSink ] ]
		ifFalse: [
			self
				updateLabel: aLabel
				value: (self staticValueFor: aDescription)
				description: aDescription ]
]

{ #category : 'visiting-description' }
CFMaReferenceElementBuilder >> visitFontAwesomeIconDescription: aDescription [
	| aHost |
	aHost := BrFrame new
		hFitContent;
		vFitContent;
		yourself.
	elements add: aHost.

	(self hasTransactionalValueFor: aDescription)
		ifTrue: [
			self
				updateIconHost: aHost
				value: (memento readUsing: aDescription)
				description: aDescription
				transactional: true.
			aHost withAsyncSinkDo: [ :anElementSink |
				anElementSink
					sink: AsyncPeekSink new;
					whenUpdate: [ :theHost :aSink |
						self
							updateIconHost: theHost
							value: aSink value currentValue
							description: aDescription
							transactional: true ].
				(memento readObservableValueUsing: aDescription) observe: anElementSink ] ]
		ifFalse: [
			self
				updateIconHost: aHost
				value: (self staticValueFor: aDescription)
				description: aDescription
				transactional: false ]
]
