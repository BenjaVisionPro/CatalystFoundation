Extension { #name : 'CFMaFormShowcase' }

{ #category : '*bvc-foundation-magritte-detail-examples' }
CFMaFormShowcase >> exampleDetailElement [
	<gtExample>
	| aDescription aMemento |
	aDescription := self magritteDescription.
	aDescription blocPresentationStencil: [ :theMemento |
		CFMaDetailPresentation new ].
	aMemento := CFMaMemento model: self description: aDescription.
	^ (CFMaViewModel forObject: self memento: aMemento) asElement
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
		add: (self durationDescription copy
			label: 'Direct duration';
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
		add: (self classValueDescription copy
			label: 'Class';
			group: 'General';
			categories: #('Appearance');
			priority: 60;
			yourself);
		add: (self dateDescription copy
			label: 'Date';
			group: 'General';
			categories: #('Appearance' 'Display');
			priority: 70;
			yourself);
		add: (self timeDescription copy
			label: 'Time';
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
		add: (self classValueDescription copy
			label: 'First class';
			group: 'Tabs';
			categories: #('First');
			priority: 120;
			yourself);
		add: (self dateDescription copy
			label: 'Second date';
			group: 'Tabs';
			categories: #('Second');
			priority: 130;
			yourself);
		add: (self timeDescription copy
			label: 'Second time';
			group: 'Tabs';
			categories: #('Second');
			priority: 140;
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
			yourself ].
	aMemento := CFMaMemento model: self description: aDescription.
	^ (CFMaViewModel forObject: self memento: aMemento) asElement
]
