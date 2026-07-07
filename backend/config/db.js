const path = require('path');
const fs = require('fs');

const connectDB = async () => {
  const dataDir = path.join(__dirname, '..', 'data');
  if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
  }
  console.log('File-based database initialized at:', dataDir);
  return true;
};

module.exports = connectDB;
