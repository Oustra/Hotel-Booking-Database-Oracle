# Dataset Description

## Dataset Overview
| Field         | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| **hotel**     | Contains booking data for two hotels: a *Resort Hotel* and a *City Hotel*. |

## Fields Description
| Field                              | Description                                                                 |
|------------------------------------|-----------------------------------------------------------------------------|
| **is_canceled**                    | Booking cancellation status: `1` (Canceled) / `0` (Not Canceled)           |
| **lead_time**                      | Days between booking date and arrival date                                 |
| **arrival_date_year**              | Year of arrival (e.g., 2018)                                               |
| **arrival_date_month**             | Month of arrival (`January` to `December`)                                 |
| **arrival_date_week_number**       | Week number of arrival (1-53)                                              |
| **arrival_date_day_of_month**      | Day of month of arrival (1-31)                                             |
| **stays_in_weekend_nights**        | Number of weekend nights stayed (Saturday/Sunday)                          |
| **stays_in_week_nights**           | Number of weeknights stayed (Monday-Friday)                                |
| **adults**                         | Number of adults                                                           |
| **children**                       | Number of children                                                         |
| **babies**                         | Number of babies                                                           |
| **meal**                           | Meal plan: `BB` (Bed & Breakfast)                                          |
| **country**                        | Guest's country of origin                                                  |
| **market_segment**                 | Booking channel category (`TA`=Travel Agents, `TO`=Tour Operators)         |
| **distribution_channel**           | Booking distribution method                                                |
| **is_repeated_guest**              | Repeat guest status: `1` (Yes) / `0` (No)                                  |
| **previous_cancellations**         | Number of prior canceled bookings by guest                                 |
| **previous_bookings_not_canceled** | Number of prior honored bookings by guest                                  |
| **reserved_room_type**             | Code of originally booked room type                                        |
| **assigned_room_type**             | Code of actual assigned room type (may differ from reserved)               |
| **booking_changes**                | Number of modifications made to booking                                    |
| **deposit_type**                   | `No Deposit`/`Non Refund`/`Refundable` deposit status                      |
| **agent**                          | ID of travel agency (anonymized)                                           |
| **company**                        | ID of responsible company (anonymized)                                     |
| **days_in_waiting_list**           | Days booking spent in waiting list                                         |
| **customer_type**                  | `Group`/`Transient`/`Transient-party` booking type                         |
| **adr**                            | Average Daily Rate (total lodging cost ÷ total nights)                     |
| **required_car_parking_spaces**    | Number of requested parking spaces                                         |
| **total_of_special_requests**      | Number of special guest requests                                           |
| **reservation_status**             | `Check-Out` (completed stay)/`No-Show` (no check-in)                       |
| **reservation_status_date**        | Last status update date                                                    |
| **name**                           | Guest name                                                                 |
| **email**                          | Guest email                                                                |
| **phone-number**                   | Guest phone number                                                         |
| **credit_card**                    | Guest credit card number                                                   |