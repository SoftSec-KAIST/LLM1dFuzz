import binascii
import sys

def hex_to_der(input_file, output_file):
    try:
        with open(input_file, 'r') as f:
            hex_data = f.read()
        
        # Remove spaces and convert to bytes
        clean_hex = hex_data.replace(" ", "").replace("\n", "")
        
        if len(clean_hex) % 2 != 0:
            clean_hex = clean_hex + "0"

        byte_data = binascii.unhexlify(clean_hex)
        
        # Write to file
        with open(output_file, "wb") as f:
            f.write(byte_data)
        
        print("DER file has been written to {}".format(output_file))
    except Exception as e:
        print("An error occurred: {}".format(str(e)))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python hex_to_der.py <input_file> <output_file>")
    else:
        hex_to_der(sys.argv[1], sys.argv[2])

