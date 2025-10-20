import subprocess
import sys
import numpy as np
from PIL import Image

def run_cpp_convolution(channel_array: np.ndarray, cpp_executable: str) -> np.ndarray:
    xdim, ydim = channel_array.shape

    # Prepare input string for C++ program
    input_str = f"{xdim} {ydim}\n"
    for i in range(xdim):
        input_str += " ".join(str(val) for val in channel_array[i]) + "\n"

    # Run C++ executable
    process = subprocess.Popen(
        ["./" + cpp_executable],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    out, err = process.communicate(input=input_str)

    if process.returncode != 0:
        raise RuntimeError(f"C++ error: {err}")

    # Parse output back into numpy array
    output_vals = list(map(float, out.strip().split()))
    out_array = np.array(output_vals).reshape(xdim, ydim)

    # Clip to valid pixel range
    out_array = np.clip(out_array, 0, 255).astype(np.uint8)
    return out_array

def run_convolution(input_png: str, output_png: str, cpp_executable: str):
    # Load image as RGB
    img = Image.open(input_png).convert("RGB")
    r, g, b = img.split()

    # Convert to numpy arrays
    r_arr = np.array(r, dtype=np.float64)
    g_arr = np.array(g, dtype=np.float64)
    b_arr = np.array(b, dtype=np.float64)

    # Run convolution for each channel
    r_out = run_cpp_convolution(r_arr, cpp_executable)
    g_out = run_cpp_convolution(g_arr, cpp_executable)
    b_out = run_cpp_convolution(b_arr, cpp_executable)

    # Merge channels back
    out_img = Image.merge("RGB", (Image.fromarray(r_out),
                                  Image.fromarray(g_out),
                                  Image.fromarray(b_out)))

    out_img.save(output_png)
    print(f"Convolved color image saved as {output_png}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python wrapper.py <input.png> <output.png> <cpp binary>")
        sys.exit(1)

    run_convolution(sys.argv[1], sys.argv[2], sys.argv[3])
