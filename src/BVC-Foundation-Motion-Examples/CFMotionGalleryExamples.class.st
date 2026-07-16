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

{ #category : 'examples - gallery' }
CFMotionGalleryExamples >> advancedGallery [
	<gtExample>
	^ self advancedGalleryElement
]

{ #category : 'gallery' }
CFMotionGalleryExamples >> advancedGalleryElement [
	| gallery adoptionCard source destination preview committed |
	gallery := BlElement new
		size: 700 @ 600;
		background: Color white;
		yourself.
	gallery addChild: (self label: 'Advanced Motion gallery' at: 20 @ 14 size: 24 color: Color black).
	gallery addChild: (self label: 'The following panels demonstrate Motion features whose visual result depends on several elements.' at: 20 @ 42 size: 12 color: Color gray).
	gallery addChild: (self crossFadeDemoAt: 20 @ 76).
	gallery addChild: (self verticalRevealDemoAt: 370 @ 76).
	gallery addChild: (self aptitudeDemoAt: 20 @ 294).

	"Adoption owns a preview-to-committed handoff. A new preview is created after the previous handoff completes."
	adoptionCard := BlElement new
		size: 330 @ 180;
		relocate: 370 @ 294;
		background: (Color purple alpha: 0.10);
		clipChildren: true;
		yourself.
	source := BlElement new
		size: 145 @ 120;
		relocate: 10 @ 50;
		background: (Color blue alpha: 0.10);
		clipChildren: true;
		yourself.
	destination := BlElement new
		size: 145 @ 120;
		relocate: 175 @ 50;
		background: (Color green alpha: 0.10);
		clipChildren: true;
		yourself.
	"The source and destination are displayed side by side inside one adoption card."
	adoptionCard addChild: (self label: 'Adoption' at: 12 @ 12 size: 16 color: Color black).
	adoptionCard addChild: (self label: 'Click source to hand the preview to the destination.' at: 12 @ 32 size: 11 color: Color gray).
	adoptionCard addChild: (self label: 'source' at: 12 @ 152 size: 10 color: Color blue).
	adoptionCard addChild: (self label: 'destination' at: 177 @ 152 size: 10 color: Color green).
	adoptionCard addChildren: { source. destination }.
	gallery addChild: adoptionCard.
	preview := BlElement new
		size: 80 @ 50;
		relocate: 32 @ 42;
		background: Color purple;
		yourself.
	source addChild: preview.
	source when: BlClickEvent do: [ :anEvent |
	preview hasParent ifFalse: [
			preview := BlElement new
				size: 80 @ 50;
				relocate: 32 @ 42;
				background: Color purple;
				yourself.
			source addChild: preview ].
	committed := BlElement new
			size: 80 @ 50;
			relocate: 32 @ 42;
			background: Color purple;
			yourself.
		destination motion
			duration: 700 milliSeconds;
			adopt: preview as: committed from: source ].
	^ gallery
]

{ #category : 'gallery' }
CFMotionGalleryExamples >> aptitudeDemoAt: aPoint [
	| card target aptitude |
	card := BlElement new
		size: 330 @ 180;
		relocate: aPoint;
		background: (Color orange alpha: 0.12);
		yourself.
	card addChild: (self label: 'Interaction aptitude' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'Press and release the tile.' at: 12 @ 36 size: 11 color: Color gray).
	target := BlElement new
		size: 110 @ 64;
		relocate: 110 @ 82;
		background: Color orange;
		yourself.
	aptitude := CFMotionAptitude new
		pressedEffect: CFMotionEffects compress;
		releasedEffect: CFMotionEffects springBack;
		yourself.
	target addAptitude: aptitude.
	card addChild: target.
	^ card
]

{ #category : 'gallery' }
CFMotionGalleryExamples >> crossFadeDemoAt: aPoint [
	| card outgoing incoming active |
	active := false.
	card := BlElement new
		size: 330 @ 180;
		relocate: aPoint;
		background: (Color red alpha: 0.10);
		yourself.
	card addChild: (self label: 'Cross-fade' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'One opacity operation coordinates two elements.' at: 12 @ 36 size: 11 color: Color gray).
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
		active := active not.
		active
			ifTrue: [ CFMotionEffects crossFadeFrom: outgoing to: incoming duration: 600 milliSeconds easing: (BlDecelerateInterpolator factor: 1.4) ]
			ifFalse: [ CFMotionEffects crossFadeFrom: incoming to: outgoing duration: 600 milliSeconds easing: (BlDecelerateInterpolator factor: 1.4) ] ].
	^ card
]

{ #category : 'gallery' }
CFMotionGalleryExamples >> verticalRevealDemoAt: aPoint [
	| card content active |
	active := false.
	card := BlElement new
		size: 330 @ 180;
		relocate: aPoint;
		background: (Color green alpha: 0.10);
		clipChildren: true;
		yourself.
	card addChild: (self label: 'Vertical reveal' at: 12 @ 12 size: 16 color: Color black).
	card addChild: (self label: 'Height changes without scaling the content.' at: 12 @ 36 size: 11 color: Color gray).
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
		content motion
			duration: 600 milliSeconds;
			verticalExtent: (active ifTrue: [ 38 ] ifFalse: [ 100 ]) ].
	^ card
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
