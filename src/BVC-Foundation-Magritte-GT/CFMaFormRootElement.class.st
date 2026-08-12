Class {
	#name : 'CFMaFormRootElement',
	#superclass : 'BrFrame',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : #'instance creation' }
CFMaFormRootElement class >> testingBackgroundForm [
	"A temporary visual-test asset. BlImagePatternPaint repeats this Form behind
	the generated Magritte form so translucent Foundation chrome is visible."
	^ (SkiaImage fromFile: '/opt/git/BenjaVisionPro/gt-runtime-workspace/CatalystFoundation/media/silverTexture.png') asForm
]

{ #category : 'converting' }
CFMaFormRootElement >> asScrollableElement [
	"CFMaFormRootElement is the Phlow-facing async form host returned by CFMaViewModel.
	Phlow wraps ordinary elements in a BlScrollableElement before installing them in an explicit view.
	Foundation forms own their internal body scroller and must fill the available view area, so the host must opt out of that wrapping."
	^ self
]

{ #category : 'initialization' }
CFMaFormRootElement >> initialize [
	"CFMaFormRootElement is the Phlow-facing async form host returned by CFMaViewModel.
	It must provide a full-area container for the generated Foundation form."
	super initialize.

	self
		background: (BlImagePatternPaint form: self class testingBackgroundForm);
		hMatchParent;
		vMatchParent
]

{ #category : 'configuration' }
CFMaFormRootElement >> beEmbedded [
	self
		hMatchParent;
		vFitContent
]
