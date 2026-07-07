const { getCollection } = require('../config/file-db');

module.exports = {
  findById: function (id) {
    const qb = getCollection('transactions').find({ _id: id });
    qb._execOverride = async () => (await qb.exec())[0];
    return qb;
  },
  findOne: function (q) {
    const qb = getCollection('transactions').find(q);
    qb._execOverride = async () => (await qb.exec())[0];
    return qb;
  },
  find: function (q = {}) { return getCollection('transactions').find(q); },
  create: async (d) => getCollection('transactions').create(d),
  countDocuments: async (q = {}) => getCollection('transactions').countDocuments(q),
  deleteMany: async (q) => getCollection('transactions').deleteMany(q),
};
