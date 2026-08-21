Class {
	#name : 'CFMaDetailPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'groupConfigurations'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPresentation >> initialize [
	super initialize.
	groupConfigurations := Dictionary new
]

{ #category : 'configuration' }
CFMaDetailPresentation >> group: aGroup configure: aBlock [
	| aConfiguration |
	aConfiguration := self groupConfigurationFor: aGroup.
	aBlock cull: aConfiguration.
	^ self
]

{ #category : 'configuration' }
CFMaDetailPresentation >> groupConfigurationFor: aGroup [
	^ groupConfigurations
		at: aGroup
		ifAbsentPut: [ CFMaDetailGroupConfiguration new ]
]

{ #category : 'configuration' }
CFMaDetailPresentation >> groupConfigurationAt: aGroup ifAbsent: aBlock [
	^ groupConfigurations at: aGroup ifAbsent: aBlock
]

{ #category : 'private - composition' }
CFMaDetailPresentation >> addLabel: aLabel field: aFieldElement to: aContainer [
	| aRow |
	aLabel
		margin: BlInsets empty;
		hFitContentLimited.
	aFieldElement
		margin: BlInsets empty;
		clipChildren: false.

	aLabel constraintsDo: [ :c |
		(c at: CFMaDetailRowLayout) beDescription ].
	aFieldElement constraintsDo: [ :c |
		(c at: CFMaDetailRowLayout) beContent ].

	aRow := BlElement new
		layout: CFMaDetailRowLayout new;
		background: Color transparent;
		border: BlBorder empty;
		padding: (BlInsets top: 6 right: 8 bottom: 6 left: 8);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		addChild: aLabel;
		addChild: aFieldElement;
		yourself.

	aContainer addChild: aRow
]
