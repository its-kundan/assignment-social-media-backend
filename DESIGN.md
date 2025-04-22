# Design Document

## Database Schema and Entity Relationships

### Entities
1. **User**
   - Columns: `id` (PK), `firstName`, `lastName`, `email` (unique), `createdAt`, `updatedAt`
   - Relationships:
     - One-to-Many with `Post` (author)
     - One-to-Many with `Like` (user)
     - Many-to-Many with `Follow` (follower and followed)
   - Indexes:
     - Unique index on `email`
     - Index on `createdAt` for sorting

2. **Post**
   - Columns: `id` (PK), `content`, `authorId` (FK), `createdAt`, `updatedAt`
   - Relationships:
     - Many-to-One with `User` (author)
     - One-to-Many with `Like` (post)
     - Many-to-Many with `Hashtag`
   - Indexes:
     - Composite index on `authorId`, `createdAt` for feed queries
     - Index on `createdAt` for sorting

3. **Like**
   - Columns: `id` (PK), `userId` (FK), `postId` (FK), `createdAt`
   - Relationships:
     - Many-to-One with `User` (user)
     - Many-to-One with `Post` (post)
   - Indexes:
     - Unique composite index on `userId`, `postId` to prevent duplicate likes
     - Index on `createdAt` for activity queries

4. **Follow**
   - Columns: `id` (PK), `followerId` (FK), `followedId` (FK), `createdAt`
   - Relationships:
     - Many-to-One with `User` (follower)
     - Many-to-One with `User` (followed)
   - Indexes:
     - Unique composite index on `followerId`, `followedId` to prevent duplicate follows
     - Index on `createdAt` for sorting followers

5. **Hashtag**
   - Columns: `id` (PK), `tag` (unique), `createdAt`
   - Relationships:
     - Many-to-Many with `Post`
   - Indexes:
     - Unique index on `tag`
     - Index on `createdAt` for sorting

### Relationships
- **User ↔ Post**: One-to-Many (one user can have many posts, each post has one author)
- **User ↔ Like**: One-to-Many (one user can have many likes, each like belongs to one user)
- **Post ↔ Like**: One-to-Many (one post can have many likes, each like belongs to one post)
- **User ↔ Follow**: Many-to-Many (self-referential through `Follow` entity)
- **Post ↔ Hashtag**: Many-to-Many (through join table `posts_hashtags`)

## Indexing Strategy
- **Users**: 
  - Unique index on `email` for fast lookups and to enforce uniqueness.
  - Index on `createdAt` for sorting in activity feeds.
- **Posts**: 
  - Composite index on `authorId`, `createdAt` for efficient feed queries.
  - Index on `createdAt` for chronological sorting.
- **Likes**: 
  - Unique composite index on `userId`, `postId` to prevent duplicate likes.
  - Index on `createdAt` for activity history queries.
- **Follows**: 
  - Unique composite index on `followerId`, `followedId` to prevent duplicate follows.
  - Index on `createdAt` for sorting followers by follow date.
- **Hashtags**: 
  - Unique index on `tag` for fast lookups and case-insensitive searches.
  - Index on `createdAt` for sorting.

## Scalability Considerations
- **Database Optimization**:
  - Indexes are designed to optimize common queries (feed, hashtag searches, follower lists).
  - Foreign keys with `ON DELETE CASCADE` ensure data integrity during deletions.
  - Pagination is implemented for all list endpoints to handle large datasets.
- **Caching**:
  - Consider adding Redis for caching frequently accessed data (e.g., user feeds, hashtag posts).
  - Cache user profiles and post metadata to reduce database load.
- **Load Balancing**:
  - The API is stateless, making it suitable for horizontal scaling with a load balancer.
  - Use environment variables (via `dotenv`) for configuration to support multiple instances.
- **Query Optimization**:
  - Use TypeORM's query builder for complex queries to avoid N+1 problems.
  - Preload relations where necessary to reduce query overhead.
- **Rate Limiting**:
  - Implement rate limiting on endpoints to prevent abuse (not implemented in code but recommended).
- **Background Jobs**:
  - For heavy operations (e.g., processing hashtag updates), consider using a job queue like Bull.

## Other Design Considerations
- **Validation**:
  - Joi is used for input validation to ensure data integrity.
  - Custom error messages improve user experience.
- **Error Handling**:
  - Consistent error responses with meaningful messages.
  - HTTP status codes follow REST conventions (e.g., 201 for creation, 404 for not found).
- **Testing**:
  - The `test.sh` script provides comprehensive testing for all CRUD operations and special endpoints.
  - Interactive interface allows manual testing for debugging.
- **Security**:
  - Input validation prevents injection attacks.
  - Unique constraints on `Like` and `Follow` prevent duplicate actions.
  - Future improvements could include JWT authentication for user-specific actions.

This design ensures a robust, scalable, and maintainable backend for the social media platform.