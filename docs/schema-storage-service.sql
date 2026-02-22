-- ===== STORAGE SERVICE SCHEMA =====
-- Tables: storage_buckets, file_objects, file_versions, file_access, file_metadata, deleted_files, file_quotas

CREATE TABLE storage_buckets (
    name VARCHAR(255) PRIMARY KEY,
    region VARCHAR(100) NOT NULL,
    policy VARCHAR(255),
    is_public BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE file_objects (
    id VARCHAR(255) PRIMARY KEY,
    bucket_name VARCHAR(255) NOT NULL,
    object_name VARCHAR(500) NOT NULL,
    url VARCHAR(500) NOT NULL,
    size BIGINT NOT NULL,
    content_type VARCHAR(100) NOT NULL,
    owner_id UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (bucket_name) REFERENCES storage_buckets(name) ON DELETE CASCADE
);

CREATE TABLE file_versions (
    id VARCHAR(255) PRIMARY KEY,
    object_id VARCHAR(255) NOT NULL,
    bucket_name VARCHAR(255) NOT NULL,
    version_number INTEGER NOT NULL,
    size BIGINT NOT NULL,
    etag VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (object_id) REFERENCES file_objects(id) ON DELETE CASCADE,
    FOREIGN KEY (bucket_name) REFERENCES storage_buckets(name) ON DELETE CASCADE
);

CREATE TABLE file_access (
    id UUID PRIMARY KEY,
    object_id VARCHAR(255) NOT NULL,
    user_id UUID NOT NULL,
    access_type VARCHAR(50) NOT NULL,
    accessed_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (object_id) REFERENCES file_objects(id) ON DELETE CASCADE
);

CREATE TABLE file_metadata (
    id VARCHAR(255) PRIMARY KEY,
    object_id VARCHAR(255) NOT NULL UNIQUE,
    metadata JSONB,
    tags VARCHAR(500),
    custom_fields JSONB,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (object_id) REFERENCES file_objects(id) ON DELETE CASCADE
);

CREATE TABLE deleted_files (
    id UUID PRIMARY KEY,
    object_id VARCHAR(255) NOT NULL,
    deleted_by UUID NOT NULL,
    deletion_reason VARCHAR(500),
    original_size BIGINT,
    deleted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE file_quotas (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
    total_quota_bytes BIGINT NOT NULL,
    used_bytes BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ===== INDEXES =====
CREATE INDEX idx_file_objects_bucket_name ON file_objects(bucket_name);
CREATE INDEX idx_file_objects_owner_id ON file_objects(owner_id);
CREATE INDEX idx_file_objects_is_deleted ON file_objects(is_deleted);
CREATE INDEX idx_file_versions_object_id ON file_versions(object_id);
CREATE INDEX idx_file_versions_version_number ON file_versions(version_number);
CREATE INDEX idx_file_access_object_id ON file_access(object_id);
CREATE INDEX idx_file_access_user_id ON file_access(user_id);
CREATE INDEX idx_file_metadata_object_id ON file_metadata(object_id);
CREATE INDEX idx_file_quotas_user_id ON file_quotas(user_id);
