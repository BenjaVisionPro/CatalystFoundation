Class {
	#name : 'CFMaFormRootElement',
	#superclass : 'BrFrame',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}


{ #category : 'initialization' }
CFMaFormRootElement >> initialize [
	"CFMaFormRootElement is the Phlow-facing async form host returned by CFMaViewModel.
	It must provide a full-area container for the generated Foundation form."
	super initialize.

	self
		background: CFInterfaceLighting backgroundPaint;
		margin: BlInsets empty;
		padding: BlInsets empty;
		hMatchParent;
		vFitContent
]

{ #category : 'configuration' }
CFMaFormRootElement >> beEmbedded [
	self
		background: Color transparent;
		hMatchParent;
		vFitContent
]


{ #category : 'conversion' }
CFMaFormRootElement >> asScrollableElement [
	^ CFSmoothScrollableElement new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		addChild: self;
		yourself
]
