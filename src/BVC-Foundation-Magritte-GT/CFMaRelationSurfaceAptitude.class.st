"
I am responsible for presenting a Foundation relation surface according to whether focus is within it.
"
Class {
	#name : 'CFMaRelationSurfaceAptitude',
	#superclass : 'BrStyleCommonAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaRelationSurfaceAptitude >> initialize [
	super initialize.

	self
		default: [ :aStyle |
			aStyle border: (BlBorder
				paint: (Color black alpha: 0.10)
				width: 2) ];
		focused: [ :aStyle |
			aStyle border: (BlBorder
				paint: (self theme highlight color blocResolveColorForTheme: self theme)
				width: 2) ]
]
