# VTM Toolbox — Vocal Tract Mimicry Analysis

A MATLAB toolbox for quantifying vocal tract kinematics from endoscopic video recordings during auditory emotion perception tasks. Tracks a dense grid of points across the vocal tract using Lucas-Kanade optical flow, and exports frame-level displacement, velocity, flow, and anatomical region metrics to a tab-delimited `.txt` file for downstream statistical analysis in R (or any other environment).

Developed to support research on vocal tract mimicry in response to emotional voices.

---

## Requirements

- MATLAB R2019b or later
- [Image Processing Toolbox](https://www.mathworks.com/products/image-processing.html)
- [Computer Vision Toolbox](https://www.mathworks.com/products/computer-vision.html)

---

## Input data format

The toolbox expects **pre-cut per-trial video clips** (`.mp4`), one file per trial, organised as follows:

```
rootFolder/
  participantID/
    Run1/
      emotion_trialnumber.mp4
      emotion_trialnumber.mp4
      ...
    Run2/
    Run3/
  anotherParticipantID/
    Run1/
    ...
  functions/          ← toolbox functions folder (see Installation)
```

Video filenames should follow the pattern `emotion_trialnumber.mp4` (e.g. `anger_42.mp4`, `happiness_6.mp4`). The emotion label and trial number are parsed directly from the filename.

**Video segmentation** (splitting continuous run recordings into per-trial clips) is not included in this toolbox and should be done beforehand using scripts tailored to your experimental software's logfile format (E-Prime, PsychoPy, Presentation, etc.).

---

## Installation

1. Clone or download this repository.
2. Copy the `functions/` folder into your root data folder (the same folder that contains your participant subfolders), or add it to your MATLAB path permanently via `pathtool`.
3. Open `VTM_main.m` in MATLAB.

---

## Configuration

Before running, set the fixed parameters in the **USER CONFIGURATION** block at the top of `VTM_main.m`:

```matlab
cfg.frameRate = 25;                        % acquisition frame rate (fps)
cfg.roi       = [226, 3, 1467, 1077];      % ROI [x, y, width, height] in pixels
                                            % use imrect() on a sample frame to find yours

cfg.mimicryWindowMs  = [50, 900];          % mimicry response window (ms re stimulus onset)
cfg.baselineWindowMs = [-200, -50];        % pre-stimulus baseline window (ms)

cfg.adaptiveTrackingThreshold = 0.3;       % point-loss fraction that triggers tracker refresh

cfg.frequencyBands = [0.5, 2; 2, 8; 8, 15]; % spectral bands [Hz]: Low / Speech / High

cfg.saveMatFiles = true;                   % save per-run .mat files (can be large: 100–500 MB/run)
                                            % set false to keep only the TXT export
```

**Setting the ROI:** the ROI defines the region of each video frame used for tracking and optical flow. To find your coordinates interactively, open a sample frame in MATLAB (`imshow(imread('yourframe.png'))`) and call `h = imrect()`, then `getPosition(h)`.

**Anatomical sub-regions:** the four anatomical ROIs (pharynx, larynx, epiglottis, vocal folds) are defined as proportional subdivisions of the main ROI in `functions/defineAnatomicalROIs.m`. Adjust the proportions there to match your imaging setup and anatomical landmarks.

---

## Running the toolbox

Run `VTM_main.m`. Three GUI dialogs will appear in sequence:

1. **Root data folder** — select the folder containing your participant subfolders.
2. **Participant selection** — multiselect list of all subfolders found; select one or more.
3. **Run selection** — multiselect checkboxes for Run 1, Run 2, Run 3.

Processing then runs automatically. Progress is printed to the MATLAB command window. For a typical participant with three runs of ~20 trials at 25 fps, expect roughly 5–15 minutes depending on video resolution and hardware.

---

## Output

All outputs are written inside each participant's folder:

```
participantID/
  DataExports/
    participantID_FrameLevel_Enhanced_<timestamp>.txt   ← main output
  TrialAnalysis/
    moving-average plots (.png) per trial
  ConditionAnalysis/
    DataInventory_participantID.txt
  SummaryReports/
    participantID_AnalysisSummary.txt
    DataSummary_participantID_Run1.mat   (if cfg.saveMatFiles = true)
    DataSummary_participantID_Run2.mat
    DataSummary_participantID_Run3.mat
```

### Frame-level TXT file

The main output is a tab-delimited text file with **one row per video frame per trial**. It can be read directly into R with `read.table(..., sep = "\t", header = TRUE)`.

| # | Column | Description |
|---|--------|-------------|
| 1 | `Participant` | Participant ID (from folder name) |
| 2 | `Gender` | Parsed from participant ID |
| 3 | `Age` | Parsed from participant ID |
| 4 | `Run` | Run number (1, 2, 3) |
| 5 | `Trial` | Trial number |
| 6 | `VoiceType` | Voice type label (e.g. `natural`, `synthetic_noise`) |
| 7 | `Condition` | Numeric condition code (neutral=1, pleasure=2, happiness=3, anger=4) |
| 8 | `Emotion` | Emotion label string |
| 9 | `Frame` | Frame index within trial |
| 10 | `Time_Seconds` | Frame time in seconds |
| 11 | `Displacement` | Mean displacement of fast-moving tracked points (pixels) |
| 12 | `MaxDisplacement` | Max displacement of tracked points (pixels) |
| 13 | `PointCount` | Number of fast-moving points retained this frame |
| 14 | `MeanVelocity` | Mean velocity of fast-moving points (pixels/frame) |
| 15 | `MaxVelocity` | Max velocity (pixels/frame) |
| 16 | `FlowMagnitude` | Mean optical flow magnitude in ROI (pixels/frame) |
| 17 | `FlowVx` | Mean horizontal optical flow component |
| 18 | `FlowVy` | Mean vertical optical flow component |
| 19 | `Entropy` | Image entropy of the frame (complexity measure) |
| 20 | `TotalPoints` | Total tracked points in frame |
| 21 | `TrackingQuality` | Proportion of points successfully tracked (0–1) |
| 22 | `PointLossRate` | Proportion of points lost this frame (0–1) |
| 23 | `Epiglottis_Movement` | Mean displacement in epiglottis sub-ROI (pixels) |
| 24 | `Vocal_folds_Movement` | Mean displacement in vocal folds sub-ROI (pixels) |
| 25 | `Pharynx_Movement` | Mean displacement in pharynx sub-ROI (pixels) |
| 26 | `Larynx_Movement` | Mean displacement in larynx sub-ROI (pixels) |
| 27 | `MaxAcceleration` | Max point acceleration this frame (pixels/frame²) |
| 28 | `FramesFromStimulus` | Frame index relative to stimulus onset |
| 29 | `SecondsFromStimulus` | Time (s) relative to stimulus onset |
| 30 | `LossTriggeredRefreshes` | Trial-level count: tracker refreshes triggered by point loss > threshold |
| 31 | `TotalRefreshes` | Trial-level count: all tracker refreshes (loss-triggered + periodic) |

`NaN` values are expected and normal for:
- Frames where tracked point density dropped below the analysis threshold (typically a few frames per trial in low-motion conditions)
- The last frame of each trial (optical flow requires a successor frame)
- Anatomical sub-region frames where no trackable points were found in that sub-ROI

Handle with `na.rm = TRUE` in R summaries or `na.action = na.omit` in mixed models.

---

## Downstream analysis in R

The frame-level TXT is designed to be the input for mixed-effects models. A minimal example:

```r
library(lme4)

dat <- read.table("p01_FrameLevel_Enhanced_20260309.txt",
                  sep = "\t", header = TRUE, na.strings = "NaN")

# Trial-level summary (aggregate frames per trial first)
library(dplyr)
trial_dat <- dat |>
  group_by(Participant, Run, Trial, VoiceType, Emotion) |>
  summarise(
    MeanDisplacement = mean(Displacement, na.rm = TRUE),
    MeanVelocity     = mean(MeanVelocity, na.rm = TRUE),
    LossRefreshes    = first(LossTriggeredRefreshes),
    .groups = "drop"
  )

# Mixed model: emotion effect on displacement
m <- lmer(MeanDisplacement ~ Emotion + (1 | Participant) + (1 | Trial),
          data = trial_dat)
summary(m)
```

---

## Citation

If you use this toolbox in published work, please cite:

> Ceravolo, L. (2025). *VTM Toolbox: Vocal Tract Mimicry Analysis* [Software]. Zenodo. https://doi.org/10.5281/zenodo.18936884

A `CITATION.cff` file is included for automated citation export from GitHub.

---

## License

MIT License — see `LICENSE` for details.

---

## Contact

Leonardo Ceravolo — University of Geneva  
Issues and pull requests welcome via GitHub.
