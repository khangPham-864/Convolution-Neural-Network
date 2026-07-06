# CNN Convolution Operation in Python and MIPS Assembly

## Project Overview

This project implements the core **2D convolution operation** used in Convolutional Neural Networks (CNNs).

The goal of the project is to simulate how a CNN applies a kernel/filter over an input image matrix to produce an output feature map. The project includes two implementations:

1. A **Python NumPy implementation** used as a reference model.
2. A **MIPS Assembly implementation** that performs the same convolution process at low level.

This was developed as an individual Computer Architecture project.

---

## Tech Stack

- **Python**
- **NumPy**
- **MIPS Assembly**
- **MARS MIPS Simulator**
- File I/O in MIPS
- Floating-point arithmetic in MIPS

---

## Problem

CNN convolution is usually done by high-level libraries such as NumPy, TensorFlow, or PyTorch. However, at the hardware and architecture level, convolution is still built from basic operations:

- Reading data from memory
- Moving values between registers
- Multiplying floating-point numbers
- Adding accumulated results
- Using loops and branches
- Writing results back to memory or file

The challenge of this project is to manually implement the convolution process in **MIPS Assembly**, including:

- Reading matrix data from an input file
- Parsing integer and floating-point values
- Applying zero-padding
- Sliding the kernel across the image
- Calculating element-wise multiplication
- Accumulating the result
- Writing the final output matrix to a file

---

## How the Project Solves the Problem

The project solves the convolution problem by breaking it into smaller steps.

### 1. Read Input Data

The program reads an input file containing:

```txt
N M p s
image matrix values
kernel matrix values
```

Where:

| Symbol | Meaning |
|---|---|
| `N` | Size of the input image matrix |
| `M` | Size of the kernel matrix |
| `p` | Padding size |
| `s` | Stride value |

The image matrix has size `N x N`.

The kernel matrix has size `M x M`.

---

### 2. Apply Zero Padding

Padding is used to add zero values around the original image matrix.

The new padded image size is:

```txt
new_N = N + 2p
```

For example, if the original image is `3x3` and padding is `1`, the padded image becomes `5x5`.

This allows the kernel to cover edge pixels more effectively.

---

### 3. Calculate Output Size

After padding, the output matrix size is calculated as:

```txt
output_size = ((N + 2p - M) / s) + 1
```

Where:

- `N + 2p` is the padded image size
- `M` is the kernel size
- `s` is the stride

---

### 4. Perform Convolution

For each output position, the kernel is placed over a matching region of the padded image.

At each position:

```txt
output value = sum of image pixel * kernel value
```

In simple form:

```txt
sum = 0

for kernel_x from 0 to M - 1:
    for kernel_y from 0 to M - 1:
        sum += image[x + kernel_x][y + kernel_y] * kernel[kernel_x][kernel_y]
```

The final `sum` becomes one value in the output feature map.

---

## Project Structure

```txt
.
├── source_code.asm
├── convolution_calculation.py
├── input_matrix.txt
├── output matrix.txt
└── README.md
```

### `source_code.asm`

Main MIPS Assembly implementation.

It handles:

- Opening the input file
- Reading file content into a buffer
- Parsing `N`, `M`, `p`, and `s`
- Parsing image matrix values
- Parsing kernel matrix values
- Applying zero-padding
- Performing convolution
- Writing the final output matrix to an output file

### `convolution_calculation.py`

Python reference implementation using NumPy.

It is used to:

- Test the convolution logic
- Compare expected results with the MIPS output
- Debug padding, stride, and output size calculations more easily

---

## Input Format

The input file should contain 3 rows.

Example:

```txt
5 3 0 1
1.2 1.5 2.1 0.0 0.0 0.0 1.0 1.0 1.0 0.0 0.0 0.0 1.0 1.0 1.0 0.0 0.0 1.0 1.0 0.0 0.0 1.0 1.0 0.0 0.0
1.0 0.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0
```

Meaning:

```txt
N = 5
M = 3
p = 0
s = 1
```

Image matrix:

```txt
1.2 1.5 2.1 0.0 0.0
0.0 1.0 1.0 1.0 0.0
0.0 0.0 1.0 1.0 1.0
0.0 0.0 1.0 1.0 0.0
0.0 1.0 1.0 0.0 0.0
```

