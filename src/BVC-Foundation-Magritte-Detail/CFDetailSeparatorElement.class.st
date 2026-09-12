Class {
	#name : 'CFDetailSeparatorElement',
	#superclass : 'BlElement',
	#instVars : [
		'overlayAppearance',
		'appearanceAptitude'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFDetailSeparatorElement >> initialize [
	super initialize.
	overlayAppearance := false.
	appearanceAptitude := BrLazyStyleCommonAptitude new
		default: [ :aStyle |
			| aColor |
			aColor := self theme surfaces separatorTint.
			overlayAppearance ifTrue: [
				aColor := (aColor blocResolveColorForTheme: self theme) alpha: 0.35 ].
			aStyle background: aColor ];
		yourself.
	self
		background: Color transparent;
		addAptitude: appearanceAptitude
]

{ #category : 'configuration - appearance' }
CFDetailSeparatorElement >> overlayAppearance: aBoolean [
	overlayAppearance := aBoolean.
	appearanceAptitude updateWith: [ ]
]

