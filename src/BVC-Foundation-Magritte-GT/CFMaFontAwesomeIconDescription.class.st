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
CFMaFontAwesomeIconDescription >> defaultIconSize [
	^ 16 @ 16
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
CFMaFontAwesomeIconDescription >> iconSize [
	^ self propertyAt: #iconSize ifAbsent: [ self defaultIconSize ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconDescription >> iconSize: anExtent [
	self propertyAt: #iconSize put: anExtent
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
