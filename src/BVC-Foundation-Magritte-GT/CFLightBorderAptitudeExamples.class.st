Class {
	#name : 'CFLightBorderAptitudeExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> cardWith: anAptitude borderWidth: aNumber [
	^ self
		cardWith: anAptitude
		geometry: (BlRoundedRectangleGeometry cornerRadius: 16)
		borderWidth: aNumber
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> cardWith: anAptitude geometry: aGeometry borderWidth: aNumber [
	^ self
		cardWithAptitudes: { anAptitude }
		geometry: aGeometry
		borderWidth: aNumber
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> cardWithAptitudes: aptitudes geometry: aGeometry borderWidth: aNumber [
	| anElement |
	anElement := BlElement new
		size: 280 @ 160;
		geometry: aGeometry;
		background: (Color black alpha: 0.1);
		outskirts: BlOutskirts inside;
		border: (BlBorder paint: (Color blue alpha: 0.5) width: aNumber).
	aptitudes do: [ :anAptitude | anElement addAptitude: anAptitude ].
	^ anElement
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> elementWith: anAptitude [
	^ self elementWith: anAptitude borderWidth: 1
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> elementWith: anAptitude borderWidth: aNumber [
	^ self stageWith: (self cardWith: anAptitude borderWidth: aNumber)
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> elementWith: anAptitude geometry: aGeometry [
	^ self stageWith: (self cardWith: anAptitude geometry: aGeometry borderWidth: 1)
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> elementWithAptitudes: aptitudes [
	^ self stageWith: (self
		cardWithAptitudes: aptitudes
		geometry: (BlRoundedRectangleGeometry cornerRadius: 16)
		borderWidth: 1)
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> ellipse [
	<gtExample>
	<return: #BlElement>
	^ self
		elementWith: CFLightBorderAptitude new beRaised
		geometry: BlEllipseGeometry new
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> flat [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new beFlat
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> inset [
	<gtExample>
	<return: #BlElement>
	^ self lowered
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> lowered [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new beLowered
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> loweredBorder [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new beLoweredBorder
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> loweredCardAndBorder [
	<gtExample>
	<return: #BlElement>
	^ self elementWithAptitudes: {
		CFLightBorderAptitude new beLoweredCard.
		CFLightBorderAptitude new beLoweredBorder }
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> raised [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new beRaised
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> raisedBorder [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new beRaisedBorder
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> raisedCardAndBorder [
	<gtExample>
	<return: #BlElement>
	"Brick composes the two visual concerns. The first aptitude lights the
	card exterior; the second lights the inside face of its native BlBorder."
	^ self elementWithAptitudes: {
		CFLightBorderAptitude new beRaisedCard.
		CFLightBorderAptitude new beRaisedBorder }
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> raisedFromTopRight [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: (CFLightBorderAptitude new
		beRaised;
		lightDirection: 1 @ -1;
		yourself)
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> stageWith: aCard [
	^ BlElement new
		size: 400 @ 280;
		background: Color gray;
		layout: BlFrameLayout new;
		addChild: (aCard constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ]);
		yourself
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> wideRaised [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new borderWidth: 3
]
