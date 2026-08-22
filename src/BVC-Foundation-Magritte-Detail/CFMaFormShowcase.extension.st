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
CFMaFormShowcase >> exampleDetailGroupingElement [
	<gtExample>
	| aDescription aMemento |
	aDescription := MAContainer new
		add: (self textDescription copy
			label: 'Nil group';
			group: nil;
			categories: #();
			priority: 10;
			yourself);
		add: (self summaryDescription copy
			label: 'Direct field';
			group: 'General';
			categories: #();
			priority: 20;
			yourself);
		add: (self passwordDescription copy
			label: 'Appearance';
			group: 'General';
			categories: #(appearance);
			priority: 30;
			yourself);
		add: (self statusDescription copy
			label: 'Display';
			group: 'General';
			categories: #(appearance display);
			priority: 40;
			yourself);
		add: (self durationDescription copy
			label: 'Behaviour';
			group: 'General';
			categories: #(appearance behaviour);
			priority: 50;
			yourself);
		add: (self dateDescription copy
			label: 'Advanced';
			group: 'General';
			categories: #(advanced);
			priority: 60;
			yourself);
		add: (self timeDescription copy
			label: 'General shared';
			group: 'General';
			categories: #(shared);
			priority: 70;
			yourself);
		add: (self classValueDescription copy
			label: 'Secondary shared';
			group: 'Secondary';
			categories: #(shared);
			priority: 80;
			yourself);
		yourself.
	aDescription blocPresentationStencil: [ :theMemento |
		CFMaDetailPresentation new ].
	aMemento := CFMaMemento model: self description: aDescription.
	^ (CFMaViewModel forObject: self memento: aMemento) asElement
]
