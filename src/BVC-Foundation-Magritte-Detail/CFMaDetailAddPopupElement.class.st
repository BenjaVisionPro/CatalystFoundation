Class {
	#name : 'CFMaDetailAddPopupElement',
	#superclass : 'CFMaDetailPopupElement',
	#traits : 'TBrEnableable',
	#classTraits : 'TBrEnableable classTrait',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailAddPopupElement >> initialize [
	super initialize.
	self removeChild: valueLabel
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
