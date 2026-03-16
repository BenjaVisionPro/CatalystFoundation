Class {
	#name : 'CFFontAwesomeDefaultStyleChangedAnnouncement',
	#superclass : 'Announcement',
	#instVars : [
		'iconLibraryClass',
		'styleName'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'instance creation' }
CFFontAwesomeDefaultStyleChangedAnnouncement class >> iconLibraryClass: anIconLibraryClass styleName: aStyleName [
	^ self new
		iconLibraryClass: anIconLibraryClass;
		styleName: aStyleName;
		yourself
]

{ #category : 'accessing' }
CFFontAwesomeDefaultStyleChangedAnnouncement >> iconLibraryClass [
	^ iconLibraryClass
]

{ #category : 'accessing' }
CFFontAwesomeDefaultStyleChangedAnnouncement >> iconLibraryClass: anIconLibraryClass [
	iconLibraryClass := anIconLibraryClass
]

{ #category : 'accessing' }
CFFontAwesomeDefaultStyleChangedAnnouncement >> styleName [
	^ styleName
]

{ #category : 'accessing' }
CFFontAwesomeDefaultStyleChangedAnnouncement >> styleName: aStyleName [
	styleName := aStyleName
]
