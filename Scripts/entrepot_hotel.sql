CREATE TABLE "DimHotel" (
  "hotel_key" INTEGER PRIMARY KEY,
  "hotel_name" VARCHAR2(255)
);

CREATE TABLE "DimAgent" (
  "agent_key" INTEGER PRIMARY KEY,
  "agent_id" INTEGER,
  "year" INTEGER,
  "starting_date" DATE,
  "total_work_hours" INTEGER,
  "total_commission" NUMBER(10,2)
);

CREATE TABLE "DimDate" (
  "date_key" INTEGER PRIMARY KEY,
  "full_date" DATE,
  "year" INTEGER,
  "month" INTEGER,
  "week_number" INTEGER,
  "day" INTEGER,
  "quarter" INTEGER,
  "day_of_week" INTEGER,
  "is_weekend" NUMBER(1) CHECK ("is_weekend" IN (0,1))
);

CREATE TABLE "DimCustomer" (
  "customer_key" INTEGER PRIMARY KEY,
  "name" VARCHAR2(255),
  "country" VARCHAR2(100),
  "is_repeated_guest" NUMBER(1) CHECK ("is_repeated_guest" IN (0,1)),
  "previous_cancellations" INTEGER,
  "previous_bookings_not_canceled" INTEGER,
  "customer_type" VARCHAR2(50),
  "required_car_parking_spaces" INTEGER,
  "total_of_special_requests" INTEGER,
);

CREATE TABLE "DimCustomerSecure" (
  "customer_key" INTEGER PRIMARY KEY,
  "credit_card" VARCHAR2(100),
  "email" VARCHAR2(255),
  "phone_number" VARCHAR2(50)
  CONSTRAINT fk_customerSecure FOREIGN KEY ("customer_key") REFERENCES "DimCustomer" ("customer_key")
);

CREATE TABLE "DimRoom" (
  "room_key" INTEGER PRIMARY KEY,
  "reserved_room_type" VARCHAR2(50),
  "assigned_room_type" VARCHAR2(50)
);

CREATE TABLE "DimMarket" (
  "market_key" INTEGER PRIMARY KEY,
  "market_segment" VARCHAR2(50),
  "distribution_channel" VARCHAR2(50)
);

CREATE TABLE "FactBooking" (
  "booking_id" INTEGER PRIMARY KEY,
  "hotel_key" INTEGER NOT NULL,
  "agent_key" INTEGER,
  "date_key" INTEGER NOT NULL,
  "is_canceled" NUMBER(1) CHECK ("is_canceled" IN (0,1)),
  "lead_time" INTEGER,
  "stays_in_weekend_nights" INTEGER,
  "stays_in_week_nights" INTEGER,
  "adults" INTEGER,
  "children" INTEGER,
  "babies" INTEGER,
  "meal" VARCHAR2(50),
  "room_key" INTEGER NOT NULL,
  "booking_changes" INTEGER,
  "deposit_type" VARCHAR2(50),
  "company" INTEGER,
  "days_in_waiting_list" INTEGER,
  "customer_key" INTEGER NOT NULL,
  "adr" NUMBER(10,2),
  "reservation_status" VARCHAR2(50),
  "reservation_status_date" DATE,
  "market_key" INTEGER NOT NULL,
  CONSTRAINT fk_hotel FOREIGN KEY ("hotel_key") REFERENCES "DimHotel" ("hotel_key"),
  CONSTRAINT fk_agent FOREIGN KEY ("agent_key") REFERENCES "DimAgent" ("agent_key"),
  CONSTRAINT fk_date FOREIGN KEY ("date_key") REFERENCES "DimDate" ("date_key"),
  CONSTRAINT fk_customer FOREIGN KEY ("customer_key") REFERENCES "DimCustomer" ("customer_key"),
  CONSTRAINT fk_room FOREIGN KEY ("room_key") REFERENCES "DimRoom" ("room_key"),
  CONSTRAINT fk_market FOREIGN KEY ("market_key") REFERENCES "DimMarket" ("market_key")
);
