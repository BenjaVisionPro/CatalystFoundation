Extension { #name : 'CFObject' }

{ #category : '*bvc-foundation-magritte-gt' }
CFObject >> asGtMagritteViewModel [
	"Hijack GT's Magritte rendering while preserving the GT rendering contract."
	^ CFMaViewModel forObject: self
]


{ #category : '*bvc-foundation-magritte-gt' }
CFObject >> gtMagritteFor: aView [
	<gtView>
	self hasMagritteDescription ifFalse: [ ^ aView empty ].

	^ aView explicit
		title: 'Magritte';
		priority: 49;
		stencil: [ self asGtMagritteViewModel asElement margin: (BlInsets all: 10) ];
		actionButtonIcon: BrGlamorousVectorIcons debug
			label: 'Layout Debug'
			tooltip: 'Toggle form layout debug overlay'
			action: [ :aButton :aTab |
				CFMaFormLayoutDebugOverlayElement toggleIn: aTab viewContentElement ];
		actionButtonIcon: BrGlamorousVectorIcons inspect
			label: 'Memento'
			tooltip: 'Inspect Memento'
			action: [ :aButton :aTab |
				| aContentElement |
				aContentElement := aTab viewContentElement.
				aContentElement userData
					at: GtMagritteViewModel gtMementoSymbol
					ifPresent: [ :aMemento | aButton phlow spawnObject: aMemento ]
					ifAbsent: [ aContentElement
							allChildrenBreadthFirstDetect: [ :anElement |
								anElement userData includesKey: GtMagritteViewModel gtMementoSymbol ]
							ifFound: [ :anElement |
								aButton phlow
									spawnObject: (anElement userData at: GtMagritteViewModel gtMementoSymbol) ] ] ]
]
