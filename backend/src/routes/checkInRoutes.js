const express = require('express');
const router = express.Router();
const checkInController = require('../controllers/checkInController');
const {requireAuth} = require('../middlewares/authMiddleware');

router.use(requireAuth);

router.get('/current', checkInController.getCurrentCheckIn);
router.get('/', checkInController.getCheckInList);
router.get('/:checkin_id', checkInController.getCheckInById);
router.put('/:checkin_id/answers', checkInController.saveAnswers);
router.post('/:checkin_id/submit', checkInController.submitCheckIn);

module.exports = router;