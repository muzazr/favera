// src/controllers/goalController.js
const goalService = require('../services/goalService');
const { sendError } = require('../utils/response');

class GoalController {
  async getGoals(req, res) {
    try {
      const familyId = req.user.family_id;
      const limit = parseInt(req.query.limit, 10) || 20;
      const cursor = req.query.cursor || null;

      if (!familyId) {
        return sendError(res, 403, 'FORBIDDEN', 'User belum memiliki ruang keluarga');
      }

      const result = await goalService.getGoals({ familyId, cursor, limit });
      return res.status(200).json(result);
    } catch (err) {
      return sendError(res, 500, 'INTERNAL_SERVER_ERROR', err.message);
    }
  }

  async createGoal(req, res) {
    try {
      const userId = req.user.id;
      const familyId = req.user.family_id;

      if (!familyId) {
        return sendError(res, 403, 'FORBIDDEN', 'User belum memiliki ruang keluarga');
      }

      const createdGoal = await goalService.createGoal({
        userId,
        familyId,
        data: req.body
      });

      return res.status(201).json(createdGoal);
    } catch (err) {
      return sendError(res, 500, 'INTERNAL_SERVER_ERROR', err.message);
    }
  }

  async getGoalById(req, res) {
    try {
      const { goal_id } = req.params;
      const familyId = req.user.family_id;

      const goal = await goalService.getGoalById({ goalId: goal_id, familyId });
      if (!goal) {
        return sendError(res, 404, 'NOT_FOUND', 'Goal tidak ditemukan');
      }

      return res.status(200).json(goal);
    } catch (err) {
      return sendError(res, 500, 'INTERNAL_SERVER_ERROR', err.message);
    }
  }

  async updateGoal(req, res) {
    try {
      const { goal_id } = req.params;
      const userId = req.user.id;
      const familyId = req.user.family_id;

      const updated = await goalService.updateGoal({
        goalId: goal_id,
        userId,
        familyId,
        updateData: req.body
      });

      if (!updated) {
        return sendError(res, 404, 'NOT_FOUND', 'Goal tidak ditemukan');
      }

      return res.status(200).json(updated);
    } catch (err) {
      return sendError(res, 500, 'INTERNAL_SERVER_ERROR', err.message);
    }
  }

  async approveGoal(req, res) {
    try {
      const { goal_id } = req.params;
      const userId = req.user.id;
      const familyId = req.user.family_id;
      const { decision, comment } = req.body;

      const result = await goalService.approveOrReject({
        goalId: goal_id,
        userId,
        familyId,
        decision,
        comment
      });

      if (result.error === 'NOT_FOUND') {
        return sendError(res, 404, 'NOT_FOUND', 'Goal tidak ditemukan');
      }

      return res.status(200).json(result.data);
    } catch (err) {
      return sendError(res, 500, 'INTERNAL_SERVER_ERROR', err.message);
    }
  }

  async addContribution(req, res) {
    try {
      const { goal_id } = req.params;
      const userId = req.user.id;
      const familyId = req.user.family_id;

      const result = await goalService.addContribution({
        goalId: goal_id,
        userId,
        familyId,
        contributionData: req.body
      });

      if (result.error === 'NOT_FOUND') {
        return sendError(res, 404, 'NOT_FOUND', 'Goal tidak ditemukan');
      }

      return res.status(201).json(result.data);
    } catch (err) {
      return sendError(res, 500, 'INTERNAL_SERVER_ERROR', err.message);
    }
  }
}

module.exports = new GoalController();