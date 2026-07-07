const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

function objId(v) {
  if (!v) return v;
  if (typeof v === 'object') return v._id || v.toString();
  return v;
}

function deepMatch(obj, query) {
  for (const key of Object.keys(query)) {
    if (key === '$or') {
      if (!query.$or.some(clause => deepMatch(obj, clause))) return false;
      continue;
    }
    if (key === '$text') {
      const q = (query.$text.$search || '').toLowerCase();
      const t = ((obj.name || '') + ' ' + (obj.description || '')).toLowerCase();
      if (!t.includes(q)) return false;
      continue;
    }
    if (key.startsWith('$')) continue;

    const val = query[key];
    const objVal = obj[key];

    if (val !== null && typeof val === 'object' && !Array.isArray(val)) {
      if ('$ne' in val && objId(objVal) === objId(val.$ne)) return false;
      if (val.$regex) {
        const re = new RegExp(val.$regex, val.$options || 'i');
        if (!re.test(objVal || '')) return false;
      }
      if (val.$in && !val.$in.map(v => objId(v)).includes(objId(objVal))) return false;
      if (val.$nin && val.$nin.map(v => objId(v)).includes(objId(objVal))) return false;
      if ('$gte' in val && !(objVal >= val.$gte)) return false;
      if ('$lte' in val && !(objVal <= val.$lte)) return false;
      if ('$gt' in val && !(objVal > val.$gt)) return false;
      if ('$lt' in val && !(objVal < val.$lt)) return false;
      if ('$exists' in val && (val.$exists ? objVal === undefined : objVal !== undefined)) return false;
    } else {
      if (objId(objVal) !== objId(val)) return false;
    }
  }
  return true;
}

function sortCompare(sortObj) {
  const keys = Object.keys(sortObj);
  return (a, b) => {
    for (const key of keys) {
      const dir = sortObj[key];
      let aVal = a[key], bVal = b[key];
      if (key === 'createdAt' || key === 'updatedAt' || key === 'lastSeen') {
        aVal = aVal ? new Date(aVal).getTime() : 0;
        bVal = bVal ? new Date(bVal).getTime() : 0;
      } else if (typeof aVal === 'string') {
        const cmp = (aVal || '').localeCompare(bVal || '');
        if (cmp !== 0) return dir * cmp;
        continue;
      }
      aVal = typeof aVal === 'number' ? aVal : 0;
      bVal = typeof bVal === 'number' ? bVal : 0;
      if (aVal !== bVal) return dir * (aVal - bVal);
    }
    return 0;
  };
}

class QueryBuilder {
  constructor(collection) {
    this._collection = collection;
    this._query = {};
    this._options = { sort: {}, skip: 0, limit: 0, select: '', populate: [] };
    this._single = false;
  }

  find(query) { this._query = { ...this._query, ...query }; return this; }
  sort(s) { Object.assign(this._options.sort, s); return this; }
  skip(n) { this._options.skip = n; return this; }
  limit(n) { this._options.limit = n; return this; }
  select(s) { this._options.select = s; return this; }

  populate(field, selectStr) {
    this._options.populate.push({ path: field, select: selectStr || '' });
    return this;
  }

  async exec() {
    let results = this._collection._raw().filter(d => deepMatch(d, this._query));
    if (Object.keys(this._options.sort).length) {
      results.sort(sortCompare(this._options.sort));
    }
    if (this._options.skip) results = results.slice(this._options.skip);
    if (this._options.limit) results = results.slice(0, this._options.limit);
    results = results.map(d => this._populateDoc(d));
    if (this._options.select) {
      const fields = this._options.select.split(' ').filter(Boolean);
      results = results.map(d => {
        const obj = {};
        fields.forEach(f => {
          if (f === '-password') return;
          if (d[f] !== undefined) obj[f] = d[f];
        });
        return obj;
      });
    }
    const wrapped = results.map(d => this._wrap(d));
    if (this._single) return wrapped[0] || null;
    return wrapped;
  }

  _populateDoc(doc) {
    for (const p of this._options.populate) {
      const refId = doc[p.path];
      if (!refId) continue;
      const id = objId(refId);
      const ref = this._collection._raw().find(r => r._id === id);
      if (ref) {
        const select = p.select || '';
        if (select) {
          const fields = select.split(' ').filter(Boolean);
          doc[p.path] = {};
          fields.forEach(f => { if (ref[f] !== undefined) doc[p.path][f] = ref[f]; });
        } else {
          doc[p.path] = { ...ref };
        }
      }
    }
    return doc;
  }

  _wrap(doc) {
    if (!doc || typeof doc !== 'object') return doc;
    const _id = doc._id;
    const self = this._collection;
    doc.save = async () => {
      const idx = self._raw().findIndex(d => d._id === _id);
      if (idx !== -1) {
        self._raw()[idx] = doc;
        self.save();
      }
    };
    return doc;
  }

  then(resolve, reject) {
    return this.exec().then(resolve, reject);
  }
}

