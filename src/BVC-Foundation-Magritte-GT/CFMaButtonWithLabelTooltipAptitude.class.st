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
			addAptitude: CFMaTooltipContainerAptitude new ]
]

{ #category : #'api - menu' }
CFMaButtonWithLabelTooltipAptitude >> text: aLabelString shortcut: aShortcutString [
	self
		handle: [ BlElement new
			size: BrMenuConstants handleExtent * 2.0;
			geometry: BlCircleGeometry new;
			background: Color transparent;
			addAptitude: BrPopoverCommonAptitude new ]
		content: [
			CFMaTooltipContentElement new
				text: aLabelString asRopedText;
				yourself ]
]
