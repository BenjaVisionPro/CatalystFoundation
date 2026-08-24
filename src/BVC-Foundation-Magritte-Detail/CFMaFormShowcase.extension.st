Extension { #name : 'CFMaFormShowcase' }

{ #category : '*bvc-foundation-magritte-detail-examples' }
CFMaFormShowcase >> exampleDetailElement [
	<gtExample>
	| aDescription aMemento |
	aDescription := self magritteDescription.
	aDescription blocPresentationStencil: [ :theMemento |
		CFMaDetailPresentation new
			group: 'Fields' configure: [ :fields |
				fields
					reserveAccessorySlots: 2;
					category: #text configure: [ :aCategory | aCategory reserveAccessorySlots: 2 ];
					category: #values configure: [ :aCategory | aCategory reserveAccessorySlots: 2 ];
					category: #resources configure: [ :aCategory | aCategory reserveAccessorySlots: 2 ];
					category: #temporal configure: [ :aCategory | aCategory reserveAccessorySlots: 2 ];
					category: #metadata configure: [ :aCategory | aCategory reserveAccessorySlots: 2 ];
					category: #presentation configure: [ :aCategory | aCategory reserveAccessorySlots: 2 ] ];
			yourself ].
	aMemento := CFMaMemento model: self description: aDescription.
	^ (CFMaViewModel forObject: self memento: aMemento) asElement asScrollableElement
]

{ #category : '*bvc-foundation-magritte-detail-examples' }
CFMaFormShowcase >> detailGroupsDescription [
	^ MAContainer new
		add: (self textDescription copy
			label: 'Nil text';
			group: nil;
			categories: #();
			priority: 10;
			yourself);
		add: (self passwordDescription copy
			label: 'Nil password';
			group: nil;
			categories: #();
			priority: 20;
			yourself);
		add: (self summaryDescription copy
			label: 'Direct field';
			group: 'General';
			categories: #();
			priority: 30;
			yourself);
		add: (self textDescription copy
			label: 'Direct text';
			group: 'General';
			categories: #();
			priority: 40;
			yourself);
		add: (self statusDescription copy
			label: 'Appearance';
			group: 'General';
			categories: #('Appearance');
			priority: 50;
			yourself);
		add: (self passwordDescription copy
			label: 'Appearance password';
			group: 'General';
			categories: #('Appearance');
			priority: 60;
			yourself);
		add: (self priorityDescription copy
			label: 'Display priority';
			group: 'General';
			categories: #('Appearance' 'Display');
			priority: 70;
			yourself);
		add: (self popupPriorityDescription copy
			label: 'Display popup';
			group: 'General';
			categories: #('Appearance' 'Display');
			priority: 80;
			yourself);
		add: (self textDescription copy
			label: 'Secondary';
			group: 'Secondary';
			categories: #();
			priority: 90;
			yourself);
		add: (self summaryDescription copy
			label: 'Direct tab field';
			group: 'Tabs';
			categories: #();
			priority: 100;
			yourself);
		add: (self statusDescription copy
			label: 'First status';
			group: 'Tabs';
			categories: #('First');
			priority: 110;
			yourself);
		add: (self passwordDescription copy
			label: 'First password';
			group: 'Tabs';
			categories: #('First');
			priority: 120;
			yourself);
		add: (self priorityDescription copy
			label: 'Second priority';
			group: 'Tabs';
			categories: #('Second');
			priority: 130;
			yourself);
		add: (self popupPriorityDescription copy
			label: 'Second popup';
			group: 'Tabs';
			categories: #('Second');
			priority: 140;
			yourself);
		add: (self statusDescription copy
			label: 'Point & Click';
			group: 'Button Bar';
			categories: #('Point & Click');
			priority: 150;
			yourself);
		add: (self priorityDescription copy
			label: 'Scroll & Zoom';
			group: 'Button Bar';
			categories: #('Scroll & Zoom');
			priority: 160;
			yourself);
		add: (self passwordDescription copy
			label: 'More Gestures';
			group: 'Button Bar';
			categories: #('More Gestures');
			priority: 170;
			yourself);
		add: (self textDescription copy
			label: 'Add';
			group: 'Icon Button Bar';
			categories: #('Add');
			priority: 180;
			yourself);
		add: (self textDescription copy
			label: 'Copy';
			group: 'Icon Button Bar';
			categories: #('Copy');
			priority: 190;
			yourself);
		add: (self textDescription copy
			label: 'Refresh';
			group: 'Icon Button Bar';
			categories: #('Refresh');
			priority: 200;
			yourself);
		add: (self textDescription copy
			label: 'Inspect';
			group: 'Icon Button Bar';
			categories: #('Inspect');
			priority: 210;
			yourself);
		yourself
]

{ #category : '*bvc-foundation-magritte-detail-examples' }
CFMaFormShowcase >> exampleDetailGroupsElement [
	<gtExample>
	| aDescription aMemento |
	aDescription := self detailGroupsDescription.
	aDescription blocPresentationStencil: [ :theMemento |
		CFMaDetailPresentation new
			group: 'Tabs' configure: [ :aGroup | aGroup beTabs ];
			group: 'Button Bar' configure: [ :aGroup | aGroup beButtonBar ];
			group: 'Icon Button Bar' configure: [ :aGroup |
				| aButtonBar |
				aButtonBar := aGroup beIconButtonBar.
				aButtonBar
					icon: (FontAwesomeIcons defaultStyle icon: #addressCard) for: 'Add';
					icon: (FontAwesomeIcons defaultStyle icon: #addressBook) for: 'Copy';
					icon: (FontAwesomeIcons defaultStyle icon: #file) for: 'Refresh';
					icon: (FontAwesomeIcons defaultStyle icon: #atom) for: 'Inspect' ];
			yourself ].
	aMemento := CFMaMemento model: self description: aDescription.
	^ (CFMaViewModel forObject: self memento: aMemento) asElement asScrollableElement
]
