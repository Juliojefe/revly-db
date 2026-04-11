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
    content VARCHAR(255),
    user_id INT,
    chat_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (chat_id) REFERENCES chat(chat_id) ON DELETE CASCADE
);

CREATE TABLE message_image (
    id SERIAL PRIMARY KEY,
    image_url VARCHAR(255) NOT NULL,
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
