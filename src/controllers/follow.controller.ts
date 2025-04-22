import { Request, Response } from 'express';
import { AppDataSource } from '../data-source';
import { Follow } from '../entities/Follow';
import { User } from '../entities/User';

export class FollowController {
  private followRepository = AppDataSource.getRepository(Follow);
  private userRepository = AppDataSource.getRepository(User);

  async getAllFollows(req: Request, res: Response) {
    try {
      const follows = await this.followRepository.find({
        relations: ['follower', 'followed'],
      });
      res.json(follows);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching follows', error });
    }
  }

  async getFollowById(req: Request, res: Response) {
    try {
      const follow = await this.followRepository.findOne({
        where: { id: parseInt(req.params.id) },
        relations: ['follower', 'followed'],
      });
      if (!follow) {
        return res.status(404).json({ message: 'Follow not found' });
      }
      res.json(follow);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching follow', error });
    }
  }

  async createFollow(req: Request, res: Response) {
    try {
      const { followerId, followedId } = req.body;
      const follower = await this.userRepository.findOneBy({ id: followerId });
      const followed = await this.userRepository.findOneBy({ id: followedId });

      if (!follower || !followed) {
        return res.status(404).json({ message: 'User not found' });
      }

      if (followerId === followedId) {
        return res.status(400).json({ message: 'Cannot follow yourself' });
      }

      const existingFollow = await this.followRepository.findOneBy({
        follower: { id: followerId },
        followed: { id: followedId },
      });
      if (existingFollow) {
        return res.status(400).json({ message: 'Already following this user' });
      }

      const follow = this.followRepository.create({ follower, followed });
      const result = await this.followRepository.save(follow);
      res.status(201).json(result);
    } catch (error) {
      res.status(500).json({ message: 'Error creating follow', error });
    }
  }

  async deleteFollow(req: Request, res: Response) {
    try {
      const result = await this.followRepository.delete(parseInt(req.params.id));
      if (result.affected === 0) {
        return res.status(404).json({ message: 'Follow not found' });
      }
      res.status(204).send();
    } catch (error) {
      res.status(500).json({ message: 'Error deleting follow', error });
    }
  }

  async getFollowers(req: Request, res: Response) {
    try {
      const userId = parseInt(req.params.id);
      const limit = parseInt(req.query.limit as string) || 10;
      const offset = parseInt(req.query.offset as string) || 0;

      const followers = await this.followRepository
        .createQueryBuilder('follow')
        .leftJoinAndSelect('follow.follower', 'follower')
        .where('follow.followedId = :userId', { userId })
        .orderBy('follow.createdAt', 'DESC')
        .take(limit)
        .skip(offset)
        .getMany();

      const totalFollowers = await this.followRepository.count({ where: { followed: { id: userId } } });

      res.json({ followers, totalFollowers });
    } catch (error) {
      res.status(500).json({ message: 'Error fetching followers', error });
    }
  }
}