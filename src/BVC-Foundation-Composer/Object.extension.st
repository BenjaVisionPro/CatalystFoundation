Extension { #name : 'Object' }

{ #category : '*bvc-foundation-composer' }
Object >> gtComposerFor: aView [
	<gtView>
	self hasMagritteDescription ifFalse: [ ^ aView empty ].

	^ aView explicit
		title: 'Composer';
		priority: 50;
		disableAsync;
		stencil: [
			(CFComposerEditorViewModel forObject: self) asElement
				margin: (BlInsets all: 10);
				yourself ]
]
