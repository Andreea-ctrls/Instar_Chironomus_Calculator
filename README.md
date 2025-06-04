# Instar_Chironomus_Calculator

This R script provides a systematic workflow to classify larval instar stages based on morphological measurements following the size reference ranges defined by Richardi et al. (2013). The tool helps researchers assign each larva to an instar stage using multiple body-part measurements, compute mean instar stages per larva, and export enriched datasets for further analysis.

---

## Overview

Instar classification is important for studying larval development and ecological effects of environmental stressors. This workflow assigns each larva to an instar stage based on five key morphological measurements:

- **VL**: Ventral length of the head capsule  
- **LA**: Length of the antennae  
- **LM**: Length of the mandibles  
- **LMe**: Length of the mentum  
- **LVP**: Length of the ventromental plates  

Each measurement is compared against empirically defined size ranges for four instar stages (I to IV).

## Features

- Assigns instar stages for each morphological measurement, including intermediate ranges (e.g., "I-II").
- Converts instar labels to numeric scores for averaging.
- Calculates a mean instar stage per larva.
- Provides instar classification in both Roman numerals and numeric formats.
- Exports enriched data with instar info to an Excel file.
- Includes error handling for missing columns or invalid data.

## Input Data Format

- The input data frame must have one row per larva.
- Columns should contain numeric morphological measurements with the codes: `VL`, `LA`, `LM`, `LMe`, `LVP`.
- Each measurement corresponds to a larval body part size in micrometers.

## Usage

1. Load your larval measurement data into R as a data frame.
2. Assign your data frame name to the variable `input_dataframe_name` in the script.
3. Run the script to classify instars and export the results.

## How it Works

- The script references size thresholds from Richardi et al. (2013).
- For each measurement, it determines the instar stage based on where the value falls within defined size ranges.
- It handles cases where measurements fall between instar ranges by assigning intermediate labels (e.g., "II-III").
- Converts instar labels to numeric values to calculate an average instar per larva.
- Converts the numeric average back to a Roman numeral instar label, including intermediate ranges.

## Reference

To create this software, data from the following study were used:

```latex
@article{richardi2013determination,
  title={Determination of larval instars in Chironomus sancticaroli (Diptera: Chironomidae) using novel head capsule structures},
  author={Richardi, Vinicius S and Rebechi, D{\'e}bora and Aranha, Jos{\'e} MR and Navarro-Silva, M{\'a}rio A},
  journal={Zoologia (Curitiba)},
  volume={30},
  pages={211--216},
  year={2013},
  publisher={SciELO Brasil}
}
```
## Citation

If you use this workflow in your research, please cite:

```latex
type: software
authors:
  - orcid: 'https://orcid.org/0009-0008-3641-130X'
    given-names: Andreea Cristina
    DOI: 10.5281/zenodo.15561341
    family-names: Bonciu
    email: andreea.bonciu@muse.it
    affiliation: MUSE - Museo delle Scienze di Trento
license: MIT
version: '01'
date-released: '2025-05-28'

