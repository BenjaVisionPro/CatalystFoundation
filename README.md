# Catalyst Foundation

Catalyst Foundation helps Smalltalk developers build rich tools around their own
objects without starting every editor, configuration model, and interaction from
scratch. It brings together shared model conventions, Magritte-based forms,
Atelier editing workspaces, and the motion and physics packages used by Catalyst's
GT interfaces. Use it when you want inspectable, adaptable application tooling.

## Features

- Shared identifiable and labelled objects for application models.
- Magritte descriptions and editor support, with GT/detail presentations and
  separate Seaside integration packages.
- Atelier workspaces combining a model's form with palettes, inspectors, and
  assessed editing operations, including drag and drop.
- Composer forms and relation editing for structured object models.
- Configuration libraries, graph copying, placement planning, validation, and
  configuration editor packages.
- Motion timelines and property tracks for opacity, translation, rotation,
  scale, extent, and coordinated layout changes.
- Physics bodies, forces, joints, collision handling, and Bloc/Mondrian tooling.

The `foundation-core` group loads shared base objects without Magritte.
Description/editor methods are supplied by the optional Magritte packages.
On plain Pharo, the optional model uses upstream Magritte plus its non-GT
compatibility extension. In GT, it retains the GT model; registered model
repository selections take precedence. Neither path is selected by `foundation-core`.
The existing `foundation-common` group holds the shared model/configuration layer
and includes Magritte support; on Pharo it declares its Magritte model dependency explicitly.
GT UI, Atelier, Composer, Motion, and Physics belong to the Pharo development
environment. Platform support follows the selected package group; the presence
of a shared group does not establish GemStone parity for the UI packages.

## Installation

Install Catalyst through [BVC](https://github.com/BenjaVisionPro/bvc#install).
With BVC installed, create and launch a local development project:

```sh
bvc init MyCatalystProject
cd MyCatalystProject
bvc run
```

BVC builds and launches the GT/Pharo DevKit without starting a GemStone deployment.
Your project's BVC configuration selects the components and startup packages.
Package-loading details below describe development inside that environment.

## Package loading and documentation

BVC uses `BaselineOfCatalystFoundation`. Its Pharo default includes the shared
foundation and UI groups; `atelier` and `composer` are also explicit groups.
Motion and Physics source currently lives in this repository.

For package development in an already prepared environment, the equivalent
Metacello entry point is:

```smalltalk
Metacello new
    repository: 'github://BenjaVisionPro/CatalystFoundation:main/src';
    baseline: 'CatalystFoundation';
    load.
```

Load the repository's Lepiter material from a registered checkout with:

```smalltalk
BaselineOfCatalystFoundation loadLepiter.
```

Examples and tests live alongside the relevant packages. Validate the package
groups and integrations you use in your own application; this README does not
claim a separately qualified release across every supported host.

## License

This repository is licensed under the [Catalyst Developer License](LICENSE).

Each developer using Catalyst for development needs an active
BenjaVision-Catalyst subscription: **$5 per month, billed annually at $60 per
developer**, including access to the BenjaVision-Catalyst repository. New products,
updates, bug fixes, and recompilation require active developer subscriptions.
Automated build machines do not need separate subscriptions.

Products lawfully built during active subscriptions may continue to be used,
hosted, sold, and distributed indefinitely without runtime royalties. Customers
and operators do not need subscriptions solely to use or distribute those builds.
Commercial and proprietary products are permitted; this license does not require
you to publish your own source code.

Existing license grants and separately licensed third-party material remain
unaffected. See [LICENSE](LICENSE) for the complete terms.
