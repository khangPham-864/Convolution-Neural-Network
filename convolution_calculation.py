import numpy as np

def convolve2D(image, kernel, stride, padding):
    # Dimensions of the input and the kernel
    image_height, image_width = image.shape
    kernel_height, kernel_width = kernel.shape 

    # Initialize the new input feature map (input map after padding)
    new_image = np.zeros((image_height + 2 * padding, image_width + 2 * padding))
    # Dimensions of the new input
    new_image_height, new_image_width = new_image.shape  

    # Apply padding and print the result
    new_image[padding:new_image_height-padding, padding:new_image_width-padding] = image 
    print("\nNew Image:\n", new_image)

    # Calculate dimensions of the output feature map
    output_height = int((new_image_height - kernel_height) / stride) + 1
    output_width = int((new_image_width - kernel_width) / stride) + 1

    # Initialize the output feature map
    output = np.zeros((output_height, output_width))

    # Perform convolution operation
    for y in range(0, output_height):
        for x in range(0, output_width):
            # Extract the current region of the image where the kernel is applied
            current_region = new_image[y*stride:y*stride+kernel_height, x*stride:x*stride+kernel_width]
            print("\ncurrent_region:\n", current_region)
            # Perform element-wise multiplication and sum the result
            output[y, x] = np.sum(current_region * kernel)
    
    return output

# Example input matrix 
image = np.array([
    [-3.0, -4.0, 4.5],
    [6.0, 7.8, 12.0],
    [5.0, -0.5, 12.0]
])

# Example kernel 
kernel = np.array([
    [1.0, 1.2, -1.3],
    [4.5, -5.0, 3.0],
    [3.5, 6.0, -8.9]
])

# Print the initial image and kernel 
print("\nInput Image:\n", image)
print("\nKernel:\n", kernel)

# Perform 2D convolution with stride 1
output = convolve2D(image, kernel, stride=1, padding=2)

# Print the result
print("\nConvolved Feature Map:\n", output)
