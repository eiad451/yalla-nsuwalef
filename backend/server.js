const express = require('express');
const http = require('http');
const socketIO = require('socket.io');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const connectDB = require('./config/db');
const setupSocket = require('./socket/handler');

const authRoutes = require('./routes/auth');
const roomRoutes = require('./routes/rooms');
const messageRoutes = require('./routes/messages');
const walletRoutes = require('./routes/wallet');
const adminRoutes = require('./routes/admin');
const countryRoutes = require('./routes/countries');
const discoverRoutes = require('./routes/discover');

const app = express();
const server = http.createServer(app);

const io = socketIO(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true,
  },
  pingTimeout: 60000,
  pingInterval: 25000,
});

app.use(cors());
app.use(morgan('dev'));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}
app.use('/uploads', express.static(uploadsDir));

app.get('/', (req, res) => {
  res.json({
    name: 'يلا نسوالف API',
    version: '1.0.0',
    status: 'running',
    time: new Date().toISOString(),
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/rooms', roomRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/countries', countryRoutes);
app.use('/api/discover', discoverRoutes);

app.use('/api/gifts', (req, res) => {
  res.json({
    gifts: [
      { id: 1, name: 'وردة', price: 100, icon: '🌹', category: 'flowers' },
      { id: 2, name: 'قلب', price: 200, icon: '❤️', category: 'romantic' },
      { id: 3, name: 'بوسة', price: 300, icon: '💋', category: 'romantic' },
      { id: 4, name: 'نجمة', price: 500, icon: '⭐', category: 'general' },
      { id: 5, name: 'كعكة', price: 800, icon: '🎂', category: 'celebrations' },
      { id: 6, name: 'تاج', price: 1000, icon: '👑', category: 'premium' },
      { id: 7, name: 'ألماسة', price: 2000, icon: '💎', category: 'premium' },
      { id: 8, name: 'سيارة', price: 5000, icon: '🚗', category: 'luxury' },
      { id: 9, name: 'يخت', price: 10000, icon: '🛥️', category: 'luxury' },
      { id: 10, name: 'قصر', price: 20000, icon: '🏰', category: 'luxury' },
      { id: 11, name: 'طائرة', price: 50000, icon: '✈️', category: 'limited' },
      { id: 12, name: 'ألعاب نارية', price: 100000, icon: '🎆', category: 'limited' },
    ],
    currency: 'coin',
  });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Internal server error', error: err.message });
});

app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

const PORT = process.env.PORT || 3000;

const start = async () => {
  try {
    await connectDB();
    setupSocket(io);
    server.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 يلا نسوالف Server running on port ${PORT}`);
      console.log(`📱 Developer phone: ${process.env.DEV_PHONE || '07744572152'}`);
    });
  } catch (error) {
    console.error(`Failed to start: ${error.message}`);
    process.exit(1);
  }
};

start();
