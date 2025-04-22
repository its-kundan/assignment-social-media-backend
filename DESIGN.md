# Design Document

## Database Schema and Entity Relationships

### Entities and Relationships
- **User**
  - Fields: `id` (UUID, primary), `username` (varchar, unique), `email` (varchar, unique), `createdAt` (timestamp), `updatedAt` (timestamp)
  - Relationships:
    - One-to-Many: Posts (author)
    - Many-to-Many: Follows (followers and following)
    - One-to-Many: Likes (user who liked)
- **Post**
  - Fields: `id` (UUID, primary), `content` (text), `createdAt` (timestamp), `updatedAt` (timestamp), `authorId` (UUID, foreign key to User)
  - Relationships:
    - Many-to-One: User (author)
    - One-to-Many: Likes
    - Many-to-Many: Hashtags
- **Like**
  - Fields: `id` (UUID, primary), `userId` (UUID, foreign key to User), `postId` (UUID, foreign key to Post), `createdAt` (timestamp)
  - Relationships:
    - Many-to-One: User
    - Many-to-One: Post
- **Follow**
  - Fields: `id` (UUID, primary), `followerId` (UUID, foreign key to User), `followingId` (UUID, foreign key to User), `createdAt` (timestamp)
  - Relationships:
    - Many-to-One: User (follower)
    - Many-to-One: User (following)
- **Hashtag**
  - Fields: `id` (UUID, primary), `tag` (varchar, unique), `createdAt` (timestamp)
  - Relationships:
    - Many-to-Many: Posts

### Indexing Strategy
- **User**
  - Unique index on `username` and `email` for quick lookups and uniqueness enforcement.
- **Post**
  - Index on `authorId` for efficient feed queries.
  - Index on `createdAt` for sorting posts in the feed.
- **Like**
  - Composite index on `userId` and `postId` for quick like/unlike operations and preventing duplicates.
  - Index on `postId` for counting likes per post.
- **Follow**
  - Composite index on `followerId` and `followingId` for quick follow/unfollow operations and preventing duplicates.
  - Index on `followingId` for fetching followers.
- **Hashtag**
  - Unique index on `tag` for case-insensitive lookups.
  - Index on `postId` in the join table for fetching posts by hashtag.

### Scalability Considerations
- **Pagination**: All list endpoints (`/api/feed`, `/api/posts/hashtag/:tag`, `/api/users/:id/followers`, `/api/users/:id/activity`) use `limit` and `offset` for pagination to handle large datasets.
- **Efficient Queries**: Use TypeORM's query builder with proper joins and indexes to minimize database load.
- **Caching**: Future implementation could include Redis for caching frequently accessed data like user feeds or hashtag posts.
- **Database**: SQLite is used for simplicity, but for production, a distributed database like PostgreSQL or a sharded MySQL setup would be considered.

### Design Considerations
- **Data Integrity**: Joi validations ensure input data meets requirements before hitting the database.
- **Error Handling**: Consistent error responses with appropriate HTTP status codes.
- **TypeORM Migrations**: Used instead of `synchronize: true` for controlled schema changes.
- **Testing**: Comprehensive `test.sh` script covers all CRUD operations and special endpoints, ensuring functionality.