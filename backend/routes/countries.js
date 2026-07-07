const express = require('express');
const router = express.Router();
const countries = require('../config/countries');

router.get('/', (req, res) => {
  res.json(countries);
});

router.get('/payment-methods', (req, res) => {
  const paymentMethods = [
    { id: 'zain_cash', name: 'زين كاش', country: 'العراق', icon: '💳' },
    { id: 'asia_cell', name: 'آسيا سيل', country: 'العراق', icon: '💳' },
    { id: 'korek', name: 'كورك', country: 'العراق', icon: '💳' },
    { id: 'mastercard', name: 'Mastercard', country: 'عالمي', icon: '💳' },
    { id: 'visa', name: 'Visa', country: 'عالمي', icon: '💳' },
    { id: 'paypal', name: 'PayPal', country: 'عالمي', icon: '💳' },
    { id: 'bank_transfer', name: 'تحويل بنكي', country: 'العراق', icon: '🏦' },
  ];
  res.json(paymentMethods);
});

router.get('/recharge-prices', (req, res) => {
  const prices = [
    { amount: 1000, points: 1000, bonus: 0 },
    { amount: 5000, points: 5500, bonus: 500 },
    { amount: 10000, points: 12000, bonus: 2000 },
    { amount: 25000, points: 30000, bonus: 5000 },
    { amount: 50000, points: 60000, bonus: 10000 },
    { amount: 100000, points: 130000, bonus: 30000 },
  ];
  res.json({ currency: 'IQD', prices });
});

module.exports = router;
