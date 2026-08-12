# Handover — replace the experimental light-border design

## Status

`CFLightBorderAptitude` and `CFLightBorderEffect` are an exploratory rendering
prototype. Do **not** treat their current public API, examples, or the form
stencil as a design to preserve.

The most recent attempt split a semantic “raised card with a raised border”
into two `CFLightBorderAptitude` instances. That is the wrong abstraction. It
exposed internal rendering passes to callers and produced the bug visible in
the current `lowered` example: sending `beLowered` and `beLoweredBorder` to
one instance merely overwrote the first configuration; two instances only
hide that mistake rather than fixing it.

The implementation should be reworked before it becomes a Foundation API.

## Product requirement

The consumer describes one illuminated element, not a card pass and a border
pass. A normal use must have one aptitude and one coherent light direction:

```smalltalk
anElement
    geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
    border: (BlBorder paint: aBorderPaint width: 1);
    addAptitude: (CFLightBorderAptitude new
        beRaised;
        lightDirection: -1 @ -1;
        yourself).
```

`beRaised` means the complete raised appearance. `beLowered` means the
complete recessed appearance. Neither operation requires a second aptitude,
a second effect, a `...Card` selector, a `...Border` selector, or a raw style
symbol. The aptitude is a visual decoration in normal Brick terms: the
element retains ownership of its `geometry`, `background`, `outskirts`, and
immutable `BlBorder`.

The same single aptitude must work for:

- a raised card without a visible border;
- a lowered card without a visible border;
- a raised border/rim when the element has a border;
- a lowered border/rim when the element has a border;
- a raised or lowered card *with* its border, as one coordinated appearance;
- arbitrary Bloc geometry, not only rectangles and rounded rectangles.

## The design error to remove

The current aptitude has rendering-mechanism state:

- `drawOuter` / `drawInner`;
- `outerHighlightAlongLightDirection` /
  `innerHighlightAlongLightDirection`;
- `beRaisedCard`, `beRaisedBorder`, `beLoweredCard`, and
  `beLoweredBorder`.

Those are private decisions of an effect renderer. They must not be the
consumer model or the public configuration vocabulary. They also make
configuration order significant, which is why the screenshot is misleading.

The internal booleans can be retained temporarily during the refactor, but
they must be derived together by a single `beRaised` or `beLowered` operation.
No caller, example, or form stencil should combine separate card and border
aptitudes.

## Target design

Keep a single `CFLightBorderAptitude` that installs exactly one
`CFLightBorderEffect` in the element’s effect chain. The effect receives a
complete, immutable snapshot of the aptitude’s configuration and decides all
rendering passes together.

Responsibilities:

| Owner | Responsibility |
| --- | --- |
| `BlElement` | Geometry, background, `BlBorder`, `BlOutskirts`, layout and content. |
| `CFLightBorderAptitude` | Declarative lighting configuration and normal Brick installation through `addChangeProperty: #(widget effect)`. |
| `CFLightBorderEffect` | One ordered rendering algorithm: outside card face, native element paint, and any inside/border face overlays. It composes with an existing `BlElementEffect`. |

Do not add a second public aptitude, a child element, a field-slot concept, or
a parallel border model. Do not make the aptitude set the element border.

### Public vocabulary

Start with only intent-level messages:

```smalltalk
beRaised
beLowered
beFlat
lightDirection:
lightDirectionDegrees:
depth:
effectWidth:
highlightColor:
shadowColor:
```

`beInset`, `beOutset`, and `bePressed` may remain only as documented aliases
if there is a real consumer need. Do not use `style: #raised`, `style:
#emboss`, or any other symbol-dispatch API.

The orientation of every highlight and shadow is derived from the *one*
light direction plus the one raised/lowered disposition. Changing the light
direction must move all faces coherently.

### One renderer, not two effects

`CFLightBorderEffect` should model one lighting treatment. It may draw
multiple passes internally, but it must do so in a defined order within the
same effect instance:

1. outer/card-face lighting before the element paint;
2. let the existing element paint itself, including its ordinary `BlBorder`;
3. draw only the required inside/rim lighting after element paint.

For `beRaised`, the light-facing exterior is highlighted and the opposite
exterior is shadowed; the border-face contribution is derived as its
complement. For `beLowered`, invert both contributions as one operation.

This is composition *inside* the effect, where the render order and shared
light direction are controllable. It is not composition by chaining two
instances of the same aptitude through Brick’s property-change mechanism.

## Geometry is the remaining correctness gate

The current generic `BlElementGeometry>>#pathOnSpartaCanvas:of:` supplies one
boundary path. It is enough for a card’s outside/inside lighting, but it does
not by itself identify the inner edge of an arbitrary native `BlBorder`.

