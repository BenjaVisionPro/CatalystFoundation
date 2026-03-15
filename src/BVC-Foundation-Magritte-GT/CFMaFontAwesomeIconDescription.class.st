Class {
	#name : 'CFMaFontAwesomeIconDescription',
	#superclass : 'GtMagritteIconDescription',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> availableIconAssociations [
	^ self availableIcons 
		asSortedCollection: [ :a :b | a key asString < b key asString ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> availableIcons [
	^ (self iconLibraryClass style: self styleName) availableIcons
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

{ #category : 'accessing-defaults' }
CFMaFontAwesomeIconDescription >> defaultStyleName [
	^ 'regular'
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
CFMaFontAwesomeIconDescription >> iconHeight [
	^ self propertyAt: #iconHeight ifAbsent: [ self defaultIconHeight ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconHeight: aNumber [
	self propertyAt: #iconHeight put: aNumber
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconWidth [
	^ self propertyAt: #iconWidth ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconWidth: aNumber [
	self propertyAt: #iconWidth put: aNumber
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconSize [
	| width height |
	width := self iconWidth.
	height := self iconHeight.
	(width notNil and: [ height notNil ]) ifTrue: [ ^ width @ height ].
	^ height
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

{ #category : 'testing' }
CFMaFontAwesomeIconDescription >> isFontAwesomeIconDescription [
	^ true
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
	^ self propertyAt: #styleName ifAbsent: [ self defaultStyleName ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> styleName: aStyleName [
	self propertyAt: #styleName put: aStyleName
]
