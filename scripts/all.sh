#!/bin/bash

echo "Which script you want to execute ?"
echo "1. All scritps"
echo "2. deb.sh"
echo "3. rpm.sh"
echo "You can enter multiple choice, sperated by a space (ex: 1 3)"
read -p "Enter choices : " choices

execute_all() {
    echo "Executing all scripts..."
    for script in ./*.sh; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            echo "Executing $script"
            "$script"
        fi
    done
}

execute_deb() {
    echo "Executing deb.sh..."
    ./deb.sh
}

execute_rpm() {
    echo "Executing rpm.sh..."
    ./rpm.sh
}

for choice in $choices; do
    case $choice in
        1)
            execute_all
            ;;
        2)
            execute_deb
            ;;
        3)
            execute_rpm
            ;;
        *)
            echo "Invalid choice : $choice. pass."
            ;;
    esac
done

echo "Execution finished"
