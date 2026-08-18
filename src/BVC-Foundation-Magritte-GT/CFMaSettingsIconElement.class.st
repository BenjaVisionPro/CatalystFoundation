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
			effectWidth: 1.5;
			intensity: 0.5;
			raiseBorderInside;
			yourself)
]

{ #category : 'accessing' }
CFMaSettingsIconElement >> icon: anIcon background: aColor [
	| anIconElement |
	self background: (self backgroundPaintFor: aColor).
	anIconElement := anIcon.
	(anIconElement respondsTo: #color:) ifTrue: [ anIconElement color: Color white ].
	(anIconElement respondsTo: #fitInto:) ifTrue: [ anIconElement fitInto: self iconExtent ].
	anIconElement constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	self addChild: anIconElement
]

{ #category : 'private - appearance' }
CFMaSettingsIconElement >> backgroundPaintFor: aColor [
	| aBaseColor |
	aBaseColor := aColor ifNil: [ self defaultBackgroundColor ].
	^ (BlLinearGradientPaint direction: CFInterfaceLighting lightDirection asPoint)
		from: (self gradientHighlightFor: aBaseColor)
		to: (self gradientShadowFor: aBaseColor)
]

{ #category : 'private - appearance' }
CFMaSettingsIconElement >> gradientHighlightFor: aColor [
	| strength |
	strength := 0.35.
	^ Color
		r: aColor red + ((1.0 - aColor red) * strength)
		g: aColor green + ((1.0 - aColor green) * strength)
		b: aColor blue + ((1.0 - aColor blue) * strength)
		alpha: aColor alpha
]

{ #category : 'private - appearance' }
CFMaSettingsIconElement >> gradientShadowFor: aColor [
	| strength |
	strength := 0.30.
	^ Color
		r: aColor red * (1.0 - strength)
		g: aColor green * (1.0 - strength)
		b: aColor blue * (1.0 - strength)
		alpha: aColor alpha
]

{ #category : 'private - appearance' }
CFMaSettingsIconElement >> defaultBackgroundColor [
	^ Color black alpha: 0.3
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
