-- =============================================================================
-- CONECTA API Gateway - H2 Database Schema
-- Development Environment
-- =============================================================================

-- Drop tables if they exist (for clean recreation)
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS transaction;
DROP TABLE IF EXISTS outbound_route_configuration;
DROP TABLE IF EXISTS inbound_route_configuration;
DROP TABLE IF EXISTS jwt_configuration;
DROP TABLE IF EXISTS system_configuration;
DROP TABLE IF EXISTS user;

-- =============================================================================
-- USERS TABLE
-- =============================================================================
CREATE TABLE user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMINISTRATOR', 'AUDITOR')),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Index for performance
CREATE INDEX idx_user_username ON user(username);
CREATE INDEX idx_user_active ON user(active);

-- =============================================================================
-- SYSTEM CONFIGURATION TABLE
-- =============================================================================
CREATE TABLE system_configuration (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value VARCHAR(500) NOT NULL,
    description VARCHAR(255),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Index for performance
CREATE INDEX idx_system_config_key ON system_configuration(config_key);
CREATE INDEX idx_system_config_active ON system_configuration(active);

-- =============================================================================
-- JWT CONFIGURATION TABLE
-- =============================================================================
CREATE TABLE jwt_configuration (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    service_key VARCHAR(100) NOT NULL UNIQUE,
    token_secret VARCHAR(500) NOT NULL,
    token_issuer VARCHAR(100) NOT NULL,
    expiration_minutes INTEGER NOT NULL DEFAULT 60,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Index for performance
CREATE INDEX idx_jwt_service_key ON jwt_configuration(service_key);
CREATE INDEX idx_jwt_active ON jwt_configuration(active);

-- =============================================================================
-- INBOUND ROUTE CONFIGURATION TABLE
-- =============================================================================
CREATE TABLE inbound_route_configuration (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    route_key VARCHAR(100) NOT NULL UNIQUE,
    target_service_url VARCHAR(500) NOT NULL,
    target_service_name VARCHAR(100) NOT NULL,
    method VARCHAR(10) NOT NULL CHECK (method IN ('GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'HEAD')),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Index for performance
CREATE INDEX idx_inbound_route_key ON inbound_route_configuration(route_key);
CREATE INDEX idx_inbound_active ON inbound_route_configuration(active);
CREATE INDEX idx_inbound_method ON inbound_route_configuration(method);

-- =============================================================================
-- OUTBOUND ROUTE CONFIGURATION TABLE
-- =============================================================================
CREATE TABLE outbound_route_configuration (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    internal_service_key VARCHAR(100) NOT NULL,
    external_system_key VARCHAR(100) NOT NULL,
    target_external_url VARCHAR(500) NOT NULL,
    jwt_config_id BIGINT NOT NULL,
    method VARCHAR(10) NOT NULL CHECK (method IN ('GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'HEAD')),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (jwt_config_id) REFERENCES jwt_configuration(id)
);

-- Index for performance
CREATE INDEX idx_outbound_internal_key ON outbound_route_configuration(internal_service_key);
CREATE INDEX idx_outbound_external_key ON outbound_route_configuration(external_system_key);
CREATE INDEX idx_outbound_active ON outbound_route_configuration(active);
CREATE INDEX idx_outbound_method ON outbound_route_configuration(method);
CREATE INDEX idx_outbound_jwt_config ON outbound_route_configuration(jwt_config_id);

-- Unique constraint for internal-external-method combination
CREATE UNIQUE INDEX idx_outbound_unique_route ON outbound_route_configuration(internal_service_key, external_system_key, method) WHERE active = TRUE;

-- =============================================================================
-- TRANSACTION TABLE
-- =============================================================================
CREATE TABLE transaction (
    id VARCHAR(50) PRIMARY KEY,
    status VARCHAR(20) NOT NULL CHECK (status IN ('STARTED', 'COMPLETED', 'FAILED', 'ROLLED_BACK')),
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    error_message VARCHAR(1000) NULL
);

-- Index for performance
CREATE INDEX idx_transaction_status ON transaction(status);
CREATE INDEX idx_transaction_start_time ON transaction(start_time);

-- =============================================================================
-- AUDIT LOG TABLE
-- =============================================================================
CREATE TABLE audit_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(50) NOT NULL,
    source_system VARCHAR(100) NOT NULL,
    target_system VARCHAR(100) NOT NULL,
    http_method VARCHAR(10) NOT NULL,
    request_path VARCHAR(500) NOT NULL,
    request_headers CLOB,
    request_body CLOB,
    response_status INTEGER,
    response_headers CLOB,
    response_body CLOB,
    processing_time BIGINT,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_id BIGINT NULL,
    FOREIGN KEY (transaction_id) REFERENCES transaction(id),
    FOREIGN KEY (user_id) REFERENCES user(id)
);

-- Index for performance and queries
CREATE INDEX idx_audit_transaction_id ON audit_log(transaction_id);
CREATE INDEX idx_audit_timestamp ON audit_log(timestamp);
CREATE INDEX idx_audit_source_system ON audit_log(source_system);
CREATE INDEX idx_audit_target_system ON audit_log(target_system);
CREATE INDEX idx_audit_http_method ON audit_log(http_method);
CREATE INDEX idx_audit_response_status ON audit_log(response_status);
CREATE INDEX idx_audit_user_id ON audit_log(user_id);

-- =============================================================================
-- INITIAL DATA
-- =============================================================================

-- Default admin user (password: admin123 - should be changed in production)
INSERT INTO user (username, password, role, active) VALUES 
('admin', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', 'ADMINISTRATOR', TRUE);

-- Default auditor user (password: auditor123 - should be changed in production)
INSERT INTO user (username, password, role, active) VALUES 
('auditor', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', 'AUDITOR', TRUE);

-- System configuration defaults
INSERT INTO system_configuration (config_key, config_value, description) VALUES 
('jwt.default.expiration.minutes', '60', 'Default JWT token expiration time in minutes'),
('gateway.max.concurrent.requests', '1000', 'Maximum concurrent requests allowed'),
('gateway.request.timeout.seconds', '30', 'Request timeout in seconds'),
('gateway.retry.attempts', '3', 'Number of retry attempts for failed requests'),
('audit.retention.days', '365', 'Audit log retention period in days'),
('cache.configuration.ttl.seconds', '300', 'Configuration cache TTL in seconds');

-- Example JWT configurations
INSERT INTO jwt_configuration (service_key, token_secret, token_issuer, expiration_minutes) VALUES 
('payment-gateway', 'payment-secret-key-2024', 'conecta-gateway', 30),
('crm-system', 'crm-secret-key-2024', 'conecta-gateway', 60),
('external-api', 'external-api-secret-2024', 'conecta-gateway', 120);

-- Example inbound route configurations
INSERT INTO inbound_route_configuration (route_key, target_service_url, target_service_name, method) VALUES 
('customers', 'http://customer-service:8080/api/customers', 'Customer Service', 'GET'),
('customers', 'http://customer-service:8080/api/customers', 'Customer Service', 'POST'),
('orders', 'http://order-service:8080/api/orders', 'Order Service', 'GET'),
('orders', 'http://order-service:8080/api/orders', 'Order Service', 'POST'),
('inventory', 'http://inventory-service:8080/api/inventory', 'Inventory Service', 'GET');

-- Example outbound route configurations
INSERT INTO outbound_route_configuration (internal_service_key, external_system_key, target_external_url, jwt_config_id, method) VALUES 
('customer-service', 'payment-gateway', 'https://api.paymentgateway.com/v1/payments', 1, 'POST'),
('customer-service', 'crm-system', 'https://api.crmsystem.com/v2/customers', 2, 'GET'),
('customer-service', 'crm-system', 'https://api.crmsystem.com/v2/customers', 2, 'POST'),
('order-service', 'payment-gateway', 'https://api.paymentgateway.com/v1/payments', 1, 'POST'),
('inventory-service', 'external-api', 'https://api.external-supplier.com/v1/stock', 3, 'GET');

-- =============================================================================
-- COMMENTS AND DOCUMENTATION
-- =============================================================================

COMMENT ON TABLE user IS 'Users table for UI authentication with role-based access control';
COMMENT ON TABLE system_configuration IS 'System-wide configuration parameters that can be modified without redeployment';
COMMENT ON TABLE jwt_configuration IS 'JWT configuration for different external systems';
COMMENT ON TABLE inbound_route_configuration IS 'Routing configuration for incoming requests from external systems';
COMMENT ON TABLE outbound_route_configuration IS 'Routing configuration for outgoing requests to external systems';
COMMENT ON TABLE transaction IS 'Transaction control for gateway operations';
COMMENT ON TABLE audit_log IS 'Complete audit trail of all transactions through the gateway';

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

-- Verify table creation
SELECT TABLE_NAME, TABLE_TYPE 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'PUBLIC' 
ORDER BY TABLE_NAME;

-- Verify initial data
SELECT 'Users' as TABLE_NAME, COUNT(*) as RECORD_COUNT FROM user
UNION ALL
SELECT 'System Config', COUNT(*) FROM system_configuration
UNION ALL
SELECT 'JWT Config', COUNT(*) FROM jwt_configuration
UNION ALL
SELECT 'Inbound Routes', COUNT(*) FROM inbound_route_configuration
UNION ALL
SELECT 'Outbound Routes', COUNT(*) FROM outbound_route_configuration;

-- =============================================================================
-- END OF SCRIPT
-- =============================================================================