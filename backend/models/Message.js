const { getCollection } = require('../config/file-db');

module.exports = {
  findById: function (id) {
    const qb = getCollection('messages').find({ _id: id });
    qb._execOverride = async () => (await qb.exec())[0];
    return qb;
  },
  findOne: function (q) {
    const qb = getCollection('messages').find(q);
    qb._execOverride = async () => (await qb.exec())[0];
    return qb;
  },
  find: function (q = {}) { return getCollection('messages').find(q); },
  create: async (d) => getCollection('messages').create(d),
  countDocuments: async (q = {}) => getCollection('messages').countDocuments(q),
  deleteMany: async (q) => getCollection('messages').deleteMany(q),
};
