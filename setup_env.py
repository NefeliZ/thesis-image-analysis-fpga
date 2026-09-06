import subprocess
import sys

# basic packages
packages = [
    "numpy",
    "pandas",
    "matplotlib",
    "seaborn",
    "requests",
    "beautifulsoup4",
    "openpyxl",
    "pillow",
    "opencv-python",
    "scikit-image"
]

print("---- start install packages")

for package in packages:
    print(f"installing {package}...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

print("\n---- all packages installed")