const express = require('express');
const router = express.Router();
const { optionalAuth } = require('../middleware/auth');
const db = require('../database/db');
const { body, validationResult } = require('express-validator');

// Apply optional auth to all routes
router.use(optionalAuth);

/**
 * Create a new character
 * POST /api/character/create
 */
router.post('/create', [
    body('character_name').optional().isLength({ min: 2, max: 255 }).trim(),
    body('soul_name').optional().trim()
], async (req, res, next) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { character_name, soul_name } = req.body;
        
        // If no player auth, use guest ID
        const playerId = req.player ? req.player.id : 1;
        const characterName = character_name || 'Soul_' + Math.floor(Math.random() * 10000);

        // Create character with default stats
        const result = await db.query(
            `INSERT INTO characters (
                player_id, character_name, soul_name, current_phase, level,
                experience_points, moral_alignment, current_health, max_health,
                spiritual_energy, max_spiritual_energy, created_at, updated_at
            ) VALUES ($1, $2, $3, 'hell', 1, 0, 0, 100, 100, 50, 50, NOW(), NOW())
            RETURNING *`,
            [playerId, characterName, soul_name || 'Unknown Soul']
        );

        const character = result.rows[0];

        // Log creation
        await db.execute(
            `INSERT INTO activity_logs (
                character_id, player_id, activity_type, current_phase, clock_in, created_at
            ) VALUES ($1, $2, 'character_created', $3, NOW(), NOW())`,
            [character.id, playerId, character.current_phase]
        );

        res.status(201).json({
            message: 'Character created successfully',
            character
        });
    } catch (error) {
        next(error);
    }
});

/**
 * Get all characters for player
 * GET /api/character/my-characters
 */
router.get('/my-characters', async (req, res, next) => {
    try {
        const playerId = req.player ? req.player.id : 1;

        const characters = await db.getAll(
            `SELECT * FROM characters WHERE player_id = $1 AND deleted_at IS NULL`,
            [playerId]
        );

        res.json({
            count: characters.length,
            characters
        });
    } catch (error) {
        next(error);
    }
});

/**
 * Get character details
 * GET /api/character/:characterId
 */
router.get('/:characterId', async (req, res, next) => {
    try {
        const { characterId } = req.params;

        const character = await db.getOne(
            `SELECT * FROM characters WHERE id = $1`,
            [characterId]
        );
        
        if (!character) {
            return res.status(404).json({
                error: 'Not Found',
                message: 'Character not found'
            });
        }

        // Get character abilities
        const abilities = await db.getAll(
            `SELECT a.* FROM abilities a
             JOIN character_abilities ca ON a.id = ca.ability_id
             WHERE ca.character_id = $1`,
            [characterId]
        );

        // Get moral choices made
        const moralChoices = await db.getAll(
            `SELECT * FROM moral_choices WHERE character_id = $1 ORDER BY created_at DESC LIMIT 10`,
            [characterId]
        );

        res.json({
            character,
            abilities,
            recent_moral_choices: moralChoices
        });
    } catch (error) {
        next(error);
    }
});

/**
 * Update character stats
 * PATCH /api/character/:characterId/stats
 */
router.patch('/:characterId/stats', async (req, res, next) => {
    try {
        const { characterId } = req.params;

        const character = await db.getOne(
            'SELECT * FROM characters WHERE id = $1',
            [characterId]
        );
        
        if (!character) {
            return res.status(404).json({
                error: 'Not Found',
                message: 'Character not found'
            });
        }

        const {
            experience_points,
            moral_alignment,
            faith_level,
            hope_level,
            love_level,
            righteousness_points,
            redemption_tokens
        } = req.body;

        // Build update query dynamically
        const updates = [];
        const values = [];
        let paramCount = 1;

        if (experience_points !== undefined) {
            updates.push(`experience_points = $${paramCount++}`);
            values.push(experience_points);
        }
        if (moral_alignment !== undefined) {
            updates.push(`moral_alignment = $${paramCount++}`);
            values.push(moral_alignment);
        }
        if (faith_level !== undefined) {
            updates.push(`faith_level = $${paramCount++}`);
            values.push(faith_level);
        }
        if (hope_level !== undefined) {
            updates.push(`hope_level = $${paramCount++}`);
            values.push(hope_level);
        }
        if (love_level !== undefined) {
            updates.push(`love_level = $${paramCount++}`);
            values.push(love_level);
        }
        if (righteousness_points !== undefined) {
            updates.push(`righteousness_points = $${paramCount++}`);
            values.push(righteousness_points);
        }
        if (redemption_tokens !== undefined) {
            updates.push(`redemption_tokens = $${paramCount++}`);
            values.push(redemption_tokens);
        }

        if (updates.length === 0) {
            return res.status(400).json({
                error: 'Bad Request',
                message: 'No fields to update'
            });
        }

        updates.push('updated_at = NOW()');
        values.push(characterId);

        const query = `UPDATE characters SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`;
        const result = await db.query(query, values);
        const updatedCharacter = result.rows[0];

        res.json({
            message: 'Character updated successfully',
            character: updatedCharacter
        });
    } catch (error) {
        next(error);
    }
});

/**
 * Delete character (soft delete)
 * DELETE /api/character/:characterId
 */
router.delete('/:characterId', async (req, res, next) => {
    try {
        const { characterId } = req.params;

        const character = await db.getOne(
            'SELECT * FROM characters WHERE id = $1',
            [characterId]
        );
        
        if (!character) {
            return res.status(404).json({
                error: 'Not Found',
                message: 'Character not found'
            });
        }

        // Soft delete
        await db.execute(
            'UPDATE characters SET deleted_at = NOW() WHERE id = $1',
            [characterId]
        );

        res.json({ message: 'Character deleted successfully' });
    } catch (error) {
        next(error);
    }
});

module.exports = router;
