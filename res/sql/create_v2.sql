/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
-- -----------------------------------------------------------------------
-- COMPANY
-- -----------------------------------------------------------------------
CREATE TABLE company (
     company_id INTEGER PRIMARY KEY AUTOINCREMENT,
     logo TEXT,
     security_score REAL,
     breach_score REAL,
     sensitivity_score REAL,
     domain TEXT
);

-- -----------------------------------------------------------------------
-- SENDER
-- -----------------------------------------------------------------------
CREATE TABLE sender (
    sender_id INTEGER PRIMARY KEY AUTOINCREMENT,
    company_id INTEGER NOT NULL,
    name TEXT,
    email TEXT,
    category TEXT,
    unsubscribe_mail_to TEXT,
    ignore_until_epoch INTEGER,
    email_since_epoch INTEGER,
    unsubscribed_bool INTEGER,
    FOREIGN KEY(company_id) REFERENCES company(company_id)
);


-- -----------------------------------------------------------------------
-- MESSAGE
-- -----------------------------------------------------------------------
CREATE TABLE message (
    message_id INTEGER PRIMARY KEY AUTOINCREMENT ,
    ext_message_id TEXT,
    sender_id INTEGER NOT NULL,
    received_date_epoch INTEGER,
    opened_date_epoch INTEGER,
    account TEXT,
    FOREIGN KEY (sender_id) REFERENCES sender(sender_id),
    UNIQUE (ext_message_id, sender_id)
);