"
I build the compact identity of an object from its explicit Magritte reference.

For descriptions owned by the supplied memento, isReadOnly is authoritative:
read-only values retain compact static rendering while writable values use their
normal Magritte editor bound to the same memento. CFCompactObjectElement supplies
only the compact line presentation through a presentation-only description copy.
"
Class {
	#name : 'CFMaCompactReferenceElementBuilder',
	#superclass : 'CFMaReferenceElementBuilder',
	#instVars : [
		'element'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'building' }
CFMaCompactReferenceElementBuilder >> buildUsing: aReferenceDescription [
	element prepareForReference.
	self visit: aReferenceDescription asContainer.
	^ element
]

{ #category : 'accessing' }
CFMaCompactReferenceElementBuilder >> element: anElement [
	element := anElement
]

{ #category : 'private - building' }
CFMaCompactReferenceElementBuilder >> updateCompactIconValue: aValue description: aDescription transactional: isTransactional [
	| aStencil anIcon |
	aValue ifNil: [
		element hideReferenceIcon.
		^ self ].

	aStencil := aDescription blocStencil
		model: aValue;
		description: aDescription.
	isTransactional ifTrue: [ aStencil memento: memento ].
	anIcon := aStencil asElement.
	element referenceIcon: anIcon
]

{ #category : 'private - building' }
CFMaCompactReferenceElementBuilder >> newCompactTextEditorFor: aDescription [
	| editorDescription aStencil anEditor currentValue |
	editorDescription := element editorDescriptionForNextTextLine: aDescription.
	aStencil := aDescription blocStencil
		ifNil: [ GtMagritteStringEditorElementStencilBuilder new ].
	anEditor := aStencil
		memento: memento;
		description: editorDescription;
		asElement.

	anEditor
		margin: BlInsets empty;
		padding: BlInsets empty;
		hMatchParent;
		vFitContent.

	currentValue := memento readUsing: editorDescription.
	(anEditor isKindOf: BrEditor) ifTrue: [
		anEditor text: (editorDescription toString: currentValue) ].

	element
		configureEditorElement: anEditor
		description: editorDescription.
	^ element addReferenceTextElement: anEditor
]

{ #category : 'private - building' }
CFMaCompactReferenceElementBuilder >> newCompactFontAwesomeEditorFor: aDescription [
	| anEditor |
	anEditor := FontAwesomeIconFieldStencilBuilder new
		memento: memento;
		description: aDescription;
		asElement.
	element
		configureEditorElement: anEditor
		description: aDescription.
	^ element referenceIconEditor: anEditor
]

{ #category : 'visiting-description' }
CFMaCompactReferenceElementBuilder >> visitElementDescription: aDescription [
	| aLabel |
	((self hasTransactionalValueFor: aDescription)
		and: [ aDescription isReadOnly not ]) ifTrue: [
		self newCompactTextEditorFor: aDescription.
		^ self ].

	aLabel := element newReferenceTextElement.
	(self hasTransactionalValueFor: aDescription)
		ifTrue: [
			element
				updateReferenceTextElement: aLabel
				value: (memento readUsing: aDescription)
				description: aDescription.
			aLabel withAsyncSinkDo: [ :anElementSink |
				anElementSink
					sink: AsyncPeekSink new;
					whenUpdate: [ :theLabel :aSink |
						element
							updateReferenceTextElement: theLabel
							value: aSink value currentValue
							description: aDescription ].
				(memento readObservableValueUsing: aDescription) observe: anElementSink ] ]
		ifFalse: [
			element
				updateReferenceTextElement: aLabel
				value: (self staticValueFor: aDescription)
				description: aDescription ]
]

{ #category : 'visiting-description' }
CFMaCompactReferenceElementBuilder >> visitFontAwesomeIconDescription: aDescription [
	((self hasTransactionalValueFor: aDescription)
		and: [ aDescription isReadOnly not ]) ifTrue: [
		self newCompactFontAwesomeEditorFor: aDescription.
		^ self ].

	(self hasTransactionalValueFor: aDescription)
		ifTrue: [
			self
				updateCompactIconValue: (memento readUsing: aDescription)
				description: aDescription
				transactional: true.
			element withAsyncSinkDo: [ :anElementSink |
				anElementSink
					sink: AsyncPeekSink new;
					whenUpdate: [ :theElement :aSink |
						self
							updateCompactIconValue: aSink value currentValue
							description: aDescription
							transactional: true ].
				(memento readObservableValueUsing: aDescription) observe: anElementSink ] ]
		ifFalse: [
			self
				updateCompactIconValue: (self staticValueFor: aDescription)
				description: aDescription
				transactional: false ]
]
