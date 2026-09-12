"
I build the compact identity of an object from its explicit Magritte reference.

For descriptions owned by the supplied memento, isReadOnly is authoritative:
read-only values retain compact static rendering while writable values use their
normal Magritte editor bound to the same memento. I do not assign visual roles to
text fields; CFCompactObjectElement does that from the textual line it is laying out.
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
	| aStencil anEditor |
	aStencil := aDescription blocStencil.
	anEditor := aStencil
		ifNil: [
			CFMaCompactIdentityEditorElement new
				fieldViewModel: (GtMagritteFieldViewModel new
					memento: memento;
					description: aDescription;
					yourself);
				yourself ]
		ifNotNil: [
			aStencil
				memento: memento;
				description: aDescription;
				asElement ].
	^ element addReferenceTextElement: anEditor
]

{ #category : 'private - building' }
CFMaCompactReferenceElementBuilder >> newCompactFontAwesomeEditorFor: aDescription [
	| anEditor |
	anEditor := FontAwesomeIconFieldStencilBuilder new
		memento: memento;
		description: aDescription;
		asElement.
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
