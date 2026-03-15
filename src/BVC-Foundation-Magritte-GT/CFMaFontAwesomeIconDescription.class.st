Class {
	#name : 'CFMaFontAwesomeIconDescription',
	#superclass : 'GtMagritteIconDescription',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'icons' }
CFMaFontAwesomeIconDescription >> applySizingToIconElement: anElement [
	| width height |
	width := self explicitIconWidth.
	height := self explicitIconHeight.

	(width notNil and: [ height notNil ]) ifTrue: [
		^ anElement fitInto: width @ height ].
	width notNil ifTrue: [ ^ anElement width: width ].
	height notNil ifTrue: [ ^ anElement height: height ].
	^ anElement height: self defaultIconHeight
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> availableIconAssociations [
	^ self availableIcons 
		asSortedCollection: [ :a :b | a key asString < b key asString ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> availableIcons [
	^ self iconLibraryClass availableIconsForStyleNamed: self styleName
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> blocStencil [
	^ self propertyAt: #blocStencil ifAbsent: [ CFMaFontAwesomeIconStencilBuilder new ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> chooseIconLabel [
	^ self propertyAt: #chooseIconLabel ifAbsent: [ 'Choose icon' ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> chooseIconLabel: aString [
	self propertyAt: #chooseIconLabel put: aString
]

{ #category : 'accessing-defaults' }
CFMaFontAwesomeIconDescription >> defaultIconHeight [
	^ 16
]

{ #category : 'accessing-defaults' }
CFMaFontAwesomeIconDescription >> defaultSelectorExtent [
	^ 420 @ 320
]

{ #category : 'icons' }
CFMaFontAwesomeIconDescription >> displayExtentForIntrinsicExtent: anExtent [
	| width height xScale yScale scale |
	width := self explicitIconWidth.
	height := self explicitIconHeight.

	(width notNil and: [ height notNil ]) ifTrue: [
		((anExtent x isZero) or: [ anExtent y isZero ]) ifTrue: [ ^ width @ height ].
		xScale := width asFloat / anExtent x asFloat.
		yScale := height asFloat / anExtent y asFloat.
		scale := xScale min: yScale.
		^ (anExtent x asFloat * scale) @ (anExtent y asFloat * scale) ].
	width notNil ifTrue: [
		(anExtent x isZero) ifTrue: [ ^ anExtent ].
		^ width @ (anExtent y asFloat * (width asFloat / anExtent x asFloat)) ].
	height notNil ifTrue: [
		(anExtent y isZero) ifTrue: [ ^ anExtent ].
		^ (anExtent x asFloat * (height asFloat / anExtent y asFloat)) @ height ].
	(anExtent y isZero) ifTrue: [ ^ anExtent ].
	^ (anExtent x asFloat * (self defaultIconHeight asFloat / anExtent y asFloat)) @ self defaultIconHeight
]

{ #category : 'private' }
CFMaFontAwesomeIconDescription >> explicitIconHeight [
	^ self propertyAt: #iconHeight ifAbsent: [ nil ]
]

{ #category : 'private' }
CFMaFontAwesomeIconDescription >> explicitIconWidth [
	^ self propertyAt: #iconWidth ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconHeight [
	| explicitHeight |
	explicitHeight := self explicitIconHeight.
	explicitHeight ifNotNil: [ ^ explicitHeight ].
	self explicitIconWidth ifNotNil: [ ^ nil ].
	^ self defaultIconHeight
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconHeight: aNumber [
	self propertyAt: #iconHeight put: aNumber
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconLibraryClass [
	^ self propertyAt: #iconLibraryClass ifAbsent: [ CFFontAwesomeIcons ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconLibraryClass: aClass [
	self propertyAt: #iconLibraryClass put: aClass
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconSize [
	| width height |
	width := self explicitIconWidth.
	height := self explicitIconHeight.
	(width notNil and: [ height notNil ]) ifTrue: [ ^ width @ height ].
	width notNil ifTrue: [ ^ width ].
	height notNil ifTrue: [ ^ height ].
	^ self defaultIconHeight
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconSize: anObject [
	anObject isPoint
		ifTrue: [
			self iconWidth: anObject x.
			self iconHeight: anObject y ]
		ifFalse: [
			self iconWidth: nil.
			self iconHeight: anObject ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconWidth [
	^ self propertyAt: #iconWidth ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconWidth: aNumber [
	self propertyAt: #iconWidth put: aNumber
]

{ #category : 'testing' }
CFMaFontAwesomeIconDescription >> isFontAwesomeIconDescription [
	^ true
]

{ #category : 'icons' }
CFMaFontAwesomeIconDescription >> scaledElementForIcon: aFontAwesomeIcon [
	^ aFontAwesomeIcon
		asScalableElementSized: (self displayExtentForIntrinsicExtent: aFontAwesomeIcon intrinsicExtent)
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> selectorExtent [
	^ self propertyAt: #selectorExtent ifAbsent: [ self defaultSelectorExtent ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> selectorExtent: anExtent [
	self propertyAt: #selectorExtent put: anExtent
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> styleName [
	^ self propertyAt: #styleName ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> styleName: aStyleName [
	self propertyAt: #styleName put: aStyleName
]