`BlOutskirtsInside` renders a border by clipping to the element geometry and
stroking that path at twice the border width. `BlOutskirtsCentered` and
`BlOutskirtsOutside` use different semantics. A correct bevelled rim needs
two boundaries:

- the appropriate visible outer edge of the element/border;
- the appropriate inner edge of that border band.

The current effect fakes this by reusing the same geometry path and clipping.
That is why the visual treatment can look inconsistent or have the wrong
relationship to a wide border. Do not polish that approximation further.

Before implementing a real border face, add a focused live-image probe for a
rectangle, rounded rectangle and ellipse, each with border widths 1, 3 and 8,
and each of Bloc’s three `BlOutskirts` policies. Establish whether the
existing geometry and Sparta APIs can produce the matching inset/outset path
for every geometry.

If they cannot, the smallest justified upstream capability is a generic
geometry/path operation that produces the relevant border boundary. It belongs
in Bloc/Sparta, not as Foundation branches for rectangles, ellipses or Magritte
fields. It must preserve arbitrary `BlElementGeometry`. Do not modify
`deps/Bloc` while this remains a Foundation task; first make and document the
minimal capability request/probe.

Until that boundary exists, the single aptitude may provide a polished raised
or lowered **card** treatment for any geometry. It must not claim to provide a
true raised/lowered border rim at all border widths.

## Refactor plan

1. Remove the two-aptitude form-stencil setup and all
   `...CardAndBorder` examples. Restore the form to one `CFLightBorderAptitude
   new beRaised` once that selector again means the complete treatment.
2. Collapse the public `...Card` and `...Border` selectors. Make `beRaised`
   and `beLowered` configure the full effect state atomically.
3. Replace the independent pass flags with one private, derived configuration
   in `CFLightBorderEffect`. The effect should be inspectable enough to prove
   it has one light direction, one disposition, and one underlying effect.
4. Add focused visual examples for flat, raised, lowered, direction reversal,
   rounded geometry, ellipse, border width and all `BlOutskirts` policies.
   Each example must be a single aptitude instance.
5. Decide, from the probes, whether a generic inner/outer border boundary is
   available. Only then implement the border-rim portion; otherwise leave it
   explicitly unsupported rather than drawing a misleading fake.
6. Move the general Bloc rendering classes out of
   `BVC-Foundation-Magritte-GT` if package structure permits. This lighting
   aptitude is Foundation/Bloc infrastructure, not a Magritte renderer.
   Keep Magritte form styling as its consumer, not its owner.
7. Apply the one final, verified aptitude in `CFMaFormStencilBuilder` only
   after the visual probes pass. The form builder should contain no lighting
   implementation details.

## Evidence and current files

Current experimental files:

- `src/BVC-Foundation-Magritte-GT/CFLightBorderAptitude.class.st`
- `src/BVC-Foundation-Magritte-GT/CFLightBorderEffect.class.st`
- `src/BVC-Foundation-Magritte-GT/CFLightBorderAptitudeExamples.class.st`
- `src/BVC-Foundation-Magritte-GT/CFMaFormStencilBuilder.class.st`

Relevant inspected Bloc behavior:

- `deps/Bloc/src/Bloc-Sparta/BlOutskirtsInside.extension.st`
- `deps/Bloc/src/Bloc-Sparta/BlOutskirtsCentered.extension.st`
- `deps/Bloc/src/Bloc-Sparta/BlOutskirtsOutside.extension.st`
- `deps/Bloc/src/Bloc-Sparta/BlBorder.extension.st`
- `deps/Brick/src/Brick-Core/BrAptitude.class.st`
- `deps/Brick/src/Brick-Core/BrLookPropertyChange.class.st`

The live image previously proved that a single effect can draw the basic
outside/inside card passes and preserve the element’s normal border. It also
proved that chaining two aptitude instances is mechanically possible. The
latter is specifically rejected as the public design.

The GT bridge has intermittently dropped during this work. On resumption,
recompile the current source first, then use the focused probes above; do not
trust an open example browser whose method source predates the files.

## Acceptance criteria

- One developer-facing aptitude instance creates one complete raised or
  lowered appearance.
- No public card/border pass selectors or mode symbols.
- The native `BlBorder` remains visible, crisp and element-owned.
- All facets honour the same light direction.
- The result is correct for supported arbitrary geometry and for the
  documented `BlOutskirts` behavior.
- If a true rim cannot be computed generically, the API states that honestly
  and does not fake it with multiple aptitudes or shape-specific code.