class FileDB {
  constructor(name) {
    this.name = name;
    this.filePath = path.join(__dirname, '..', 'data', `${name}.json`);
    this._docs = [];
    this.load();
  }

  load() {
    try {
      if (fs.existsSync(this.filePath)) {
        this._docs = JSON.parse(fs.readFileSync(this.filePath, 'utf8'));
        this._docs.forEach(d => { if (!d._id) d._id = this._newId(); });
      }
    } catch (e) { this._docs = []; }
  }

  save() {
    const dir = path.dirname(this.filePath);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(this.filePath, JSON.stringify(this._docs, null, 2));
  }

  _raw() { return this._docs; }
  _newId() { return crypto.randomBytes(12).toString('hex'); }

  find(query = {}) { return new QueryBuilder(this).find(query); }

  async findOne(query) {
    return this.find(query).limit(1).exec().then(r => r[0] || null);
  }

  findById(id) {
    const qb = this.find({ _id: id }).limit(1);
    qb._single = true;
    return qb;
  }

  async create(doc) {
    const now = new Date().toISOString();
    const d = { _id: this._newId(), ...doc, createdAt: now, updatedAt: now };
    if (doc.createdAt) d.createdAt = doc.createdAt;
    this._docs.push(d);
    this.save();
    return d;
  }

  async findByIdAndUpdate(id, update, opts = {}) {
    const idx = this._docs.findIndex(d => d._id === id);
    if (idx === -1) return null;
    const doc = this._docs[idx];
    if (update.$set) Object.assign(doc, update.$set);
    else if (update.$push) {
      for (const [k, v] of Object.entries(update.$push)) {
        if (!doc[k]) doc[k] = [];
        if (!doc[k].some(x => objId(x) === objId(v))) doc[k].push(v);
      }
    } else if (update.$pull) {
      for (const [k, v] of Object.entries(update.$pull)) {
        if (Array.isArray(doc[k])) doc[k] = doc[k].filter(x => objId(x) !== objId(v));
      }
    } else if (update.$inc) {
      for (const [k, v] of Object.entries(update.$inc)) doc[k] = (doc[k] || 0) + v;
    } else {
      Object.assign(doc, update);
    }
    doc.updatedAt = new Date().toISOString();
    this._docs[idx] = doc;
    this.save();
    return { ...doc };
  }

  async findByIdAndDelete(id) {
    const idx = this._docs.findIndex(d => d._id === id);
    if (idx === -1) return null;
    const doc = this._docs[idx];
    this._docs.splice(idx, 1);
    this.save();
    return { ...doc };
  }

  async findOneAndUpdate(query, update, opts = {}) {
    const doc = await this.findOne(query);
    if (!doc) return null;
    return this.findByIdAndUpdate(doc._id, update, opts);
  }

  async deleteMany(query) {
    const before = this._docs.length;
    this._docs = this._docs.filter(d => !deepMatch(d, query));
    this.save();
    return { deletedCount: before - this._docs.length };
  }

  async countDocuments(query = {}) {
    return this._docs.filter(d => deepMatch(d, query)).length;
  }

  async aggregate(pipeline) {
    let results = [...this._docs];
    for (const stage of pipeline) {
      if (stage.$group) {
        const groups = {};
        for (const doc of results) {
          let key;
          if (stage.$group._id === null) key = '__all__';
          else {
            const field = stage.$group._id.startsWith('$') ? stage.$group._id.slice(1) : stage.$group._id;
            key = doc[field];
          }
          const ks = typeof key === 'string' ? key : JSON.stringify(key);
          if (!groups[ks]) groups[ks] = { _id: key };
          for (const [field, expr] of Object.entries(stage.$group)) {
            if (field === '_id') continue;
            if (expr.$sum) {
              const fieldName = typeof expr.$sum === 'string' && expr.$sum.startsWith('$') ? expr.$sum.slice(1) : null;
              const val = fieldName ? (doc[fieldName] || 0) : (typeof expr.$sum === 'number' ? expr.$sum : 0);
              groups[ks][field] = (groups[ks][field] || 0) + val;
            }
          }
        }
        results = Object.values(groups);
      }
    }
    return results;
  }

  async updateOne(query, update) {
    const docs = this._docs.filter(d => deepMatch(d, query));
    if (docs.length === 0) return { modifiedCount: 0 };
    const doc = docs[0];
    if (update.$set) Object.assign(doc, update.$set);
    else if (update.$push) {
      for (const [k, v] of Object.entries(update.$push)) {
        if (!doc[k]) doc[k] = [];
        if (!doc[k].some(x => objId(x) === objId(v))) doc[k].push(v);
      }
    } else if (update.$pull) {
      for (const [k, v] of Object.entries(update.$pull)) {
        if (Array.isArray(doc[k])) doc[k] = doc[k].filter(x => objId(x) !== objId(v));
      }
    }
    doc.updatedAt = new Date().toISOString();
    this.save();
    return { modifiedCount: 1 };
  }
}

const collections = {};

function getCollection(name) {
  if (!collections[name]) collections[name] = new FileDB(name);
  return collections[name];
}

module.exports = { FileDB, getCollection };
