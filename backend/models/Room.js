const { getCollection } = require('../config/file-db');

module.exports = {
  findById: function (id) {
    const qb = getCollection('rooms').find({ _id: id });
    qb._execOverride = async () => (await qb.exec())[0];
    return qb;
  },
  findOne: function (q) {
    const qb = getCollection('rooms').find(q);
    qb._execOverride = async () => (await qb.exec())[0];
    return qb;
  },
  find: function (q = {}) { return getCollection('rooms').find(q); },
  create: async (d) => getCollection('rooms').create(d),
  findByIdAndUpdate: async (id, d, o) => getCollection('rooms').findByIdAndUpdate(id, d, o),
  findByIdAndDelete: async (id) => getCollection('rooms').findByIdAndDelete(id),
  countDocuments: async (q = {}) => getCollection('rooms').countDocuments(q),
  deleteMany: async (q) => getCollection('rooms').deleteMany(q),
};
