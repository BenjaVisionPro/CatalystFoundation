Class {
	#name : 'CFMaDetailSliderAptitude',
	#superclass : 'BrLazyStyleCommonAptitude',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailSliderAptitude >> initialize [
	super initialize.
	self default: [ :aStyle |
		aStyle do: [ self updateAppearance ] ]
]

{ #category : 'private - styling' }
CFMaDetailSliderAptitude >> updateAppearance [
	self widgetDo: [ :aSlider |
		| aTheme |
		aTheme := aSlider theme.
		aSlider sliderTrack
			background: (aTheme controls sliderTrackTint blocResolveColorForTheme: aTheme).
		aSlider sliderFill
			background: (aTheme controls sliderActiveTrackTint blocResolveColorForTheme: aTheme).
		aSlider sliderThumb
			background: (aTheme controls sliderThumbBackground blocResolveColorForTheme: aTheme);
			border: (BlBorder
				paint: (aTheme controls sliderThumbBorderTint blocResolveColorForTheme: aTheme)
				width: 0.5).
		{ aSlider minimumTick. aSlider middleTick. aSlider maximumTick } do: [ :aTick |
			aTick background: (aTheme controls sliderTickTint blocResolveColorForTheme: aTheme) ].
		{ aSlider minimumLabel. aSlider currentLabel. aSlider maximumLabel } do: [ :aLabel |
			aLabel aptitude
				foreground: aTheme typography secondaryForeground;
				fontSize: aTheme typography supportingFontSize ] ]
]
