-- =========================================================
-- 1. CREATE DATABASE (optional, depends on your SQL engine)
-- =========================================================
CREATE DATABASE credit_risk_db;

-- If your DBMS supports schemas, you can also do:
-- CREATE SCHEMA credit_risk;
-- and then prefix tables with credit_risk. like credit_risk.customer

-- =========================================================
-- 2. REFERENCE / LOOKUP TABLES
-- =========================================================

-- Currency codes (ISO-like)
CREATE TABLE currency (
    currency_code       CHAR(3) PRIMARY KEY,
    currency_name       VARCHAR(50) NOT NULL
);

-- Loan status lookup
CREATE TABLE loan_status_lkp (
    loan_status_code    VARCHAR(20) PRIMARY KEY,
    description         VARCHAR(100) NOT NULL
);

-- Application status lookup
CREATE TABLE application_status_lkp (
    application_status_code VARCHAR(20) PRIMARY KEY,
    description             VARCHAR(100) NOT NULL
);

-- Repayment frequency
CREATE TABLE repayment_frequency_lkp (
    repayment_frequency_code VARCHAR(20) PRIMARY KEY,
    description              VARCHAR(100) NOT NULL
);

-- Risk stage (IFRS 9-like)
CREATE TABLE risk_stage_lkp (
    risk_stage_code     VARCHAR(10) PRIMARY KEY,
    description         VARCHAR(100) NOT NULL
);

-- =========================================================
-- 3. CUSTOMER & ACCOUNT STRUCTURE
-- =========================================================

CREATE TABLE customer (
    customer_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    external_customer_ref   VARCHAR(50),             -- if you have external IDs
    first_name          VARCHAR(50) NOT NULL,
    last_name           VARCHAR(50) NOT NULL,
    date_of_birth       DATE NOT NULL,
    national_id_number  VARCHAR(40),
    email               VARCHAR(100),
    phone_mobile        VARCHAR(30),
    phone_home          VARCHAR(30),
    address_line1       VARCHAR(100),
    address_line2       VARCHAR(100),
    city                VARCHAR(50),
    state_province      VARCHAR(50),
    postal_code         VARCHAR(20),
    country             VARCHAR(50),
    employment_status   VARCHAR(50),
    annual_income       DECIMAL(18,2),
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customer_account (
    account_id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id         BIGINT NOT NULL,
    account_number      VARCHAR(50) NOT NULL UNIQUE,
    account_type        VARCHAR(30) NOT NULL,         -- e.g. "CURRENT", "SAVINGS"
    currency_code       CHAR(3) NOT NULL,
    open_date           DATE NOT NULL,
    close_date          DATE,
    status              VARCHAR(20) NOT NULL,         -- e.g. "ACTIVE", "CLOSED"
    current_balance     DECIMAL(18,2) DEFAULT 0,
    CONSTRAINT fk_acct_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id),
    CONSTRAINT fk_acct_currency FOREIGN KEY (currency_code)
        REFERENCES currency(currency_code)
);

-- =========================================================
-- 4. LOAN PRODUCTS & PRICING RULES
-- =========================================================

CREATE TABLE loan_product (
    product_id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_code        VARCHAR(30) NOT NULL UNIQUE,
    product_name        VARCHAR(100) NOT NULL,
    description         VARCHAR(255),
    currency_code       CHAR(3) NOT NULL,
    min_term_months     INT NOT NULL,
    max_term_months     INT NOT NULL,
    min_amount          DECIMAL(18,2) NOT NULL,
    max_amount          DECIMAL(18,2) NOT NULL,
    base_interest_rate  DECIMAL(5,2) NOT NULL,      -- e.g. 12.50 (%)
    penalty_rate        DECIMAL(5,2),               -- late payment rate
    CONSTRAINT fk_prod_currency FOREIGN KEY (currency_code)
        REFERENCES currency(currency_code)
);

-- =========================================================
-- 5. APPLICATIONS (PRE-LOAN STAGE)
-- =========================================================

