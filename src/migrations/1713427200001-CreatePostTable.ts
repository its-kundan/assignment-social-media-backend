import { MigrationInterface, QueryRunner, Table } from 'typeorm';

export class CreatePostTable1713427200001 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'posts',
        columns: [
          {
            name: 'id',
            type: 'integer',
            isPrimary: true,
            isGenerated: true,
            generationStrategy: 'increment',
          },
          {
            name: 'content',
            type: 'text',
            isNullable: false,
          },
          {
            name: 'authorId',
            type: 'integer',
            isNullable: false,
          },
          {
            name: 'createdAt',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
          {
            name: 'updatedAt',
            type: 'datetime',
            default: 'CURRENT_TIMESTAMP',
          },
        ],
        foreignKeys: [
          {
            columnNames: ['authorId'],
            referencedTableName: 'users',
            referencedColumnNames: ['id'],
            onDelete: 'CASCADE',
          },
        ],
        indices: [
          {
            columnNames: ['authorId', 'createdAt'],
          },
        ],
      }),
      true
    );

    await queryRunner.createTable(
      new Table({
        name: 'posts_hashtags',
        columns: [
          {
            name: 'postId',
            type: 'integer',
            isPrimary: true,
          },
          {
            name: 'hashtagId',
            type: 'integer',
            isPrimary: true,
          },
        ],
        foreignKeys: [
          {
            columnNames: ['postId'],
            referencedTableName: 'posts',
            referencedColumnNames: ['id'],
            onDelete: 'CASCADE',
          },
          {
            columnNames: ['hashtagId'],
            referencedTableName: 'hashtags',
            referencedColumnNames: ['id'],
            onDelete: 'CASCADE',
          },
        ],
      }),
      true
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('posts_hashtags');
    await queryRunner.dropTable('posts');
  }
}