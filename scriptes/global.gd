extends Node

var gameStarted: bool
var playerBody: CharacterBody2D
var playerAlive: bool
var gameManager: Node = null  # 增加一个变量来存储 GameManager 的引用

var player_lives: int = 3  # 全局变量，用于同步玩家生命值
var reset_player: bool = false  # 新增的变量，用于标记是否需要重置玩家

var reset_count: int = 0  # 记录重置次数

# 提供一个方法来设置 GameManager
func set_game_manager(manager: Node):
	gameManager = manager
