/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
-- -----------------------------------------------------------------------
-- AUTH SERVICE ACCOUNT
-- -----------------------------------------------------------------------
CREATE TABLE auth_service_account (
    account_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT,
    provider TEXT,
    access_token TEXT,
    access_token_expiration INTEGER,
    refresh_token TEXT,
    refresh_token_expiration INTEGER,
    should_reconnect INTEGER,
    created_epoch INTEGER NOT NULL,
    modified_epoch INTEGER NOT NULL
);