import binascii
import sys

def hex_to_tiff(input_file, output_file):
    try:
        with open(input_file, 'r') as f:
            hex_data = f.read()
        
        # Remove spaces and convert to bytes
        byte_data = binascii.unhexlify(hex_data.replace(" ", "").replace("\n", ""))
        
        # Write to file
        with open(output_file, "wb") as f:
            f.write(byte_data)
        
        print("TIFF file has been written to {}".format(output_file))
    except Exception as e:
        print("An error occurred: {}".format(str(e)))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python hex_to_tiff.py <input_file> <output_file>")
    else:
        hex_to_tiff(sys.argv[1], sys.argv[2])

