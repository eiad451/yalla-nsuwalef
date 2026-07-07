const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Message = require('../models/Message');
const Room = require('../models/Room');

const connectedUsers = new Map();
const voiceRooms = new Map();

const setupSocket = (io) => {
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) {
        return next(new Error('Authentication required'));
      }
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id).select('-password');
      if (!user) {
        return next(new Error('User not found'));
      }
      socket.user = user;
      next();
    } catch (err) {
      next(new Error('Authentication failed'));
    }
  });

  io.on('connection', async (socket) => {
    const user = socket.user;
    connectedUsers.set(socket.id, { userId: user._id.toString(), socket });
    user.isOnline = true;
    user.lastSeen = new Date();
    await user.save();

    socket.emit('connected', {
      message: 'Connected successfully',
      userId: user._id,
    });

    io.emit('user-status', {
      userId: user._id,
      isOnline: true,
      username: user.username,
    });

    socket.on('join-room', async (data) => {
      try {
        const { roomId, password } = data;
        const room = await Room.findById(roomId);

        if (!room) {
          return socket.emit('error', { message: 'Room not found' });
        }

        if (room.bannedMembers.includes(user._id)) {
          return socket.emit('error', { message: 'You are banned from this room' });
        }

        if (room.type === 'private' && password !== room.password) {
          return socket.emit('error', { message: 'Wrong password' });
        }

        socket.join(roomId);

        if (!room.members.includes(user._id)) {
          room.members.push(user._id);
          await room.save();
        }

        socket.to(roomId).emit('user-joined', {
          userId: user._id,
          username: user.username,
          displayName: user.displayName,
          avatar: user.avatar,
        });

        const systemMsg = await Message.create({
          room: roomId,
          sender: user._id,
          content: `${user.displayName || user.username} joined the room`,
          messageType: 'system',
        });

        io.to(roomId).emit('new-message', {
          _id: systemMsg._id,
          room: roomId,
          sender: {
            _id: user._id,
            username: user.username,
            displayName: user.displayName,
            avatar: user.avatar,
          },
          content: systemMsg.content,
          messageType: 'system',
          createdAt: systemMsg.createdAt,
        });
      } catch (error) {
        socket.emit('error', { message: error.message });
      }
    });

    socket.on('leave-room', async (data) => {
      try {
        const { roomId } = data;
        socket.leave(roomId);

        const room = await Room.findById(roomId);
        if (room) {
          room.members = room.members.filter(m => m.toString() !== user._id.toString());
          await room.save();
        }

        socket.to(roomId).emit('user-left', {
          userId: user._id,
          username: user.username,
        });

        const systemMsg = await Message.create({
          room: roomId,
          sender: user._id,
          content: `${user.displayName || user.username} left the room`,
          messageType: 'system',
        });

        io.to(roomId).emit('new-message', {
          _id: systemMsg._id,
          room: roomId,
          sender: {
            _id: user._id,
            username: user.username,
            displayName: user.displayName,
            avatar: user.avatar,
          },
          content: systemMsg.content,
          messageType: 'system',
          createdAt: systemMsg.createdAt,
        });
      } catch (error) {
        socket.emit('error', { message: error.message });
      }
    });

    socket.on('send-message', async (data) => {
      try {
        const { roomId, content, messageType, mediaUrl, gift } = data;

        const room = await Room.findById(roomId);
        if (!room) {
          return socket.emit('error', { message: 'Room not found' });
        }

        if (!room.members.includes(user._id)) {
          return socket.emit('error', { message: 'Not a member of this room' });
        }

        if (gift) {
          const sender = await User.findById(user._id);
          if (sender.balance < gift.price) {
            return socket.emit('error', { message: 'Insufficient balance' });
          }
          sender.balance -= gift.price;
          await sender.save();
        }

        const message = await Message.create({
          room: roomId,
          sender: user._id,
          content: content || '',
          messageType: messageType || 'text',
          mediaUrl: mediaUrl || '',
          gift,
        });

        room.lastMessage = message._id;
        await room.save();

        const populatedMessage = await Message.findById(message._id)
          .populate('sender', 'username displayName avatar role');

        io.to(roomId).emit('new-message', populatedMessage);
      } catch (error) {
        socket.emit('error', { message: error.message });
      }
    });

    socket.on('typing', (data) => {
      const { roomId, isTyping } = data;
      socket.to(roomId).emit('user-typing', {
        userId: user._id,
        username: user.username,
        isTyping,
      });
    });

    socket.on('delete-message', async (data) => {
      try {
        const { roomId, messageId } = data;
        const message = await Message.findById(messageId);
        if (!message) {
          return socket.emit('error', { message: 'Message not found' });
        }
        if (message.sender.toString() !== user._id.toString()) {
          return socket.emit('error', { message: 'Not authorized' });
        }

        message.isDeleted = true;
        await message.save();

        io.to(roomId).emit('message-deleted', { messageId, roomId });
      } catch (error) {
        socket.emit('error', { message: error.message });
      }
    });

    socket.on('join-voice-room', async (data) => {
      try {
        const { roomId, isSpeaker } = data;
        const room = await Room.findById(roomId);
        if (!room) {
          return socket.emit('error', { message: 'Room not found' });
        }

        if (!voiceRooms.has(roomId)) {
          voiceRooms.set(roomId, { speakers: [], listeners: [] });
        }

        const vr = voiceRooms.get(roomId);
        const userData = {
          userId: user._id.toString(),
          username: user.username,
          displayName: user.displayName,
          avatar: user.avatar,
          isSpeaking: false,
          isMuted: !isSpeaker,
        };

        if (isSpeaker) {
          vr.speakers.push(userData);
        } else {
          vr.listeners.push(userData);
        }

        socket.join(`voice:${roomId}`);
        io.to(`voice:${roomId}`).emit('voice-room-update', vr);
        socket.emit('voice-room-joined', { roomId, ...vr });
      } catch (error) {
        socket.emit('error', { message: error.message });
      }
    });

    socket.on('leave-voice-room', async (data) => {
      try {
        const { roomId } = data;
        const vr = voiceRooms.get(roomId);
        if (vr) {
          vr.speakers = vr.speakers.filter(s => s.userId !== user._id.toString());
          vr.listeners = vr.listeners.filter(l => l.userId !== user._id.toString());
          if (vr.speakers.length === 0 && vr.listeners.length === 0) {
            voiceRooms.delete(roomId);
          } else {
            io.to(`voice:${roomId}`).emit('voice-room-update', vr);
          }
        }
        socket.leave(`voice:${roomId}`);
      } catch (error) {
        socket.emit('error', { message: error.message });
      }
    });

    socket.on('voice-toggle-mute', async (data) => {
      try {
        const { roomId, isMuted } = data;
        const vr = voiceRooms.get(roomId);
        if (vr) {
          const speaker = vr.speakers.find(s => s.userId === user._id.toString());
          if (speaker) {
            speaker.isMuted = isMuted;
          }
          io.to(`voice:${roomId}`).emit('voice-room-update', vr);
        }
      } catch (error) {
        socket.emit('error', { message: error.message });
      }
    });

    socket.on('leave-all-voice-rooms', async () => {
      for (const [roomId, vr] of voiceRooms.entries()) {
        const wasSpeaker = vr.speakers.some(s => s.userId === user._id.toString());
        const wasListener = vr.listeners.some(l => l.userId === user._id.toString());
        if (wasSpeaker || wasListener) {
          vr.speakers = vr.speakers.filter(s => s.userId !== user._id.toString());
          vr.listeners = vr.listeners.filter(l => l.userId !== user._id.toString());
          if (vr.speakers.length === 0 && vr.listeners.length === 0) {
            voiceRooms.delete(roomId);
          } else {
            io.to(`voice:${roomId}`).emit('voice-room-update', vr);
          }
          socket.leave(`voice:${roomId}`);
        }
      }
    });

    socket.on('disconnect', async () => {
      connectedUsers.delete(socket.id);

      user.isOnline = false;
      user.lastSeen = new Date();
      await user.save();

      io.emit('user-status', {
        userId: user._id,
        isOnline: false,
        lastSeen: user.lastSeen,
      });
    });
  });

  return io;
};

module.exports = setupSocket;
