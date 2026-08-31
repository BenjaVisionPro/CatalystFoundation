Class {
	#name : #CFMenuShadowAptitude,
	#superclass : #BrShadowAptitude,
	#category : #'BVC-Foundation-Magritte-GT'
}

{ #category : #initialization }
CFMenuShadowAptitude >> initialize [
	super initialize.

	self
		color: (self theme menu shadowColor
			blocResolveColorForTheme: self theme);
		width: self theme menu shadowWidth;
		offset: self theme menu shadowOffset
]
