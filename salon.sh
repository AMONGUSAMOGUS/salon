#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~Bakr's Salon~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"
SERVICE_MENU(){
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT service_id,name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
  echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID ]]
  then
SERVICE_MENU "I could not find that service. What would you like today?"
 else
echo -e "What's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
  then
#new customer
echo -e "I don't have a record for that phone number, what's your name?"
read CUSTOMER_NAME
INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
SERVICE_NAME_FRMT=$(echo $SERVICE_NAME |  sed -E 's/^ *| *$//g')
echo -e "What time would you like your $SERVICE_NAME_FRMT, $(echo $CUSTOMER_NAME |  sed -E 's/^ *| *$//g')"
read SERVICE_TIME
#correct time
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
echo "I have put you down for a $SERVICE_NAME_FRMT at $SERVICE_TIME, $(echo $CUSTOMER_NAME |  sed -E 's/^ *| *$//g')."
  else
#old customer
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
SERVICE_NAME_FRMT=$(echo $SERVICE_NAME |  sed -E 's/^ *| *$//g')
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
echo -e "What time would you like your $SERVICE_NAME_FRMT, $(echo $CUSTOMER_NAME |  sed -E 's/^ *| *$//g')"
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
read SERVICE_TIME
#correct time
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
SERVICE_NAME_FRMT=$(echo $SERVICE_NAME |  sed -E 's/^ *| *$//g')
echo "I have put you down for a $SERVICE_NAME_FRMT at $SERVICE_TIME, $(echo $CUSTOMER_NAME |  sed -E 's/^ *| *$//g')."
fi
fi
}
SERVICE_MENU
