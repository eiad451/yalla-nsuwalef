const { getCollection } = require('../config/file-db');

const col = getCollection('users');

function sanitize(doc) {
  if (!doc) return null;
  delete doc.password;
  return doc;
}

module.exports = {
  findById: (id) => {
    const qb = col.findById(id);
    const origExec = qb.exec.bind(qb);
    qb.exec = async () => sanitize(await origExec());
    return qb;
  },
  findOne: (q) => {
    const qb = col.find(q).limit(1);
    qb._single = true;
    const origExec = qb.exec.bind(qb);
    qb.exec = async () => sanitize(await origExec());
    return qb;
  },
  find: (q = {}) => {
    const qb = col.find(q);
    const origExec = qb.exec.bind(qb);
    qb.exec = async () => (await origExec()).map(sanitize);
    return qb;
  },
  create: async (d) => sanitize(await col.create(d)),
  findByIdAndUpdate: async (id, d, o) => sanitize(await col.findByIdAndUpdate(id, d, o)),
  findByIdAndDelete: async (id) => sanitize(await col.findByIdAndDelete(id)),
  findOneAndUpdate: async (q, d, o) => sanitize(await col.findOneAndUpdate(q, d, o)),
  countDocuments: async (q = {}) => col.countDocuments(q),
  deleteMany: async (q) => col.deleteMany(q),
  aggregate: async (p) => col.aggregate(p),
};
