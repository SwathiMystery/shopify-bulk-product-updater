#! /usr/bin/env bash
# This script accepts a filename and updates the
# body_html for each product. The body_html is a table
# of HTML content from various fields. 
#
# @author Swathi Venkatachala

set -o errexit  # Exit if any command fails

function help {
    echo -e "Convert CSV file to valid HTML table.\n"
    echo "Required arguments:"
    echo "  -i              Path to input file"
    echo "  --input-file"
    echo "Optional arguments:"
    echo "  -o              Output file path (default: $input_filename.html)"
    echo -e "   --output-file\n"
    echo "  -d              Delimiter (default: ,)"
    echo "  --delimiter"
}

# Handle passed arguments
while [[ $# -gt 1 ]]; do
    key="$1"
    case $key in
        -i|--input-file)
        input_file="$2"
        shift
        ;;
        -d|--delimiter)
        delimiter="$2"
        shift
        ;;
        -o|--output-file)
        output_file="$2"
        shift
        ;;
        *)  # Invalid argument passed
        help
        exit
        ;;
    esac
    shift
done

if [ -z "${input_file}" ]; then
    echo "ERROR! Input file not set."
    help
    exit
fi

if [ ! -f "${input_file}" ]; then
    echo "ERROR! Given file does not exist!"
    help
    exit
fi

output=${output_file:-"${input_file}.html"}
IFS=${delimiter:-,}

echo "Converting ${input_file} to HTML..."
{
    read -r -a headers
    while IFS=${delimiter:-,} read -r -a line; do
        body_html=""
        FIRST=1
        handle=""
        for i in "${!line[@]}"; do
            if [ $FIRST -eq 1 ]
            then
                handle=${line[i]}
                FIRST=0
                table_content=""
            else 
                
                cell_name="<td>${headers[i]//,/</td><td>}</td>"
                cell_value="<td>${line[i]//,/</td><td>}</td>"
               
                table_content="$table_content<tr>${cell_name}${cell_value}</tr>"
            fi
        done
      
    body_html="<table>$table_content</table>"
    shopt -s extglob
    body_html="${body_html##*()}"
    shopt -u extglob
    echo "$handle, $body_html" >> $output
    done  
} < $input_file


echo "Finished! Output saved to ${output}."
exit