#!/bin/bash
#Function for CSV data processing  @RahulKumar
process_input_csv() {
    local file="$1"
    local IFS=$'\n'
    local c=-1
    
    while read -r line; do
        ((c++))
        if ((c==0)); then
            continue
        fi
        IFS=$','
        #Logic for Sanitizing and Restructuring the URL   @RahulKumar
        read url description <<<"${line}"
        read eachurl <<<"${url}"
        common_prefix=$(echo "$eachurl" | awk -F "/" '{print $1"//"$3"/"$4"/"$5}')
        category=$(echo "$eachurl" | sed "s|$common_prefix||" | awk -F "/" '{print $2}')
        if [ -z "$category" ]; then
            category="overview"
        fi

	#Logic for Restructuring the Category from the URL and Title Consolidation
	#For example :
	# if the URL is https://example.com/data/ai/courses then the Category would be courses
	# @RahulKumar
        if [ -n "${common_prefixes[$common_prefix]}" ]; then
            common_prefixes["$common_prefix"]+="${category}: ${description}\n"
        else
            common_prefixes["$common_prefix"]="${category}: ${description}\n"
            prefix_order+=("$common_prefix")  # Store the order of common prefixes
        fi

        #Logic for storing the mapping of categories to descriptions  @RahulKumar
        categories_mapping["$category"]="${description}"
        if ! [[ " ${categories_order[@]} " =~ " ${category} " ]]; then
            categories_order+=("$category")
        fi
    done < "$file"
}

#Function for generating the Output CSV file  @RahulKumar
generate_output_csv() {
    local output_file="$1"
    local header="URL,"
    local category

    for category in "${categories_order[@]}"; do
        header="${header}${category},"
    done
    header="${header%?}" 
    echo "$header" > "$output_file"
    for prefix in "${prefix_order[@]}"; do
        row="${prefix},"  
        descriptions="${common_prefixes[$prefix]}"
        for category in "${categories_order[@]}"; do
            description=$(echo -e "$descriptions" | grep -m 1 "${category}:" | awk -F ": " '{print $2}')
            row="${row}${description},"
        done
        row="${row%?}"
        echo "$row" >> "$output_file"
    done
}

# Main function  @RahulKumar
main() {
    local input_file="/home/rahul_kumar/Desktop/Task/input.csv"      #Input File path   @RahulKumar
    local output_file="/home/rahul_kumar/Desktop/Task/output.csv"    #Output File path  @Rahul Kumar
    declare -A common_prefixes   
    declare -A categories_mapping
    declare -a categories_order
    declare -a prefix_order
    #Error Handling Logic    @RahulKumar
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file not found."
        exit 1
    fi

    process_input_csv "$input_file"
    generate_output_csv "$output_file"
}

# Execute main function   @RahulKumar
main

