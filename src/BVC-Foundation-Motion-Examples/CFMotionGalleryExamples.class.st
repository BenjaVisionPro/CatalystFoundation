Class {
	#name : 'CFMotionGalleryExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Examples',
	#package : 'BVC-Foundation-Motion-Examples'
}

{ #category : 'examples - gallery' }
CFMotionGalleryExamples >> crossFade [
	<gtExample>
	| card outgoing incoming active currentMotion |
	active := false.
	card := BlElement new
		size: 330 @ 180;
		background: (Color red alpha: 0.10);
		yourself.
	card addChild: (self label: 'Cross-fade' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'One Motion coordinates two elements.' at: 12 @ 36 size: 11 color: Color gray).
	card addChild: (self label: 'Click to replay' at: 12 @ 158 size: 10 color: Color gray).
	outgoing := BlElement new
		size: 80 @ 80;
		relocate: 125 @ 72;
		background: Color blue;
		yourself.
	incoming := BlElement new
		size: 80 @ 80;
		relocate: 125 @ 72;
		background: Color red;
		opacity: 0.0;
		yourself.
	card addChildren: { outgoing. incoming }.
	card when: BlClickEvent do: [ :anEvent |
		| departing arriving |
		active := active not.
		currentMotion ifNotNil: [ currentMotion cancel ].
		departing := active ifTrue: [ outgoing ] ifFalse: [ incoming ].
		arriving := active ifTrue: [ incoming ] ifFalse: [ outgoing ].
		currentMotion := ((CFMotion
			coordinator: card space cfMotionCoordinator
			tracks: {
				CFMotionPropertyTrack on: departing property: CFMotionOpacityProperty uniqueInstance target: 0.0.
				CFMotionPropertyTrack on: arriving property: CFMotionOpacityProperty uniqueInstance target: 1.0 })
			duration: 600 milliSeconds;
			easing: (BlDecelerateInterpolator factor: 1.4);
			start) ].
	^ card
]

{ #category : 'examples - public gallery' }
CFMotionGalleryExamples >> fadeIn [
	<gtExample>
	| space card tile |
	space := BlSpace new.
	card := BlElement new
		size: 330 @ 180;
		background: (Color blue alpha: 0.12);
		clipChildren: true;
		yourself.
	card addChild: (self label: 'Fade in' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'One public request starts the Motion.' at: 12 @ 36 size: 11 color: Color gray).
	tile := BlElement new
		size: 56 @ 56;
		relocate: 137 @ 82;
		background: Color blue;
		opacity: 0.0;
		yourself.
	card addChild: tile.
	space root addChild: card.
	space pulse.
	tile motion fadeIn.
	^ card
]

{ #category : 'examples - public gallery' }
CFMotionGalleryExamples >> fadeInWithDuration [
	<gtExample>
	| space card tile |
	space := BlSpace new.
	card := BlElement new
		size: 330 @ 180;
		background: (Color purple alpha: 0.12);
		clipChildren: true;
		yourself.
	card addChild: (self label: 'Fade in with configuration' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'The block configures before the Motion starts.' at: 12 @ 36 size: 11 color: Color gray).
	tile := BlElement new
		size: 56 @ 56;
		relocate: 137 @ 82;
		background: Color purple;
		opacity: 0.0;
		yourself.
	card addChild: tile.
	space root addChild: card.
	space pulse.
	tile motion fadeIn: [ :builder | builder duration: 600 milliSeconds ].
	^ card
]

{ #category : 'examples - public gallery' }
CFMotionGalleryExamples >> fadeOut [
	<gtExample>
	| space card tile |
	space := BlSpace new.
	card := BlElement new
		size: 330 @ 180;
		background: (Color red alpha: 0.12);
		clipChildren: true;
		yourself.
	card addChild: (self label: 'Fade out' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'One public request starts the Motion.' at: 12 @ 36 size: 11 color: Color gray).
	tile := BlElement new
		size: 56 @ 56;
		relocate: 137 @ 82;
		background: Color red;
		yourself.
	card addChild: tile.
	space root addChild: card.
	space pulse.
	tile motion fadeOut.
	^ card
]

{ #category : 'examples - public gallery' }
CFMotionGalleryExamples >> fallAndFadeOut [
	<gtExample>
	| space card tile |
	space := BlSpace new.
	card := BlElement new
		size: 330 @ 180;
		background: (Color orange alpha: 0.12);
		clipChildren: true;
		yourself.
	card addChild: (self label: 'Fall and fade out' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'One public request coordinates two tracks.' at: 12 @ 36 size: 11 color: Color gray).
	tile := BlElement new
		size: 56 @ 56;
		relocate: 137 @ 82;
		background: Color orange;
		yourself.
	card addChild: tile.
	space root addChild: card.
	space pulse.
	tile motion fallAndFadeOut.
	^ card
]

{ #category : 'examples - gallery' }
CFMotionGalleryExamples >> interactionAptitude [
	<gtExample>
	| card target aptitude |
	card := BlElement new
		size: 330 @ 180;
		background: (Color orange alpha: 0.12);
		yourself.
	card addChild: (self label: 'Interaction aptitude' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'Press and release the tile.' at: 12 @ 36 size: 11 color: Color gray).
	target := BlElement new
		size: 110 @ 64;
		relocate: 110 @ 82;
		background: Color orange;
		yourself.
	aptitude := CFMotionButtonAptitude new.
	target addAptitude: aptitude.
	card addChild: target.
	^ card
]

{ #category : 'examples - gallery' }
CFMotionGalleryExamples >> relocate [
	<gtExample>
	^ self
		toggleCardTitled: 'Relocate'
		subtitle: 'Move to an authoritative layout position.'
		color: Color brown
		action: [ :element :active |
			element motion
				duration: 600 milliSeconds;
				relocate: (active ifTrue: [ 230 @ 82 ] ifFalse: [ 24 @ 82 ]) ]
]

{ #category : 'gallery' }
CFMotionGalleryExamples >> label: aString at: aPoint size: aNumber color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			fontSize: aNumber;
			foreground: aColor);
		text: aString;
		relocate: aPoint;
		yourself
]

{ #category : 'examples - gallery' }
CFMotionGalleryExamples >> opacity [
	<gtExample>
	^ self
		toggleCardTitled: 'Opacity'
		subtitle: 'A property track fades the tile.'
		color: Color blue
		action: [ :element :active :currentMotion |
			currentMotion
				ifNil: [
					(element motion
						duration: 600 milliSeconds;
						holdAtDestination;
						opacity: (active ifTrue: [ 0.18 ] ifFalse: [ 1.0 ]);
						build)
						start ]
				ifNotNil: [
					currentMotion
						retarget: (CFMotionPropertyTrack
							on: element
							property: CFMotionOpacityProperty uniqueInstance
							target: (active ifTrue: [ 0.18 ] ifFalse: [ 1.0 ]))
						duration: 600 milliSeconds
						easing: (BlDecelerateInterpolator factor: 1.4) ] ]
]

{ #category : 'examples - gallery' }
CFMotionGalleryExamples >> riseAndFade [
	<gtExample>
	^ self
		toggleCardTitled: 'Rise and fade'
		subtitle: 'One Motion coordinates opacity and translation.'
		color: Color purple
		action: [ :element :active :currentMotion |
			currentMotion
				ifNil: [
					((active
						ifTrue: [ CFMotionBuilder fallAndFadeOut ]
						ifFalse: [ CFMotionBuilder riseAndFadeIn ])
						element: element;
						duration: 600 milliSeconds;
						holdAtDestination;
						build)
						start ]
				ifNotNil: [
					currentMotion
						retarget: {
							CFMotionPropertyTrack
								on: element
								property: CFMotionOpacityProperty uniqueInstance
								target: (active ifTrue: [ 0.0 ] ifFalse: [ 1.0 ]).
							CFMotionTranslationTrack
								on: element
								from: 0 @ 0
								to: (active ifTrue: [ 0 @ 12 ] ifFalse: [ 0 @ 0 ]) }
						duration: 600 milliSeconds
						easing: (BlDecelerateInterpolator factor: 1.4) ] ]
]

{ #category : 'examples - public gallery' }
CFMotionGalleryExamples >> riseAndFadeIn [
	<gtExample>
	| space card tile |
	space := BlSpace new.
	card := BlElement new
		size: 330 @ 180;
		background: (Color green alpha: 0.12);
		clipChildren: true;
		yourself.
	card addChild: (self label: 'Rise and fade in' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'One public request coordinates two tracks.' at: 12 @ 36 size: 11 color: Color gray).
	tile := BlElement new
		size: 56 @ 56;
		relocate: 137 @ 82;
		background: Color green;
		opacity: 0.0;
		yourself.
	card addChild: tile.
	space root addChild: card.
	space pulse.
	tile motion riseAndFadeIn.
	^ card
]

{ #category : 'examples - gallery' }
CFMotionGalleryExamples >> rotation [
	<gtExample>
	^ self
		toggleCardTitled: 'Rotation'
		subtitle: 'Rotation is another transform property.'
		color: Color orange
		action: [ :element :active :currentMotion |
			currentMotion
				ifNil: [
					(element motion
						duration: 600 milliSeconds;
						holdAtDestination;
						rotation: (active ifTrue: [ 45 ] ifFalse: [ 0 ]);
						build)
						start ]
				ifNotNil: [
					currentMotion
						retarget: (CFMotionRotationTrack
							on: element
							from: 0
							to: (active ifTrue: [ 45 ] ifFalse: [ 0 ]))
						duration: 600 milliSeconds
						easing: (BlDecelerateInterpolator factor: 1.4) ] ]
]

{ #category : 'examples - gallery' }
CFMotionGalleryExamples >> scaleAndFade [
	<gtExample>
	^ self
		toggleCardTitled: 'Scale and fade'
		subtitle: 'One Motion coordinates two tracks.'
		color: Color red
		action: [ :element :active :currentMotion |
			currentMotion
				ifNil: [
					((active
						ifTrue: [ CFMotionBuilder scaleAndFadeOut ]
						ifFalse: [ CFMotionBuilder scaleAndFadeIn ])
						element: element;
						duration: 600 milliSeconds;
						holdAtDestination;
						build)
						start ]
				ifNotNil: [
					currentMotion
						retarget: {
							CFMotionPropertyTrack
								on: element
								property: CFMotionOpacityProperty uniqueInstance
								target: (active ifTrue: [ 0.0 ] ifFalse: [ 1.0 ]).
							CFMotionScaleTrack
								on: element
								from: 1 @ 1
								to: (active ifTrue: [ 0.8 @ 0.8 ] ifFalse: [ 1 @ 1 ]) }
						duration: 600 milliSeconds
						easing: (BlDecelerateInterpolator factor: 1.4) ] ]
]

{ #category : 'examples - public gallery' }
CFMotionGalleryExamples >> scaleAndFadeIn [
	<gtExample>
	| space card tile |
	space := BlSpace new.
	card := BlElement new
		size: 330 @ 180;
		background: (Color purple alpha: 0.12);
		clipChildren: true;
		yourself.
	card addChild: (self label: 'Scale and fade in' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'One public request coordinates two tracks.' at: 12 @ 36 size: 11 color: Color gray).
	tile := BlElement new
		size: 56 @ 56;
		relocate: 137 @ 82;
		background: Color purple;
		opacity: 0.0;
		yourself.
	card addChild: tile.
	space root addChild: card.
	space pulse.
	tile motion scaleAndFadeIn.
	^ card
]

{ #category : 'examples - public gallery' }
CFMotionGalleryExamples >> scaleAndFadeOut [
	<gtExample>
	| space card tile |
	space := BlSpace new.
	card := BlElement new
		size: 330 @ 180;
		background: (Color red alpha: 0.12);
		clipChildren: true;
		yourself.
	card addChild: (self label: 'Scale and fade out' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'One public request coordinates two tracks.' at: 12 @ 36 size: 11 color: Color gray).
	tile := BlElement new
		size: 56 @ 56;
		relocate: 137 @ 82;
		background: Color red;
		yourself.
	card addChild: tile.
	space root addChild: card.
	space pulse.
	tile motion scaleAndFadeOut.
	^ card
]

{ #category : 'gallery' }
CFMotionGalleryExamples >> toggleCardTitled: aTitle subtitle: aSubtitle color: aColor action: anActionBlock [
	| card visual active currentMotion |
	active := false.
	card := BlElement new
		size: 330 @ 180;
		background: (aColor alpha: 0.12);
		clipChildren: true;
		yourself.
	card addChild: (self label: aTitle at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: aSubtitle at: 12 @ 36 size: 11 color: Color gray).
	card addChild: (self label: 'Click to replay' at: 12 @ 158 size: 10 color: Color gray).
	visual := BlElement new
		size: 56 @ 56;
		relocate: 137 @ 82;
		background: aColor;
		yourself.
	card addChild: visual.
	card when: BlClickEvent do: [ :anEvent |
		active := active not.
		currentMotion := anActionBlock
			cull: visual
			cull: active
			cull: currentMotion ].
	^ card
]

{ #category : 'examples - gallery' }
CFMotionGalleryExamples >> transformComposition [
	<gtExample>
	^ self
		toggleCardTitled: 'Transform composition'
		subtitle: 'Scale and translation share a channel.'
		color: Color green
		action: [ :element :active :currentMotion |
			currentMotion
				ifNil: [
					(element motion
						duration: 600 milliSeconds;
						holdAtDestination;
						scale: (active ifTrue: [ 0.62 @ 0.62 ] ifFalse: [ 1 @ 1 ]);
						translation: (active ifTrue: [ 28 @ -12 ] ifFalse: [ 0 @ 0 ]);
						build)
						start ]
				ifNotNil: [
					currentMotion
						retarget: {
							CFMotionScaleTrack
								on: element
								from: 1 @ 1
								to: (active ifTrue: [ 0.62 @ 0.62 ] ifFalse: [ 1 @ 1 ]).
							CFMotionTranslationTrack
								on: element
								from: 0 @ 0
								to: (active ifTrue: [ 28 @ -12 ] ifFalse: [ 0 @ 0 ]) }
						duration: 600 milliSeconds
						easing: (BlDecelerateInterpolator factor: 1.4) ] ]
]

{ #category : 'examples - gallery' }
CFMotionGalleryExamples >> verticalReveal [
	<gtExample>
	| card content active currentMotion |
	active := false.
	card := BlElement new
		size: 330 @ 180;
		background: (Color green alpha: 0.10);
		clipChildren: true;
		yourself.
	card addChild: (self label: 'Vertical reveal' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'Height changes without scaling the content.' at: 12 @ 36 size: 11 color: Color gray).
	card addChild: (self label: 'Click to replay' at: 12 @ 158 size: 10 color: Color gray).
	content := BlElement new
		size: 220 @ 100;
		relocate: 55 @ 66;
		background: Color green;
		clipChildren: true;
		yourself.
	content addChild: (self label: 'Natural-width content' at: 16 @ 16 size: 14 color: Color white).
	content addChild: (self label: 'The child layout remains unscaled.' at: 16 @ 42 size: 11 color: Color white).
	card addChild: content.
	card when: BlClickEvent do: [ :anEvent |
		active := active not.
		currentMotion ifNotNil: [ currentMotion cancel ].
		currentMotion := ((content motion
			duration: 600 milliSeconds;
			verticalExtent: (active ifTrue: [ 38 ] ifFalse: [ 100 ]);
			build)
			start) ].
	^ card
]
