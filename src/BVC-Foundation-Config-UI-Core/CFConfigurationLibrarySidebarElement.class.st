Class {
	#name : 'CFConfigurationLibrarySidebarElement',
	#superclass : 'BrFrame',
	#instVars : [
		'assetActivatedBlock',
		'library',
		'listElement'
	],
	#category : 'BVC-Foundation-Config-UI-Core',
	#package : 'BVC-Foundation-Config-UI-Core'
}

{ #category : 'private - building' }
CFConfigurationLibrarySidebarElement >> addAssetInteractionsTo: anElement asset: anAsset [
	anElement addEventHandler: (BlDragHandler new
		liftItem: [ :aSourceElement |
			BlDragItem new
				sourceElement: aSourceElement;
				domainObject: anAsset;
				stencil: [ :aDragItem | self createAssetPresentationFor: aDragItem domainObject ];
				yourself ];
		yourself).
	anElement when: BlDoubleClickEvent do: [ :anEvent |
		assetActivatedBlock ifNotNil: [ :aBlock | aBlock value: anAsset ].
		anEvent consumed: true ]
]

{ #category : 'private - building' }
CFConfigurationLibrarySidebarElement >> createAssetPresentationFor: anAsset [
	| element |
	element := CFCompactObjectStencil new
		object: anAsset;
		create.
	element
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 8 left: 10 bottom: 8 right: 10);
		margin: (BlInsets bottom: 4);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 9);
		background: (Color black alpha: 0.24);
		border: (BlBorder paint: (Color white alpha: 0.14) width: 1).
	element titleElement aptitude: (BrGlamorousLabelAptitude new
		glamorousRegularFont;
		fontSize: 13;
		foreground: (Color white alpha: 0.9);
		yourself).
	self addAssetInteractionsTo: element asset: anAsset.
	^ element
]

{ #category : 'private - building' }
CFConfigurationLibrarySidebarElement >> createContent [
	| content heading |
	content := BrVerticalPane new
		hMatchParent;
		vMatchParent;
		padding: (BlInsets all: 12);
		yourself.
	heading := BrLabel new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 2 left: 2 bottom: 9 right: 2);
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFont;
			fontSize: 15;
			foreground: (Color white alpha: 0.92);
			yourself);
		text: 'Configuration library';
		yourself.
	listElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		yourself.
	content
		addChild: heading;
		addChild: listElement.
	self addChild: content
]

{ #category : 'initialization' }
CFConfigurationLibrarySidebarElement >> initialize [
	super initialize.
	self
		hExact: 300;
		vMatchParent;
		layout: BlFrameLayout new;
		padding: (BlInsets all: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 13);
		background: (Color black alpha: 0.46);
		border: (BlBorder paint: (Color white alpha: 0.18) width: 1);
		effect: (BlBlurBelowEffect radius: 14).
	self createContent
]

{ #category : 'accessing' }
CFConfigurationLibrarySidebarElement >> library [
	^ library
]

{ #category : 'accessing' }
CFConfigurationLibrarySidebarElement >> library: aConfigurationLibrary [
	library := aConfigurationLibrary.
	self refresh
]

{ #category : 'updating' }
CFConfigurationLibrarySidebarElement >> refresh [
	listElement ifNil: [ ^ self ].
	listElement removeChildren.
	library ifNil: [ ^ self ].
	library assets do: [ :each |
		listElement addChild: (self createAssetPresentationFor: each) ]
]

{ #category : 'events' }
CFConfigurationLibrarySidebarElement >> whenAssetActivatedDo: aBlock [
	assetActivatedBlock := aBlock
]
