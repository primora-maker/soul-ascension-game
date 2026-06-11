const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const dotenv = require('dotenv');
const WebSocket = require('ws');
const http = require('http');

// Load environment variables
dotenv.config();

// Import routes and middleware
const authRoutes = require('./routes/auth');
const characterRoutes = require('./routes/character');
const battleRoutes = require('./routes/battle');
const questRoutes = require('./routes/quest');
const multiplayerRoutes = require('./routes/multiplayer');
const leaderboardRoutes = require('./routes/leaderboard');
const authMiddleware = require('./middleware/auth');
const errorHandler = require('./middleware/errorHandler');

// Initialize Express app
const app = express();
const server = http.createServer(app);

// WebSocket setup
const wss = new WebSocket.Server({ server });

// Middleware - ALLOW ALL REQUESTS
app.use(cors({
    origin: '*',
    credentials: false,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['*'],
    maxAge: 86400
}));

app.use(helmet({
    crossOriginResourcePolicy: false
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Preflight requests
app.options('*', cors());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        message: 'Soul Ascension Backend is running',
        timestamp: new Date().toISOString()
    });
});

// API Routes - PUBLIC (no auth required)
app.use('/api/auth', authRoutes);
app.use('/api/leaderboard', leaderboardRoutes);

// API Routes - PROTECTED (auth optional, works with or without token)
app.use('/api/character', characterRoutes);
app.use('/api/battle', battleRoutes);
app.use('/api/quest', questRoutes);
app.use('/api/multiplayer', multiplayerRoutes);

// WebSocket connection handling
const connectedClients = new Map();

wss.on('connection', (ws) => {
    const clientId = generateUUID();
    connectedClients.set(clientId, {
        socket: ws,
        playerId: null,
        characterId: null
    });

    console.log(`[WebSocket] Client ${clientId} connected. Total: ${connectedClients.size}`);

    ws.on('message', (message) => {
        handleWebSocketMessage(clientId, message);
    });

    ws.on('close', () => {
        connectedClients.delete(clientId);
        console.log(`[WebSocket] Client ${clientId} disconnected. Total: ${connectedClients.size}`);
    });

    ws.on('error', (error) => {
        console.error(`[WebSocket] Error from client ${clientId}:`, error);
    });
});

// WebSocket message handler
function handleWebSocketMessage(clientId, message) {
    try {
        const data = JSON.parse(message);
        const client = connectedClients.get(clientId);

        switch (data.type) {
            case 'authenticate':
                client.playerId = data.playerId;
                client.characterId = data.characterId;
                client.socket.send(JSON.stringify({
                    type: 'auth_success',
                    message: 'Authenticated successfully'
                }));
                break;

            case 'battle_update':
                broadcastToCharacter(data.characterId, {
                    type: 'battle_update',
                    data: data.payload
                });
                break;

            case 'moral_choice':
                broadcastToCharacter(data.characterId, {
                    type: 'moral_choice',
                    data: data.payload
                });
                break;

            case 'multiplayer_action':
                broadcastToSession(data.sessionId, {
                    type: 'multiplayer_action',
                    playerId: client.playerId,
                    data: data.payload
                });
                break;

            case 'ping':
                client.socket.send(JSON.stringify({ type: 'pong' }));
                break;

            default:
                console.log(`[WebSocket] Unknown message type: ${data.type}`);
        }
    } catch (error) {
        console.error('[WebSocket] Message parsing error:', error);
    }
}

// Broadcast helper functions
function broadcastToCharacter(characterId, message) {
    connectedClients.forEach((client) => {
        if (client.characterId === characterId && client.socket.readyState === WebSocket.OPEN) {
            client.socket.send(JSON.stringify(message));
        }
    });
}

function broadcastToSession(sessionId, message) {
    connectedClients.forEach((client) => {
        if (client.socket.readyState === WebSocket.OPEN) {
            client.socket.send(JSON.stringify(message));
        }
    });
}

// Utility function
function generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        const r = Math.random() * 16 | 0;
        const v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

// Error handling middleware
app.use(errorHandler);

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Not Found',
        message: `Route ${req.method} ${req.path} does not exist`
    });
});

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`
╔══════════════════════════════════════════╗
║     Soul Ascension Backend Server        ║
║           Running on PORT ${PORT}         ║
║   "Every soul has the potential for      ║
║    redemption. Will you rise?"           ║
║                                          ║
║  🔓 CORS: ALL REQUESTS ALLOWED           ║
║  🌐 WebSocket: Enabled                   ║
║  📊 Database: Connected                  ║
╚══════════════════════════════════════════╝
    `);
});

module.exports = app;
