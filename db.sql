CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255),
    profile_pic VARCHAR(255),
    google_id VARCHAR(255),
    biography VARCHAR(150)
);

CREATE TABLE post (
    post_id SERIAL PRIMARY KEY,
    description VARCHAR(3000) NOT NULL,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description_embedding VECTOR(1536),
    embedding_updated_at TIMESTAMPTZ,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE TABLE comment (
    comment_id SERIAL PRIMARY KEY,
    content VARCHAR(3000) NOT NULL,
    user_id INT,
    post_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE
);

CREATE TABLE post_image (
    id SERIAL PRIMARY KEY,
    image_url VARCHAR(255) NOT NULL,
    post_id INT,
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE
);

CREATE TABLE comment_image (
    id SERIAL PRIMARY KEY,
    image_url VARCHAR(255) NOT NULL,
    comment_id INT,
    FOREIGN KEY (comment_id) REFERENCES comment(comment_id) ON DELETE CASCADE
);

CREATE TABLE chat (
    chat_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_chat (
    chat_id INT,
    user_id INT,
    unread_count INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (chat_id) REFERENCES chat(chat_id) ON DELETE CASCADE,
    CONSTRAINT unique_user_chat UNIQUE (chat_id, user_id)
);

CREATE TABLE message (
    message_id SERIAL PRIMARY KEY,
    content TEXT,
    user_id INT,
    chat_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (chat_id) REFERENCES chat(chat_id) ON DELETE CASCADE
);

CREATE TABLE message_image (
    id SERIAL PRIMARY KEY,
    image_url TEXT NOT NULL,
    message_id INT,
    FOREIGN KEY (message_id) REFERENCES message(message_id) ON DELETE CASCADE
);

CREATE TABLE follow (
    follower_id INT,
    followed_id INT,
    FOREIGN KEY (follower_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (followed_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT unique_follow UNIQUE (follower_id, followed_id)
);

CREATE TABLE save_post (
    user_id INT,
    post_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE,
    CONSTRAINT unique_save UNIQUE (user_id, post_id)
);

CREATE TABLE like_post (
    user_id INT,
    post_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE,
    CONSTRAINT unique_like UNIQUE (user_id, post_id)
);

CREATE TABLE user_roles (
    user_id INT PRIMARY KEY,
    isadmin BOOLEAN NOT NULL DEFAULT FALSE,
    ismechanic BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE refresh_tokens (
    id SERIAL PRIMARY KEY,
    token VARCHAR(255) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    expiry_date TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE tag (
    tag_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tag_name VARCHAR(64) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_tag_tag_name UNIQUE (tag_name),
    CONSTRAINT chk_tag_tag_name_format CHECK (tag_name ~ '^[a-z0-9_]{1,64}$')
);

CREATE TABLE post_tag (
    post_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (post_id, tag_id),
    CONSTRAINT fk_post_tag_post FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE,
    CONSTRAINT fk_post_tag_tag FOREIGN KEY (tag_id) REFERENCES tag(tag_id) ON DELETE CASCADE
);

CREATE TABLE businesses (
    business_id SERIAL PRIMARY KEY,
    address VARCHAR(255),
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION
);

CREATE TABLE user_businesses (
    user_id INT NOT NULL,
    business_id INT NOT NULL,
    PRIMARY KEY (user_id, business_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE
);

CREATE TABLE review (
    review_id SERIAL PRIMARY KEY,
    reviewer_id INT NOT NULL,
    mechanic_id INT NOT NULL,
    business_id INT,
    rating DOUBLE PRECISION NOT NULL CHECK (rating >= 1 AND rating <= 5),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reviewer_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (mechanic_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE SET NULL,
    CONSTRAINT unique_reviewer_mechanic UNIQUE (reviewer_id, mechanic_id)
);

CREATE TABLE review_image (
    id SERIAL PRIMARY KEY,
    image_url VARCHAR(255) NOT NULL,
    review_id INT,
    FOREIGN KEY (review_id) REFERENCES review(review_id) ON DELETE CASCADE
);

CREATE TABLE review_response (
    response_id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    user_id INT,
    review_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (review_id) REFERENCES review(review_id) ON DELETE CASCADE
);

CREATE TABLE review_response_image (
    id SERIAL PRIMARY KEY,
    image_url VARCHAR(255) NOT NULL,
    response_id INT,
    FOREIGN KEY (response_id) REFERENCES review_response(response_id) ON DELETE CASCADE
);

--  predefined reasons have been inserted manually
CREATE TABLE report_reason (
    reason_id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE report (
    report_id SERIAL PRIMARY KEY,
    reporter_id INT NOT NULL,
    entity_type VARCHAR(30) NOT NULL,
    entity_id INT NOT NULL,
    explanation TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_by INT,
    admin_explanation TEXT,
    reviewed_at TIMESTAMP,
    FOREIGN KEY (reporter_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_by) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT unique_reporter_entity UNIQUE (reporter_id, entity_type, entity_id),
    CONSTRAINT chk_valid_status CHECK (status IN ('PENDING', 'IN_REVIEW', 'RESOLVED', 'CLOSED', 'DISMISSED')),
    CONSTRAINT chk_valid_entity_type CHECK (entity_type IN (
        'USER',
        'POST',
        'COMMENT',
        'REVIEW',
        'MESSAGE',
        'REVIEW_RESPONSE'
    ))
);

-- multiple reasons per report
CREATE TABLE report_report_reason (
    report_id INT NOT NULL,
    reason_id INT NOT NULL,
    PRIMARY KEY (report_id, reason_id),
    FOREIGN KEY (report_id) REFERENCES report(report_id) ON DELETE CASCADE,
    FOREIGN KEY (reason_id) REFERENCES report_reason(reason_id) ON DELETE RESTRICT
);

CREATE INDEX idx_report_status ON report(status);
CREATE INDEX idx_report_reporter_id ON report(reporter_id);
CREATE INDEX idx_report_reporter_status ON report(reporter_id, status);
CREATE INDEX idx_report_entity_type_entity_id ON report(entity_type, entity_id);
CREATE INDEX idx_report_created_at ON report(created_at DESC);
CREATE INDEX idx_report_reviewed_by ON report(reviewed_by);
CREATE INDEX idx_report_report_reason_report_id ON report_report_reason(report_id);
CREATE INDEX idx_report_report_reason_reason_id ON report_report_reason(reason_id);
CREATE INDEX idx_post_created_at ON post(created_at DESC);
CREATE INDEX idx_post_user_id ON post(user_id);
CREATE INDEX idx_post_embedding_hnsw ON post USING hnsw (description_embedding vector_cosine_ops) WHERE description_embedding IS NOT NULL;
CREATE INDEX idx_like_post_post_id ON like_post(post_id);
CREATE INDEX idx_like_post_user_id ON like_post(user_id);
CREATE INDEX idx_save_post_post_id ON save_post(post_id);
CREATE INDEX idx_save_post_user_id ON save_post(user_id);
CREATE INDEX idx_follow_follower_id ON follow(follower_id);
CREATE INDEX idx_follow_followed_id ON follow(followed_id);
CREATE INDEX idx_post_tag_tag_id_post_id ON post_tag(tag_id, post_id);
CREATE INDEX idx_post_image_post_id ON post_image(post_id);
CREATE INDEX idx_user_businesses_user_id ON user_businesses(user_id);
CREATE INDEX idx_user_businesses_business_id ON user_businesses(business_id);
CREATE INDEX idx_review_mechanic_id ON review(mechanic_id);
CREATE INDEX idx_review_reviewer_id ON review(reviewer_id);
CREATE INDEX idx_review_created_at ON review(created_at DESC);
CREATE INDEX idx_review_business_id ON review(business_id);
CREATE INDEX idx_review_image_review_id ON review_image(review_id);
CREATE INDEX idx_review_response_review_id ON review_response(review_id);
CREATE INDEX idx_review_response_created_at ON review_response(created_at DESC);
