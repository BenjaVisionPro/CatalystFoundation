Extension { #name : #CFObject }

{ #category : '*BVC-Foundation-Magritte-GT' }
CFObject >> asElement [
	^ self asGtMagritteViewModel asElement
]

{ #category : '*BVC-Foundation-Magritte-GT' }
CFObject >> asGtMagritteViewModel [
	"Hijack GT's Magritte rendering while preserving the GT rendering contract."
	^ CFMaViewModel forObject: self
]

{ #category : '*BVC-Foundation-Magritte-GT' }
CFObject >> gtMagritteFor: aView [
	<gtView>
	self hasMagritteDescription ifFalse: [ ^ aView empty ].

	^ aView explicit
		title: 'Magritte';
		priority: 49;
		disableAsync;
		stencil: [
			self asElement asScrollableElement ];
		actionToggleIcon: CFMaFormLayoutDebugOverlayElement debugIconOff
			label: 'Layout Debug'
			tooltip: 'Toggle form layout debug overlay'
			activated: [ :aButton :aTab :anEvent |
				CFMaFormLayoutDebugOverlayElement
					setEnabled: true
					in: aTab viewContentElement
					button: aButton ]
			deactivated: [ :aButton :aTab :anEvent |
				CFMaFormLayoutDebugOverlayElement
					setEnabled: false
					in: aTab viewContentElement
					button: aButton ];
		actionButtonIcon: [ (FontAwesomeIcons defaultStyle icon: #file)
				size: 16 @ 16;
				yourself ] asStencil
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

{ #category : '*BVC-Foundation-Magritte-GT' }
CFObject class >> icon [
	"Answer an icon stencil, not an icon element."
	^ [ (FontAwesomeIcons defaultStyle icon: self defaultIcon) height: 16 ] asStencil
]

{ #category : '*BVC-Foundation-Magritte-GT' }
CFObject >> iconDescription [
	<magritteDescription>
	^ FontAwesomeIconDescription new
		accessor: #icon;
		label: 'Icon';
		default: self defaultIcon;
		priority: 5;
		iconHeight: 32;
		beReadOnly;
		cfSerializable: true;
		yourself
]