CREATE TABLE loan_application (
    application_id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id             BIGINT NOT NULL,
    product_id              BIGINT NOT NULL,
    application_date        DATE NOT NULL,
    requested_amount        DECIMAL(18,2) NOT NULL,
    requested_term_months   INT NOT NULL,
    application_status_code VARCHAR(20) NOT NULL,
    decision_date           DATE,
    approved_amount         DECIMAL(18,2),
    approved_term_months    INT,
    decision_reason_code    VARCHAR(50),           -- e.g. "APPROVED", "DECLINE_DTI"
    channel                 VARCHAR(50),           -- e.g. "BRANCH", "ONLINE"
    remarks                 VARCHAR(255),

    CONSTRAINT fk_app_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id),
    CONSTRAINT fk_app_product FOREIGN KEY (product_id)
        REFERENCES loan_product(product_id),
    CONSTRAINT fk_app_status FOREIGN KEY (application_status_code)
        REFERENCES application_status_lkp(application_status_code)
);

-- =========================================================
-- 6. LOANS (BOOKED ACCOUNTS)
-- =========================================================

CREATE TABLE loan (
    loan_id                 BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    application_id          BIGINT,
    customer_id             BIGINT NOT NULL,
    product_id              BIGINT NOT NULL,
    disbursement_account_id BIGINT,
    loan_number             VARCHAR(50) NOT NULL UNIQUE,
    origination_date        DATE NOT NULL,
    principal_amount        DECIMAL(18,2) NOT NULL,
    term_months             INT NOT NULL,
    interest_rate           DECIMAL(5,2) NOT NULL,
    repayment_frequency_code VARCHAR(20) NOT NULL,  
    currency_code           CHAR(3) NOT NULL,
    maturity_date           DATE,
    loan_status_code        VARCHAR(20) NOT NULL,   -
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_loan_app FOREIGN KEY (application_id)
        REFERENCES loan_application(application_id),
    CONSTRAINT fk_loan_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id),
    CONSTRAINT fk_loan_product FOREIGN KEY (product_id)
        REFERENCES loan_product(product_id),
    CONSTRAINT fk_loan_account FOREIGN KEY (disbursement_account_id)
        REFERENCES customer_account(account_id),
    CONSTRAINT fk_loan_currency FOREIGN KEY (currency_code)
        REFERENCES currency(currency_code),
    CONSTRAINT fk_loan_status FOREIGN KEY (loan_status_code)
        REFERENCES loan_status_lkp(loan_status_code),
    CONSTRAINT fk_loan_freq FOREIGN KEY (repayment_frequency_code)
        REFERENCES repayment_frequency_lkp(repayment_frequency_code)
);

-- =========================================================
-- 7. COLLATERAL
-- =========================================================

CREATE TABLE collateral (
    collateral_id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loan_id             BIGINT NOT NULL,
    collateral_type     VARCHAR(50) NOT NULL,     -- e.g. "PROPERTY", "VEHICLE"
    description         VARCHAR(255),
    appraised_value     DECIMAL(18,2) NOT NULL,
    appraised_date      DATE NOT NULL,
    currency_code       CHAR(3) NOT NULL,
    lien_rank           INT,                      -- 1 = first lien, 2 = second, etc.
    CONSTRAINT fk_coll_loan FOREIGN KEY (loan_id)
        REFERENCES loan(loan_id),
    CONSTRAINT fk_coll_currency FOREIGN KEY (currency_code)
        REFERENCES currency(currency_code)
);

-- =========================================================
-- 8. PAYMENT SCHEDULE & PAYMENTS (CASH FLOWS)
-- =========================================================

CREATE TABLE payment_schedule (
    schedule_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loan_id             BIGINT NOT NULL,
    installment_number  INT NOT NULL,
    due_date            DATE NOT NULL,
    principal_due       DECIMAL(18,2) NOT NULL,
    interest_due        DECIMAL(18,2) NOT NULL,
    fee_due             DECIMAL(18,2) NOT NULL DEFAULT 0,
    total_due           DECIMAL(18,2) NOT NULL,
    schedule_status     VARCHAR(20) NOT NULL,     -- "DUE", "PAID", "PARTIAL", etc.
    CONSTRAINT fk_sched_loan FOREIGN KEY (loan_id)
        REFERENCES loan(loan_id),
    CONSTRAINT uq_sched_loan_inst UNIQUE (loan_id, installment_number)
);

