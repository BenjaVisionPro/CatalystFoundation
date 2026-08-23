Class {
	#name : 'CFMaDetailAddPopupElement',
	#superclass : 'CFMaDetailPopupElement',
	#traits : 'TBrEnableable',
	#instVars : [
		'activeBackgroundColor'
	],
	#classTraits : 'TBrEnableable classTrait',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailAddPopupElement >> initialize [
	| anInset |
	super initialize.
	activeBackgroundColor := nil.
	self removeChild: valueLabel.
	anInset := (CFMaDetailPopupMetrics controlHeight
		- CFMaDetailPopupMetrics indicatorExtent y) / 2.
	self
		padding: (BlInsets all: anInset);
		geometry: BlCircleGeometry new
]


{ #category : 'private - appearance' }
CFMaDetailAddPopupElement >> popupBackgroundColor [
	^ activeBackgroundColor ifNil: [ super popupBackgroundColor ]
]

{ #category : 'private - appearance' }
CFMaDetailAddPopupElement >> popupBackgroundColor: aColor [
	activeBackgroundColor := aColor.
	self updatePopupAppearance
]

{ #category : 'private - instance creation' }
CFMaDetailAddPopupElement >> newIndicator [
	^ (FontAwesomeIcons icon: #circlePlus)
		size: CFMaDetailPopupMetrics indicatorGlyphExtent;
		color: (Color black alpha: 0.72);
		yourself
]

{ #category : 'layout' }
CFMaDetailAddPopupElement >> supportsBaseline [
	^ false
]
