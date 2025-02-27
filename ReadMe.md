# SIFT Image Retrieval Project

This project implements an image retrieval system leveraging the Scale-Invariant Feature Transform (SIFT) algorithm. It extracts SIFT keypoints and descriptors from a set of query images and a gallery of images, then ranks the gallery images based on their similarity to each query image. The feature extraction is performed using MATLAB, while the similarity computation and ranking are handled in Python.

## Project Overview

The system operates in two main phases:
1. **Feature Extraction**: MATLAB scripts process images to detect keypoints and compute SIFT descriptors, saving the results as `.mat` files and visualizing keypoints in `.jpg` files.
2. **Image Ranking**: A Python script computes similarity scores between query and gallery images using the extracted SIFT descriptors, generates ranked lists, and organizes the top matches in an output folder.

## Requirements

- **MATLAB**: Required for SIFT feature extraction. Ensure the Parallel Computing Toolbox is installed for parallel processing.
- **Python 3.x**: Required for ranking and similarity computation.
- **Python Libraries**:
  - `numpy`: For numerical operations.
  - `scipy`: For loading `.mat` files and scientific computations.
  - `shutil`: For file operations (included in Python standard library).

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/sift-image-retrieval.git
   cd sift-image-retrieval
   ```

2. **Install Python Dependencies**:
   ```bash
   pip install numpy scipy
   ```

3. **Verify MATLAB Installation**:
   - Ensure MATLAB is installed and callable from the command line.
   - Confirm the Parallel Computing Toolbox is available (optional but recommended for performance).

## Usage

### Step 1: Extract SIFT Features
- **Prepare Image Folders**:
  - Place query images in a folder (e.g., `../data/query_cropped`).
  - Place gallery images in another folder (e.g., `../data/gallery`).
  - Images must be in `.jpg` format.

- **Run the Feature Extraction Script**:
  Use the `extract_all_sift.m` function in MATLAB to process the images:
  ```matlab
  extract_all_sift("../data/query_cropped", "./out/query_cropped_features")
  extract_all_sift("../data/gallery", "./out/gallery_features")
  ```
  - **Input**: Path to the image folder and output folder.
  - **Output**: For each image, a subfolder is created in the output directory containing:
    - `[image_name].mat`: Keypoints and descriptors.
    - `[image_name].jpg`: Visualization of detected keypoints.

### Step 2: Generate Rank Lists
- **Run the Ranking Script**:
  Use the `generate_rank.py` Python script to compute similarities and rank gallery images:
  ```bash
  python generate_rank.py
  ```
  - **Default Configuration** (as specified in `main()`):
    - Query folder: `./out/query_cropped_features_2/`
    - Gallery folder: `./out/gallery_features_2/`
    - Output folder: `./match_results_3/`
    - Top-k matches: `10`
    - Output file: `rank_list_3.txt`
  - **Output**:
    - A `match_results_3` folder with subfolders for each query, containing:
      - The query image (`[query_name].jpg`).
      - Top-k matched gallery images (`top[i]_[gallery_name].jpg`).
    - A `rank_list_3.txt` file listing ranked gallery image names for each query in the format `Q[index]: [gallery_names]`.

## Code Structure

### MATLAB Functions
- **`computeGradient.m`**:
  - Computes gradient magnitude and orientation in a 16x16 window around a point using the Sobel operator.
- **`constructScaleSpace.m`**:
  - Builds Gaussian and Difference of Gaussians (DoG) pyramids for multi-scale analysis.
- **`detectKeypoints.m`**:
  - Identifies keypoints by detecting local extrema in the DoG pyramid, filtered by a contrast threshold.
- **`extractSIFTDescriptors.m`**:
  - Generates 128-dimensional SIFT descriptors for keypoints, incorporating gradient histograms and normalization.
- **`extract_all_sift.m`**:
  - Processes all `.jpg` images in a folder, extracts SIFT features using parallel processing, and saves results.

### Python Script
- **`generate_rank.py`**:
  - Computes similarity between query and gallery descriptors using a ratio test, ranks gallery images, and organizes output.

## Parameters

### Feature Extraction (MATLAB)
- **`detectKeypoints.m`**:
  - `numOctaves`: Number of octaves in the scale space (default: 4).
  - `numScales`: Scales per octave (default: 5).
  - `octaveInitialSigma`: Initial Gaussian sigma (default: 1.6).
  - `contrastThreshold`: Minimum contrast for keypoint detection (default: 0.01).

### Similarity Computation (Python)
- **`compute_similarity`**:
  - `ratio_threshold`: Threshold for the ratio test to filter good matches (default: 0.8).
- **`compute_rank_lists`**:
  - `top_k`: Number of top gallery images to retrieve per query (default: 10 in `main()`).

## Example

1. **Prepare Folders**:
   - Query images: `../data/query_cropped`
   - Gallery images: `../data/gallery`

2. **Extract Features**:
   ```matlab
   extract_all_sift("../data/query_cropped", "./out/query_cropped_features")
   extract_all_sift("../data/gallery", "./out/gallery_features")
   ```

3. **Generate Rankings**:
   ```bash
   python generate_rank.py
   ```

4. **View Results**:
   - Check `./match_results_3/` for matched images and `rank_list_3.txt` for rankings.

## Notes

- **SIFT Algorithm**: Based on David Lowe’s original implementation, designed for scale and rotation invariance.
- **Image Format**: The code processes only `.jpg` files; ensure all images are in this format.
- **Parallel Processing**: MATLAB’s `parfor` requires the Parallel Computing Toolbox. Without it, processing will be sequential and slower.
- **Educational Use**: This project is optimized for learning and demonstration. For large-scale applications, consider optimizing memory usage and processing speed.
- **Customization**: Adjust parameters like `contrastThreshold`, `ratio_threshold`, or `top_k` to fine-tune performance for specific datasets.
