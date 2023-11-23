#!/bin/zsh

if [ "$#" -ne 2 ]; then
  echo "Param đâu ku ~~~ Dùng như này ku \\n$0 <input_csv_file> <output_json_folder_path>"
  exit 1
fi

input_csv_file="$1"
output_dir="$2"

#Tổng số hàng
total_lines=$(wc -l < "$input_csv_file")

# Lấy hàng đầu tiên
IFS=';' read -A column_names <<< "$(head -n 1 "${input_csv_file}")"
# Lấy số lượng cột từ hàng đầu tiên
num_columns=${#column_names[@]}

# Check từ hàng thứ hai
row_number=2
while IFS=';' read -A values; do
    # Kiểm tra xem số lượng giá trị trong hàng có bằng số lượng cột không
    if [[ ${#values[@]} -eq ${num_columns} ]]; then
        # Lặp qua từng giá trị trong hàng và tên cột tương ứng
        for i in {2..${num_columns}}; do
            column=${column_names[i]}
            value=${values[i]}

            #Tên cột sai định dạng thì thôi
            if [[ ! -n "${column}" || ! "${column}" =~ ^[[:alnum:]]+$ ]]; then
              continue
            fi

            json_file="${output_dir}/${column}.json"

            if [[ ${row_number} == 2 ]]; then
              echo "{" >> "$json_file"
            fi

            #Key mà sai định dạng thì thôi
            if [[ -n "${values[1]}" && "${values[1]}" =~ ^[[:alnum:]]+$ ]]; then   
              echo "  \"$values[1]\": \"$value\"," >> "$json_file"
            fi

            # Kiểm tra xem đã đọc đến cuối tệp chưa
            if [ ${total_lines} -lt ${row_number} ]; then
             # Xóa dấu phẩy cuối cùng
              sed '$s/,$//' "$json_file" > tmpfile && mv tmpfile "$json_file"
              echo "}" >> "$json_file"
            fi
        done
    fi
    # Tăng số hàng
    ((row_number++))
done < "$input_csv_file"
echo "DONE"

