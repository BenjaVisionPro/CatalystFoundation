Class {
	#name : #CFMaTooltipSurfaceAptitude,
	#superclass : #CFGlassSurfaceAptitude,
	#category : #'BVC-Foundation-Magritte-GT-Tooltip'
}

{ #category : #accessing }
CFMaTooltipSurfaceAptitude >> borderColor [
	^ self theme tooltip borderColor blocResolveColorForTheme: self theme
]
