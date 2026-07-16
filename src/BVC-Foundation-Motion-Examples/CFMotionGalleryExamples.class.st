Class {
	#name : 'CFMotionGalleryExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Examples',
	#package : 'BVC-Foundation-Motion-Examples'
}

{ #category : 'examples - gallery' }
CFMotionGalleryExamples >> liveGallery [
	<gtExample>
	^ self gallery
]

{ #category : 'gallery' }
CFMotionGalleryExamples >> cardAt: aPoint title: aTitle subtitle: aSubtitle color: aColor action: anActionBlock [
	| card visual active |
	active := false.
	card := BlElement new
		size: 210 @ 180;
		relocate: aPoint;
		background: (aColor alpha: 0.12);
		clipChildren: true;
		yourself.
	card addChild: (self label: aTitle at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: aSubtitle at: 12 @ 36 size: 11 color: Color gray).
	card addChild: (self label: 'Click to replay' at: 12 @ 158 size: 10 color: Color gray).
	visual := BlElement new
		size: 56 @ 56;
		relocate: 77 @ 82;
		background: aColor;
		yourself.
	card addChild: visual.
	card when: BlClickEvent do: [ :anEvent |
		active := active not.
		anActionBlock value: visual value: active ].
	^ card
]

{ #category : 'gallery' }
CFMotionGalleryExamples >> gallery [
	| gallery |
	gallery := BlElement new
		size: 700 @ 470;
		background: Color white;
		yourself.
	gallery addChild: (self label: 'Motion gallery' at: 20 @ 14 size: 24 color: Color black).
	gallery addChild: (self label: 'Each tile is a live Motion example. Click it repeatedly to retarget or reverse the presentation.' at: 20 @ 42 size: 12 color: Color gray).
	gallery
		addChild: (self
				cardAt: 20 @ 76
				title: 'Opacity'
				subtitle: 'A property track fades the tile.'
				color: Color blue
				action: [ :element :active |
					element motion
						duration: 600 milliSeconds;
						opacity: (active ifTrue: [ 0.18 ] ifFalse: [ 1.0 ]) ]).
	gallery
		addChild: (self
				cardAt: 245 @ 76
				title: 'Transform composition'
				subtitle: 'Scale and translation share a channel.'
				color: Color green
				action: [ :element :active |
					element motion
						duration: 600 milliSeconds;
						scale: (active ifTrue: [ 0.62 @ 0.62 ] ifFalse: [ 1 @ 1 ]);
						translation: (active ifTrue: [ 28 @ -12 ] ifFalse: [ 0 @ 0 ]) ]).
	gallery
		addChild: (self
				cardAt: 470 @ 76
				title: 'Rotation'
				subtitle: 'Rotation is another transform property.'
				color: Color orange
				action: [ :element :active |
					element motion
						duration: 600 milliSeconds;
						rotation: (active ifTrue: [ 45 ] ifFalse: [ 0 ]) ]).
	gallery
		addChild: (self
				cardAt: 20 @ 272
				title: 'Rise and fade'
				subtitle: 'An effect owns opacity and translation.'
				color: Color purple
				action: [ :element :active |
					active
						ifTrue: [ CFMotionEffects fallAndFadeOut: element distance: 28 duration: 600 milliSeconds easing: (BlDecelerateInterpolator factor: 1.4) ]
						ifFalse: [ CFMotionEffects riseAndFadeIn: element distance: 28 duration: 600 milliSeconds easing: (BlDecelerateInterpolator factor: 1.4) ] ]).
	gallery
		addChild: (self
				cardAt: 245 @ 272
				title: 'Scale and fade'
				subtitle: 'One operation coordinates two tracks.'
				color: Color red
				action: [ :element :active |
					active
						ifTrue: [ CFMotionEffects scaleAndFadeOut: element to: 0.55 @ 0.55 duration: 600 milliSeconds easing: (BlDecelerateInterpolator factor: 1.4) ]
						ifFalse: [ CFMotionEffects scaleAndFadeIn: element from: 0.55 @ 0.55 duration: 600 milliSeconds easing: (BlDecelerateInterpolator factor: 1.4) ] ]).
	gallery
		addChild: (self
				cardAt: 470 @ 272
				title: 'Layout transaction'
				subtitle: 'Authoritative geometry changes; Motion presents it.'
				color: Color brown
				action: [ :element :active | | transaction destination |
					destination := active ifTrue: [ 130 @ 82 ] ifFalse: [ 24 @ 82 ].
					transaction := (element parent motion
						duration: 600 milliSeconds;
						layout).
					transaction
						affecting: { element };
						mutate: [ element relocate: destination ];
						play ]).
	^ gallery
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
