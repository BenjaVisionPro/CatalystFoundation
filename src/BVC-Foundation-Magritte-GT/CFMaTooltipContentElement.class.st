Class {
	#name : #CFMaTooltipContentElement,
	#superclass : #BrEditor,
	#category : #'BVC-Foundation-Magritte-GT-Tooltip'
}

{ #category : #initialization }
CFMaTooltipContentElement >> initialize [
	super initialize.
	self
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithoutSelection;
		hFitContentLimited;
		vFitContent;
		constraintsDo: [ :c | c maxWidth: 250 ];
		padding: (BlInsets top: 4 left: 8 bottom: 4 right: 8);
		background: Color transparent;
		border: BlBorder empty;
		focusability: BlFocusability none;
		preventMouseEvents;
		addAptitude: CFMaTooltipSurfaceAptitude new;
		addAptitude: (BrLazyStyleCommonAptitude new
			default: [ :aStyle |
				aStyle do: [
					self geometry: (BlRoundedRectangleGeometry cornerRadius: self theme tooltip cornerRadius) ] ])
]

{ #category : #'editor - accessing' }
CFMaTooltipContentElement >> text: aBlText [
	super text: (aBlText asRopedText
		foreground: self theme tooltip foreground;
		fontSize: self theme tooltip fontSize)
]
