Class {
	#name : #CFMaButtonWithLabelTooltipAptitude,
	#superclass : #BrGlamorousButtonWithLabelTooltipAptitude2,
	#category : #'BVC-Foundation-Magritte-GT-Tooltip'
}

{ #category : #initialization }
CFMaButtonWithLabelTooltipAptitude >> initialize [
	| aNativeContainerAptitude |
	super initialize.

	self handle: [ BlElement new
		size: BrMenuConstants handleExtent * 2.0;
		geometry: BlCircleGeometry new;
		background: Color transparent;
		addAptitude: BrPopoverCommonAptitude new ].

	self menuContainerDo: [ :aContainer |
		aNativeContainerAptitude := nil.
		aContainer aptitudeDo: [ :anAptitude |
			(anAptitude isKindOf: BrPopoverContainerAptitude) ifTrue: [
				aNativeContainerAptitude := anAptitude ] ].
		aNativeContainerAptitude ifNotNil: [
			aContainer removeAptitude: aNativeContainerAptitude ].
		aContainer addAptitude: CFMaTooltipContainerAptitude new ]
]