Kernel matrix:

```txt
1.0 0.0 1.0
0.0 1.0 0.0
1.0 0.0 1.0
```

---

## Output Format

The program writes the convolution result into:

```txt
output matrix.txt
```

Example output:

```txt
5.3000 3.5000 5.1000
2.0000 4.0000 3.0000
2.0000 3.0000 4.0000
```

---

## How to Run the Python Version

### 1. Install NumPy

```bash
pip install numpy
```

### 2. Run the Python file

```bash
python convolution_calculation.py
```

The Python program prints:

- Original input image
- Kernel matrix
- Padded image
- Current kernel region at each step
- Final convolved feature map

---

## How to Run the MIPS Assembly Version

### 1. Open MARS

Open the MARS MIPS simulator.

### 2. Open the Assembly File

Open:

```txt
source_code.asm
```

### 3. Update File Paths

Inside the `.data` section, update the input and output file paths to match your own computer.

Example:

```asm
fileO: .asciiz "D:\\your_path\\input_matrix.txt"
filename: .asciiz "D:\\your_path\\output matrix.txt"
```

### 4. Assemble and Run

In MARS:

1. Click **Assemble**
2. Click **Run**
3. Check the console output
4. Open `output matrix.txt` to view the final convolution result

---

## Main Algorithm

```txt
Start

Read input file

Parse N, M, padding, stride

Parse image matrix

Parse kernel matrix

Create padded image matrix

Copy original image into the center of padded matrix

Calculate output size

For each output row:
    For each output column:
        Calculate x_offset = row * stride
        Calculate y_offset = column * stride
        sum = 0

        For each kernel row:
            For each kernel column:
                Get image value
                Get kernel value
                Multiply them
                Add result to sum

        Store sum in output matrix

Write output matrix to file

End
```

---

## Example Test Case

Input:

```txt
5 3 0 1
1.2 1.5 2.1 0.0 0.0 0.0 1.0 1.0 1.0 0.0 0.0 0.0 1.0 1.0 1.0 0.0 0.0 1.0 1.0 0.0 0.0 1.0 1.0 0.0 0.0
1.0 0.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0
```

Output:

```txt
5.3000 3.5000 5.1000
2.0000 4.0000 3.0000
2.0000 3.0000 4.0000
```

---

## Key Features

- Implements 2D convolution manually
- Supports square image matrices
- Supports square kernel matrices
- Supports zero-padding
- Supports stride
- Uses floating-point calculations
- Uses file input and file output in MIPS
- Includes a Python NumPy version for checking correctness
- Demonstrates how high-level CNN operations can be translated into low-level assembly instructions

---

## Challenges Faced

The most difficult parts of this project were:

- Parsing floating-point numbers manually in MIPS
- Handling negative numbers and decimal values
- Managing memory addresses for 2D matrices stored as 1D arrays
- Applying padding correctly
- Calculating the correct index for each image and kernel element
- Writing formatted floating-point results to an output file
- Debugging convolution results between Python and MIPS

---

## What I Learned

Through this project, I learned how a CNN convolution operation works at a much lower level.

Instead of relying only on high-level libraries, I implemented the operation using:

- Registers
- Memory addresses
- Loops
- Branch instructions
- Floating-point registers
- File syscalls
- Manual matrix indexing

This helped me better understand the connection between machine-level programming and deep learning operations.

---

## Future Improvements

Possible improvements for this project include:

- Support non-square matrices
- Support multiple channels such as RGB images
- Support multiple kernels
- Add automatic comparison between Python output and MIPS output
- Improve input validation
- Remove hardcoded file paths
- Add more test cases
- Format output more cleanly
- Build a small script to generate random test cases

---

## Credits

This is an individual project.

Author:

```txt
Pham Le Nguyen Khang
```

---

## Summary

This project demonstrates how the convolution operation used in CNNs can be implemented both in Python and in MIPS Assembly.

The Python version provides a clear and simple reference implementation, while the MIPS version shows how the same logic can be performed manually using low-level instructions, memory management, loops, and floating-point arithmetic.
