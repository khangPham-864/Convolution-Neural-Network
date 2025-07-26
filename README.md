**Convolutional Neural Network (CNN)**
This project demonstrates the implementation in both Python and MIPS Assembly of a basic convolutional neural network (CNN), focusing on the core mathematical operations: padding and convolution

**Tech Stack**
- Python 
- NumPy
- MIPS Assembly (for explore low level operation)
- MARS (to run MIPS programs)

**Key Features**
Padding:
- Preserves image dimensions by adding a zero-value border.
- Prevents feature loss around image edges.
- Formula: New_image_size = Old_image_size + 2 * Padding

Convolution Operation:
- Slides an M x M kernel across a padded N x N image using a configurable stride.
- Computes dot products between the kernel and overlapping regions of the input.
- Produces a new output matrix representing feature activation.
- Full step-by-step explanation available in Report.doc.

**Visual Example** 
Demo input/output examples and diagrams can be found in the Report.doc file.

**How to Run**
Python
1. Ensure Python and NumPy installed.
2. Download .py file and run the simulation.

MIPS
1. Install MARS.
2. Download the following files into the same directory:
   + .asm
   + input.txt
   + output.txt
3. Run the program – results will be written to output.txt.
