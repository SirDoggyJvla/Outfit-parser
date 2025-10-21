import re

file = "/home/simon/Documents/ProjectZomboid/ZomboidDecompiler/bin/PZDecompile/zombie/vehicles/UI3DScene.java"

## parse the file and make a list of elements in a "case <val>:" pattern
# Read the file
with open(file, 'r') as f:
    content = f.read()

# Find all case statements using regex
case_pattern = r'case\s+([^:]+):'
matches = re.findall(case_pattern, content)

# Clean up the matches (remove quotes and whitespace)
case_values = [match.strip().strip('"\'') for match in matches]

# Remove duplicates and sort
unique_case_values = sorted(set(case_values))

print("Found case values:")
for value in unique_case_values:
    print(f"  {value}")


# Write to output file
output_file = "Scripts/parseUI3DScene.txt"
with open(output_file, 'w') as f:
    for value in unique_case_values:
        f.write(f"{value}\n")