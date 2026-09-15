Class {
	#name : 'CFDetailSeparatorElement',
	#superclass : 'BlElement',
	#instVars : [
		'appearanceAptitude'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFDetailSeparatorElement >> initialize [
	super initialize.
	appearanceAptitude := BrLazyStyleCommonAptitude new
		default: [ :aStyle |
			aStyle background: self theme separator color ];
		yourself.
	self
		background: Color transparent;
		addAptitude: appearanceAptitude
]


