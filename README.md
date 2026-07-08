# vislab-common

Shared resources for the Geisler Lab vision-science projects (`texture-learning`,
`texture-segmentation`, `camouflage_detection`). Kept as a **sibling folder** (`vislab-common`) next to those
repos (each project's `setup.m` auto-fetches it if it's missing), so the shared code and data live in exactly
one place.

This repo contains two things:
- **`+vislab/`** — the shared MATLAB namespace package (`+lib`, `+nat_stat_bayes`, `+psychframework`).
- **`data/`** — the shared data store (see the **Shared data store** section below for contents).

## Package

Everything is one MATLAB namespace package, `vislab`, with three subpackages. Call functions as
`vislab.<subpackage>.<function>`.

| Subpackage | Call as | Purpose |
|---|---|---|
| `+vislab/+lib` | `vislab.lib.*` | General vision/numerical utilities: optics (OTF), CSF, steerable/DoG/LoG filters, noise, `downsample`, patch/contrast normalization, color conversions, sample statistics (`dPrime`, `gauss_llr`, `maha_dist`), image math. |
| `+vislab/+nat_stat_bayes` | `vislab.nat_stat_bayes.*` | Natural-scene-statistics & Bayesian-observer toolkit: efficient-coding/PCA transforms, CDF + adaptive-histogram bin learning, and likelihood-ratio decision variables (power, histogram, edge, border, spatial). |
| `+vislab/+psychframework` | `vislab.psychframework.*` | Psychtoolbox experiment framework (trial/interval/feedback primitives, session I/O). |

Only genuinely cross-project code lives here. Project-specific code stays in its own repo — e.g. the
texture-segmentation grouping algorithm and GTR stimulus generation currently live in `texture-learning`
(as local `+segmentation` / `+gtr` packages) and may be promoted here later if shared. (Note: a project's
own local `+lib` is a different, project-scoped `lib.*` namespace — distinct from the shared `vislab.lib.*`.)

## Usage

Put the directory that **contains** `+vislab` on the MATLAB path (i.e. this `vislab-common` folder, not the
`+vislab` folder itself) so `vislab.*` resolves. Each consuming project ships a `setup.m` that does this:

```matlab
addpath(vislab_common_dir);   % exposes vislab.lib.*, vislab.nat_stat_bayes.*, vislab.psychframework.*
```

## Shared data store (`data/`)

The `data/` folder holds the shared assets. **Committed to git:** the two colour transforms
(`cps_rgb2lms.mat`, `cps_lms2abr_otf.mat`), `nat_im_eff_coding.mat`, the full `textures/` tree
(~379 MB: Brodatz, Fabric, Pertex, VisTex, McGill, …), and a **12-image demo subset** inside
`CPS natural images/`. This means a fresh clone can run the colour transforms, every texture dataset,
and train the natural-image pipeline out of the box. **Gitignored** (too big for GitHub, obtained
manually / synced via OneDrive): the rest of the full natural-image set (~19 GB) and the ~3.7 GB
`nat_im_cdfs.mat`.
The two colour transforms are loaded automatically the first time they're used (cached thereafter) —
**callers just call the function; they do not load the matrix**:
- `vislab.lib.rgb2lms(img)` — camera-RGB → LMS, using `data/cps_rgb2lms.mat` (var `lms`).
- `vislab.nat_stat_bayes.apply_color_rotation(patch)` — LMS → ABR, using `data/cps_lms2abr_otf.mat`
  (var `coeff`, the OTF-derived rotation produced by texture-learning stage 1).

Each also accepts an optional explicit matrix to override the shared one (tests, the non-OTF transform, or
the producing stage s1). This is the one place `vislab.*` reads from `data/`.

## External dependencies

- [IntClassNorm](https://github.com/abhranildas/IntClassNorm)
  (`classify_normals`, `quad2fun`) -- used by the Bayesian decision-variable code; itself depends on
  the generalized chi-square package `gx2`.
- MATLAB toolboxes used by parts of `vislab.lib`: Image Processing, Statistics & Machine Learning,
  DSP System, Parallel Computing.

## License

MIT License (see `LICENSE`).