CREATE TABLE payment (
    payment_id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loan_id             BIGINT NOT NULL,
    schedule_id         BIGINT,                  -- nullable if ad-hoc payment
    payment_date        DATE NOT NULL,
    value_date          DATE,                    -- accounting value date
    amount_paid         DECIMAL(18,2) NOT NULL,
    principal_component DECIMAL(18,2) NOT NULL,
    interest_component  DECIMAL(18,2) NOT NULL,
    fee_component       DECIMAL(18,2) NOT NULL DEFAULT 0,
    payment_method      VARCHAR(30),             -- "CASH", "DEBIT ORDER", etc.
    external_ref        VARCHAR(100),

    CONSTRAINT fk_pay_loan FOREIGN KEY (loan_id)
        REFERENCES loan(loan_id),
    CONSTRAINT fk_pay_schedule FOREIGN KEY (schedule_id)
        REFERENCES payment_schedule(schedule_id)
);

-- =========================================================
-- 9. CREDIT BUREAU / EXTERNAL RISK DATA
-- =========================================================

CREATE TABLE credit_bureau_report (
    report_id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id             BIGINT NOT NULL,
    bureau_name             VARCHAR(100) NOT NULL,
    report_date             DATE NOT NULL,
    bureau_score            INT,
    score_band              VARCHAR(50),
    total_outstanding_debt  DECIMAL(18,2),
    total_monthly_obligation DECIMAL(18,2),
    num_open_loans          INT,
    num_defaults            INT,
    worst_status_last_24m   VARCHAR(20),
    raw_json                TEXT,                 -- store full report if needed (JSON string)

    CONSTRAINT fk_bureau_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
);

-- Internal score history (application or behavioral)
CREATE TABLE credit_score_history (
    credit_score_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id         BIGINT NOT NULL,
    loan_id             BIGINT,                  -- optional, for behavioral model
    score_date          DATE NOT NULL,
    score_type          VARCHAR(50) NOT NULL,    -- "APPLICATION", "BEHAVIORAL"
    model_name          VARCHAR(100) NOT NULL,
    score_value         INT NOT NULL,
    probability_of_default DECIMAL(9,6),         -- e.g. 0.034500
    loss_given_default  DECIMAL(9,6),
    exposure_at_default DECIMAL(18,2),
    notes               VARCHAR(255),

    CONSTRAINT fk_cs_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id),
    CONSTRAINT fk_cs_loan FOREIGN KEY (loan_id)
        REFERENCES loan(loan_id)
);

-- =========================================================
-- 10. RISK SNAPSHOTS & PROVISIONS (IFRS 9 / NPL MONITORING)
-- =========================================================

CREATE TABLE loan_risk_snapshot (
    snapshot_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loan_id             BIGINT NOT NULL,
    snapshot_date       DATE NOT NULL,
    days_past_due       INT NOT NULL,
    arrears_bucket      VARCHAR(20),             -- "0", "1-30", "31-60", etc.
    risk_stage_code     VARCHAR(10),             -- FK to risk_stage_lkp
    behavioral_score    INT,
    lifetime_pd         DECIMAL(9,6),
    ecl_amount          DECIMAL(18,2),           -- expected credit loss
    is_nonperforming    BOOLEAN NOT NULL,
    remarks             VARCHAR(255),

    CONSTRAINT fk_rs_loan FOREIGN KEY (loan_id)
        REFERENCES loan(loan_id),
    CONSTRAINT fk_rs_stage FOREIGN KEY (risk_stage_code)
        REFERENCES risk_stage_lkp(risk_stage_code)
);

-- =========================================================
-- 11. USEFUL INDEXES FOR PERFORMANCE / RISK REPORTING
-- =========================================================

CREATE INDEX idx_customer_national_id
    ON customer (national_id_number);

CREATE INDEX idx_loan_customer
    ON loan (customer_id);

CREATE INDEX idx_loan_status
    ON loan (loan_status_code);

CREATE INDEX idx_sched_loan_due_date
    ON payment_schedule (loan_id, due_date);

CREATE INDEX idx_payment_loan_date
    ON payment (loan_id, payment_date);

CREATE INDEX idx_bureau_cust_date
    ON credit_bureau_report (customer_id, report_date);

CREATE INDEX idx_risk_loan_date
    ON loan_risk_snapshot (loan_id, snapshot_date);
