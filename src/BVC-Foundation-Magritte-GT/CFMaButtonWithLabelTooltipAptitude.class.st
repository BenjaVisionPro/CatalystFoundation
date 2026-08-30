Class {
	#name : #CFMaButtonWithLabelTooltipAptitude,
	#superclass : #BrGlamorousButtonWithLabelTooltipAptitude2,
	#category : #'BVC-Foundation-Magritte-GT-Tooltip'
}

{ #category : #initialization }
CFMaButtonWithLabelTooltipAptitude >> initialize [
	super initialize.

	self menuContainerDo: [ :aContainer |
		aContainer
			beInSeparateCompositionLayer;
			aptitude: CFMaTooltipContainerAptitude new;
			effect: BlNullEffect new ]
]

{ #category : #'api - menu' }
CFMaButtonWithLabelTooltipAptitude >> text: aLabelString shortcut: aShortcutString [
	self
		handle: [ BlElement new
			size: BrMenuConstants handleExtent * 2.0;
			geometry: BlCircleGeometry new;
			background: Color transparent;
			addAptitude: CFMaTooltipSurfaceAptitude new ]
		content: [
			CFMaTooltipShadowElement new
				addChild: (CFMaTooltipContentElement new
					text: aLabelString asRopedText;
					yourself);
				yourself ]
]
