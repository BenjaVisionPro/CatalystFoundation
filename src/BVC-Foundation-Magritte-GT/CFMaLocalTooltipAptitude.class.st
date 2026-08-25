Class {
	#name : 'CFMaLocalTooltipAptitude',
	#superclass : 'BrGlamorousWithExplicitTooltipAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : #'api - displaying' }
CFMaLocalTooltipAptitude >> showDueTo: anEventOrNil [
	"Test variant: keep the tooltip in the anchor's local parent instead of hoisting it to topMostParent."

	self canShow ifFalse: [ ^ self ].

	self widgetDo: [ :aWidget |
		| aParent |
		aWidget dispatchEvent: BrTooltipHideWish new.
		aParent := aWidget parent.
		aParent ifNotNil: [
			self showIn: aParent dueToEvent: anEventOrNil ] ]
]

{ #category : #private }
CFMaLocalTooltipAptitude >> temporarilyShow [
	"Keep reappearing tooltips in the same local-parent strategy used by showDueTo:."

	self widgetDo: [ :aWidget |
		| aParent |
		aParent := aWidget parent.
		aParent ifNotNil: [
			self
				temporarilyShowIn: aParent
				dueToReason: BrPopoverRelocateReason reappear ] ]
]
