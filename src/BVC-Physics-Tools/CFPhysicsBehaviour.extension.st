Extension { #name : 'CFPhysicsBehaviour' }

{ #category : '*bvc-physics-tools' }
CFPhysicsBehaviour >> asGtMagritteViewModel [
	^ CFMaViewModel forObject: self
]

{ #category : '*bvc-physics-tools' }
CFPhysicsBehaviour >> configurationDescriptions [
	^ (self magritteDescription select: #cfSerializable)
		sorted: [ :first :second | first priority < second priority ]
]

{ #category : '*bvc-physics-tools' }
CFPhysicsBehaviour >> configurationSource [
	^ self configurationSourceUsing: nil
]

{ #category : '*bvc-physics-tools' }
CFPhysicsBehaviour >> configurationSourceUsing: aMemento [
	^ String streamContents: [ :stream |
		stream
			nextPutAll: self class name;
			nextPutAll: ' new';
			cr.
		self configurationSourceSetupOn: stream.
		self configurationDescriptions do: [ :description |
			| value |
			value := aMemento
				ifNil: [ self perform: description accessor selector ]
				ifNotNil: [ aMemento readUsing: description ].
			stream
				nextPutAll: '    ';
				nextPutAll: description accessor selector asString;
				nextPutAll: ': ';
				nextPutAll: value storeString;
				nextPutAll: ';';
				cr ].
		stream nextPutAll: '    start' ]
]

{ #category : '*bvc-physics-tools' }
CFPhysicsBehaviour >> configurationSourceSetupOn: aStream [
	aStream
		nextPutAll: '    target: aTarget;';
		cr
]

{ #category : '*bvc-physics-tools' }
CFPhysicsBehaviour >> gtConfigurationFor: aView [
	<gtView>
	self hasMagritteDescription ifFalse: [ ^ aView empty ].

	^ aView explicit
		title: 'Configuration';
		priority: 20;
		disableAsync;
		stencil: [
			self asGtMagritteViewModel asElement
				margin: (BlInsets all: 10);
				yourself ];
		actionButtonIcon: BrGlamorousVectorIcons clipboard
			label: 'Copy source'
			tooltip: 'Copy Smalltalk source for this configuration'
			action: [ :aButton :aTab |
				| content source |
				content := aTab viewContentElement.
				source := self configurationSource.
				content userData
					at: GtMagritteViewModel gtMementoSymbol
					ifPresent: [ :memento | source := self configurationSourceUsing: memento ].
				content
					allChildrenBreadthFirstDetect: [ :element |
						element userData includesKey: GtMagritteViewModel gtMementoSymbol ]
					ifFound: [ :element |
						source := self configurationSourceUsing:
							(element userData at: GtMagritteViewModel gtMementoSymbol) ].
				Clipboard clipboardText: source ]
]


{ #category : '*bvc-physics-tools' }
CFPhysicsBehaviour >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsBehaviourInspector newContent
]
