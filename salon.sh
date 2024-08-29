#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Welcome to Edward Scissor Hands ~~~\n"

# Main menu with options
MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo -e "$1"
  fi
  
  # Retrieve and display services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # Display each service in the required format
  echo -e "\nWhat would you like done today?"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Prompt for user input
  read SERVICE_ID_SELECTED
  
  # Validate the user's selection
  case $SERVICE_ID_SELECTED in 
    1|2|3) SERVICE_MENU ;;
    *) MAIN_MENU "Please make a valid selection." ;;
  esac
}

SERVICE_MENU() {
  # Get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ *//;s/ *$//') # Trim whitespace

  # Ask for phone number 
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Check if number is in DB
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_NAME ]]
  then 
    # If no number in DB, get name
    echo -e "\nI don't have that number in my system. What's your name?"
    read CUSTOMER_NAME
    # Insert new customer into DB
    INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # Get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # Ask for appointment time
  echo -e "\nSure thing, $CUSTOMER_NAME. What time would you like your $SERVICE_NAME?"
  read SERVICE_TIME

  # Insert into DB
  INSERTED_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES($CUSTOMER_ID, '$SERVICE_TIME', $SERVICE_ID_SELECTED)")
  
  # Echo booking and return to menu 
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  
  EXIT
} 

EXIT() {
  echo -e "Thank you for visiting Edward Scissor Hands. Have a great day!"
  exit 0
}

MAIN_MENU
