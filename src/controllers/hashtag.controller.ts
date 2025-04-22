import { Request, Response } from 'express';
import { AppDataSource } from '../data-source';
import { Hashtag } from '../entities/Hashtag';

export class HashtagController {
  private hashtagRepository = AppDataSource.getRepository(Hashtag);

  async getAllHashtags(req: Request, res: Response) {
    try {
      const hashtags = await this.hashtagRepository.find({
        relations: ['posts'],
      });
      res.json(hashtags);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching hashtags', error });
    }
  }

  async getHashtagById(req: Request, res: Response) {
    try {
      const hashtag = await this.hashtagRepository.findOne({
        where: { id: parseInt(req.params.id) },
        relations: ['posts'],
      });
      if (!hashtag) {
        return res.status(404).json({ message: 'Hashtag not found' });
      }
      res.json(hashtag);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching hashtag', error });
    }
  }

  async createHashtag(req: Request, res: Response) {
    try {
      const { tag } = req.body;
      const existingHashtag = await this.hashtagRepository.findOneBy({ tag });
      if (existingHashtag) {
        return res.status(400).json({ message: 'Hashtag already exists' });
      }
      const hashtag = this.hashtagRepository.create({ tag });
      const result = await this.hashtagRepository.save(hashtag);
      res.status(201).json(result);
    } catch (error) {
      res.status(500).json({ message: 'Error creating hashtag', error });
    }
  }

  async updateHashtag(req: Request, res: Response) {
    try {
      const hashtag = await this.hashtagRepository.findOneBy({ id: parseInt(req.params.id) });
      if (!hashtag) {
        return res.status(404).json({ message: 'Hashtag not found' });
      }
      this.hashtagRepository.merge(hashtag, req.body);
      const result = await this.hashtagRepository.save(hashtag);
      res.json(result);
    } catch (error) {
      res.status(500).json({ message: 'Error updating hashtag', error });
    }
  }

  async deleteHashtag(req: Request, res: Response) {
    try {
      const result = await this.hashtagRepository.delete(parseInt(req.params.id));
      if (result.affected === 0) {
        return res.status(404).json({ message: 'Hashtag not found' });
      }
      res.status(204).send();
    } catch (error) {
      res.status(500).json({ message: 'Error deleting hashtag', error });
    }
  }
}