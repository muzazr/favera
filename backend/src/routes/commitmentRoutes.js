const express = require('express');
const router = express.Router();
const CommitmentController = require('../controllers/commitmentController');
const { requireAuth } = require('../middlewares/authMiddleware');

router.use(requireAuth);

router.get('/', CommitmentController.getCommitments);
router.post('/', CommitmentController.createCommitment);
router.get('/:commitment_id', CommitmentController.getCommitmentById);
router.patch('/:commitment_id', CommitmentController.reviseCommitment);
router.post('/:commitment_id/approval', CommitmentController.approveCommitment);
router.post('/:commitment_id/progress', CommitmentController.updateProgress);
router.post('/:commitment_id/complete', CommitmentController.completeCommitment);

module.exports = router;