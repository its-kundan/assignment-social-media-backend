import { Request, Response } from 'express';
import { AppDataSource } from '../data-source';
import { Post } from '../entities/Post';
import { User } from '../entities/User';
import { Hashtag } from '../entities/Hastag';
import { Like } from '../entities/Like';
import { Follow } from '../entities/Follow';

export class PostController {
  private postRepository = AppDataSource.getRepository(Post);
  private userRepository = AppDataSource.getRepository(User);
  private hashtagRepository = AppDataSource.getRepository(Hashtag);
  private likeRepository = AppDataSource.getRepository(Like);
  private followRepository = AppDataSource.getRepository(Follow);

  async getAllPosts(req: Request, res: Response) {
    try {
      const posts = await this.postRepository.find({
        relations: ['author', 'hashtags', 'likes'],
        order: { createdAt: 'DESC' },
      });
      res.json(posts);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching posts', error });
    }
  }

  async getPostById(req: Request, res: Response) {
    try {
      const post = await this.postRepository.findOne({
        where: { id: parseInt(req.params.id) },
        relations: ['author', 'hashtags', 'likes'],
      });
      if (!post) {
        return res.status(404).json({ message: 'Post not found' });
      }
      res.json(post);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching post', error });
    }
  }

  async createPost(req: Request, res: Response) {
    try {
      const { content, hashtagTags } = req.body;
      const user = await this.userRepository.findOneBy({ id: req.body.authorId });
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }

      const post = this.postRepository.create({ content, author: user });
      if (hashtagTags && hashtagTags.length > 0) {
        const hashtags = await Promise.all(
          hashtagTags.map(async (tag: string) => {
            let hashtag = await this.hashtagRepository.findOneBy({ tag });
            if (!hashtag) {
              hashtag = this.hashtagRepository.create({ tag });
              await this.hashtagRepository.save(hashtag);
            }
            return hashtag;
          })
        );
        post.hashtags = hashtags;
      }

      const result = await this.postRepository.save(post);
      res.status(201).json(result);
    } catch (error) {
      res.status(500).json({ message: 'Error creating post', error });
    }
  }

  async updatePost(req: Request, res: Response) {
    try {
      const post = await this.postRepository.findOneBy({ id: parseInt(req.params.id) });
      if (!post) {
        return res.status(404).json({ message: 'Post not found' });
      }
      this.postRepository.merge(post, req.body);
      const result = await this.postRepository.save(post);
      res.json(result);
    } catch (error) {
      res.status(500).json({ message: 'Error updating post', error });
    }
  }

  async deletePost(req: Request, res: Response) {
    try {
      const result = await this.postRepository.delete(parseInt(req.params.id));
      if (result.affected === 0) {
        return res.status(404).json({ message: 'Post not found' });
      }
      res.status(204).send();
    } catch (error) {
      res.status(500).json({ message: 'Error deleting post', error });
    }
  }

  async getFeed(req: Request, res: Response) {
    try {
      const userId = parseInt(req.query.userId as string);
      const limit = parseInt(req.query.limit as string) || 10;
      const offset = parseInt(req.query.offset as string) || 0;

      const followedUsers = await this.followRepository.find({
        where: { follower: { id: userId } },
        relations: ['followed'],
      });

      const followedUserIds = followedUsers.map((follow) => follow.followed.id);

      const posts = await this.postRepository
        .createQueryBuilder('post')
        .leftJoinAndSelect('post.author', 'author')
        .leftJoinAndSelect('post.hashtags', 'hashtags')
        .leftJoinAndSelect('post.likes', 'likes')
        .where('post.authorId IN (:...followedUserIds)', { followedUserIds })
        .orderBy('post.createdAt', 'DESC')
        .take(limit)
        .skip(offset)
        .getMany();

      res.json(posts);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching feed', error });
    }
  }

  async getPostsByHashtag(req: Request, res: Response) {
    try {
      const tag = req.params.tag.toLowerCase();
      const limit = parseInt(req.query.limit as string) || 10;
      const offset = parseInt(req.query.offset as string) || 0;

      const posts = await this.postRepository
        .createQueryBuilder('post')
        .leftJoinAndSelect('post.author', 'author')
        .leftJoinAndSelect('post.hashtags', 'hashtags')
        .leftJoinAndSelect('post.likes', 'likes')
        .where('hashtags.tag = :tag', { tag })
        .orderBy('post.createdAt', 'DESC')
        .take(limit)
        .skip(offset)
        .getMany();

      res.json(posts);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching posts by hashtag', error });
    }
  }
}