Extension { #name : 'Object' }

{ #category : '*BVC-Foundation-Magritte-GT' }
Object >> compactListItemComment [
	^ nil
]

{ #category : '*BVC-Foundation-Magritte-GT' }
Object >> compactListItemDescription [
	| aContainer |
	aContainer := MAContainer new.
	aContainer
		add: (MAStringDescription new
			accessor: #compactListItemIcon;
			label: 'Icon';
			beReadOnly;
			propertyAt: #cfCompactListItemRole put: #icon;
			yourself);
		add: (MAStringDescription new
			accessor: #compactListItemTitle;
			label: 'Title';
			beReadOnly;
			propertyAt: #cfCompactListItemRole put: #title;
			yourself);
		add: (MAStringDescription new
			accessor: #compactListItemComment;
			label: 'Comment';
			beReadOnly;
			propertyAt: #cfCompactListItemRole put: #comment;
			yourself).
	^ aContainer
]

{ #category : '*BVC-Foundation-Magritte-GT' }
Object >> compactListItemIcon [
	^ #inspect
]

{ #category : '*BVC-Foundation-Magritte-GT' }
Object >> compactListItemTitle [
	^ self displayString
]
