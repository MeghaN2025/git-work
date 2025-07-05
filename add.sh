#!/bin/bash

# Prompt the user for two numbers
read -p "Enter the first number: " num1
read -p "Enter the second number: " num2

# Calculate the sum
sum=$((num1 + num2))

# Display the result
echo "The sum of $num1 and $num2 is: $sum"

