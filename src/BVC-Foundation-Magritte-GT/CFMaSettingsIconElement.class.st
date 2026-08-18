"I present a field icon in the fixed Foundation Settings icon tile. I own Settings-specific tile geometry and treatment; the icon and optional background come from resolved field metadata."

Class {
	#name : 'CFMaSettingsIconElement',
	#superclass : 'BrFrame',
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'initialization' }
CFMaSettingsIconElement >> initialize [
	super initialize.
	self
		size: self tileExtent;
		geometry: (BlRoundedRectangleGeometry cornerRadius: self cornerRadius);
		border: BlBorder empty;
		clipChildren: true;
		addAptitude: (CFLightBorderAptitude new
			beFlat;
			effectWidth: 2;
			raiseBorderInside;
			yourself)
]

{ #category : 'accessing' }
CFMaSettingsIconElement >> icon: anIcon background: aColor [
	| anIconElement |
	self background: (aColor
		ifNil: [ self defaultBackgroundPaint ]
		ifNotNil: [ aColor ]).
	anIconElement := anIcon.
	(anIconElement respondsTo: #color:) ifTrue: [ anIconElement color: Color white ].
	(anIconElement respondsTo: #fitInto:) ifTrue: [ anIconElement fitInto: self iconExtent ].
	anIconElement constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	self addChild: anIconElement
]

{ #category : 'private - appearance' }
CFMaSettingsIconElement >> defaultBackgroundPaint [
	^ (BlLinearGradientPaint direction: CFInterfaceLighting lightDirection asPoint)
		from: (Color black alpha: 0.42)
		to: (Color black alpha: 0.18)
]

{ #category : 'private - metrics' }
CFMaSettingsIconElement >> tileExtent [
	^ 28 @ 28
]

{ #category : 'private - metrics' }
CFMaSettingsIconElement >> iconExtent [
	^ 20 @ 20
]

{ #category : 'private - metrics' }
CFMaSettingsIconElement >> cornerRadius [
	^ 7
]
