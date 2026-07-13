Class {
	#name : 'CFConfigurationRelationElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'memento',
		'description',
		'relationItemsElement'
	],
	#category : 'BVC-Foundation-Config-UI-ConfigurationEditor',
	#package : 'BVC-Foundation-Config-UI-ConfigurationEditor'
}

{ #category : 'accessing' }
CFConfigurationRelationElement >> description [ ^ description ]

{ #category : 'accessing' }
CFConfigurationRelationElement >> description: anObject [ description := anObject ]

{ #category : 'accessing' }
CFConfigurationRelationElement >> memento [ ^ memento ]

{ #category : 'accessing' }
CFConfigurationRelationElement >> memento: anObject [ memento := anObject ]

{ #category : 'accessing' }
CFConfigurationRelationElement >> relationItemsElement [ ^ relationItemsElement ]

{ #category : 'accessing' }
CFConfigurationRelationElement >> relationItemsElement: anObject [ relationItemsElement := anObject ]
