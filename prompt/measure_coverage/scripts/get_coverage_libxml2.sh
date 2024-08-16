#!/bin/bash

# File to store all coverage summaries
current_directory=$(pwd)
coverage_summary_file="$current_directory/coverage_summaries/libxml2.txt"

# Clear the coverage summary file if it already exists
> "$coverage_summary_file"

# Make libxml2
./build_targets/build_libxml2.sh

# Navigate to the libxml2-2.9.4 directory
cd libxml2-2.9.4

total_seed_cnt=$(find "$current_directory/../modified_seeds/libxml2/seeds" -type f | wc -l)
echo "Total file count: $total_seed_cnt"

# Perform coverage measurement
for i in $(seq 1 $total_seed_cnt)
do

  # Zeroing counters
  lcov --directory . --zerocounters
  
  # Capturing initial coverage data
  lcov --capture --initial --directory . --output-file coverage_base.info

  # Running the test with modified seeds
  ./xmllint --valid $current_directory/../modified_seeds/libxml2/seeds/seed-$i.xml

  # Capturing test coverage data
  lcov --no-checksum --directory . --capture --output-file coverage_test_$i.info

  # Combining base and test coverage data
  lcov --add-tracefile coverage_base.info --add-tracefile coverage_test_$i.info --output-file coverage_total.info
  
  # Appending the coverage summary to the file
  echo "Seed $i:" >> "$coverage_summary_file"
  echo "" >> "$coverage_summary_file"
  lcov --summary coverage_total.info &>> "$coverage_summary_file"
  echo "" >> "$coverage_summary_file"
  
done
