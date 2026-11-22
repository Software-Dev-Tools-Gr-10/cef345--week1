-- Event Ticketing and Check-in System
-- Individual Week 5 schema draft by Luma Chrisparr Ngale Jomia (FE25A114)
-- The group has not selected a database engine yet. This uses common SQL types
-- and constraints; identity/auto-increment syntax may need small engine changes.

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    display_name VARCHAR(160) NOT NULL,
    email_or_phone VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roles (
    id INTEGER PRIMARY KEY,
    name VARCHAR(40) NOT NULL UNIQUE,
    CONSTRAINT chk_roles_name CHECK (name IN ('Organizer', 'Check-in staff', 'System administrator'))
);

CREATE TABLE user_roles (
    user_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT
);

CREATE TABLE events (
    id INTEGER PRIMARY KEY,
    organizer_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    venue VARCHAR(255) NOT NULL,
    starts_at TIMESTAMP NOT NULL,
    ends_at TIMESTAMP NOT NULL,
    capacity INTEGER NOT NULL,
    registration_deadline TIMESTAMP NOT NULL,
    ticket_price_xaf INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    FOREIGN KEY (organizer_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT chk_events_capacity CHECK (capacity > 0),
    CONSTRAINT chk_events_price CHECK (ticket_price_xaf >= 0),
    CONSTRAINT chk_events_time CHECK (ends_at > starts_at),
    CONSTRAINT chk_events_status CHECK (status IN ('draft', 'published', 'closed', 'cancelled'))
);

CREATE TABLE registrations (
    id INTEGER PRIMARY KEY,
    event_id INTEGER NOT NULL,
    attendee_name VARCHAR(160) NOT NULL,
    contact_value VARCHAR(255) NOT NULL,
    normalized_contact VARCHAR(255) NOT NULL,
    payment_status VARCHAR(10) NOT NULL DEFAULT 'unpaid',
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE RESTRICT,
    CONSTRAINT uq_registration_event_contact UNIQUE (event_id, normalized_contact),
    CONSTRAINT chk_registration_payment CHECK (payment_status IN ('unpaid', 'paid'))
);

CREATE TABLE tickets (
    id INTEGER PRIMARY KEY,
    registration_id INTEGER NOT NULL UNIQUE,
    ticket_identifier VARCHAR(80) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'valid',
    issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (registration_id) REFERENCES registrations(id) ON DELETE RESTRICT,
    CONSTRAINT chk_ticket_status CHECK (status IN ('valid', 'cancelled'))
);

CREATE TABLE payments (
    id INTEGER PRIMARY KEY,
    registration_id INTEGER NOT NULL,
    recorded_by_user_id INTEGER NOT NULL,
    amount_xaf INTEGER NOT NULL,
    payment_method VARCHAR(80) NOT NULL,
    recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (registration_id) REFERENCES registrations(id) ON DELETE RESTRICT,
    FOREIGN KEY (recorded_by_user_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT chk_payment_amount CHECK (amount_xaf >= 0)
);

CREATE TABLE check_ins (
    id INTEGER PRIMARY KEY,
    registration_id INTEGER NOT NULL UNIQUE,
    staff_user_id INTEGER NOT NULL,
    checked_in_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (registration_id) REFERENCES registrations(id) ON DELETE RESTRICT,
    FOREIGN KEY (staff_user_id) REFERENCES users(id) ON DELETE RESTRICT
);

CREATE TABLE event_updates (
    id INTEGER PRIMARY KEY,
    event_id INTEGER NOT NULL,
    published_by_user_id INTEGER NOT NULL,
    message TEXT NOT NULL,
    published_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE RESTRICT,
    FOREIGN KEY (published_by_user_id) REFERENCES users(id) ON DELETE RESTRICT
);

CREATE INDEX idx_events_status_start ON events(status, starts_at);
CREATE INDEX idx_registrations_event ON registrations(event_id);
CREATE INDEX idx_tickets_identifier ON tickets(ticket_identifier);
CREATE INDEX idx_payments_registration ON payments(registration_id);
CREATE INDEX idx_event_updates_event_time ON event_updates(event_id, published_at);
