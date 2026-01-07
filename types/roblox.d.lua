---@meta

--[[
    Roblox Type Definitions for Lua Language Server
    Provides type information for Roblox APIs
]]

---@class DataModel
---@field ReplicatedStorage ReplicatedStorage
---@field ServerScriptService ServerScriptService
---@field StarterPlayer StarterPlayer
---@field StarterGui StarterGui
---@field StarterPack StarterPack
---@field Lighting Lighting
---@field Workspace Workspace
game = {}

---@class Workspace
workspace = {}

---@class ReplicatedStorage
ReplicatedStorage = {}

---@class ServerScriptService
ServerScriptService = {}

---@class StarterPlayer
StarterPlayer = {}

---@class StarterGui
StarterGui = {}

---@class StarterPack
StarterPack = {}

---@class Lighting
Lighting = {}

---@class Players
Players = {}

---@class DataStoreService
DataStoreService = {}

---@class TeleportService
TeleportService = {}

---@class TweenService
TweenService = {}

---@class UserInputService
UserInputService = {}

---@class RunService
RunService = {}

---@class HttpService
HttpService = {}

---@class PathfindingService
PathfindingService = {}

---@class ProximityPromptService
ProximityPromptService = {}

---@class PlayerGui
local PlayerGui = {}

---@class Player
---@field Name string
---@field UserId number
---@field Character Model?
---@field PlayerGui PlayerGui
local Player = {}

---@class Instance
---@field Name string
---@field Parent Instance?
---@function new
---@param className string
---@return Instance
---@function FindFirstChild
---@param childName string
---@param recursive boolean?
---@return Instance?
---@function WaitForChild
---@param childName string
---@param timeout number?
---@return Instance
---@function GetService
---@param serviceName string
---@return Instance
local Instance = {}

---@class Part
---@field Position Vector3
---@field Size Vector3
---@field CFrame CFrame
---@field Anchored boolean
---@field BrickColor BrickColor
local Part = {}

---@class Vector3
---@field X number
---@field Y number
---@field Z number
---@field Magnitude number
---@function new
---@param x number
---@param y number
---@param z number
---@return Vector3
Vector3 = {}

---@class Vector2
---@field X number
---@field Y number
---@function new
---@param x number
---@param y number
---@return Vector2
Vector2 = {}

---@class CFrame
---@function new
---@param x number
---@param y number
---@param z number
---@return CFrame
CFrame = {}

---@class Color3
---@field R number
---@field B number
---@field G number
---@function new
---@param r number
---@param g number
---@param b number
---@return Color3
Color3 = {}

---@class BrickColor
---@function new
---@param color string|number
---@return BrickColor
BrickColor = {}

---@class UDim2
---@function new
---@param xScale number
---@param xOffset number
---@param yScale number
---@param yOffset number
---@return UDim2
UDim2 = {}

---@class UDim
---@function new
---@param scale number
---@param offset number
---@return UDim
UDim = {}

---@class RemoteEvent
---@field OnServerEvent RBXScriptSignal
---@field OnClientEvent RBXScriptSignal
---@function FireServer
---@function FireClient
---@function FireAllClients
local RemoteEvent = {}

---@class RemoteFunction
---@field OnServerInvoke function
---@field OnClientInvoke function
local RemoteFunction = {}

---@class RBXScriptSignal
---@function Connect
---@function Wait
---@function ConnectParallel
local RBXScriptSignal = {}

---@class Model
local Model = {}

---@class Folder
local Folder = {}

---@class ScreenGui
local ScreenGui = {}

---@class Frame
local Frame = {}

---@class TextLabel
local TextLabel = {}

---@class TextButton
local TextButton = {}

---@class ProximityPrompt
local ProximityPrompt = {}

---@class TeleportOptions
---@function SetTeleportData
local TeleportOptions = {}

---@class DataStore
---@function GetAsync
---@function SetAsync
---@function UpdateAsync
local DataStore = {}

---@class Enum
Enum = {}

---@class EnumItem
---@field EasingStyle EnumItem
---@field EasingDirection EnumItem
local EnumItem = {}

---@class TweenInfo
---@function new
---@param time number
---@param easingStyle EnumItem?
---@param easingDirection EnumItem?
---@param repeatCount number?
---@param reverses boolean?
---@param delayTime number?
---@return TweenInfo
TweenInfo = {}

---@class Tween
local Tween = {}

---@class Path
local Path = {}

---@class Humanoid
local Humanoid = {}

---@class HumanoidRootPart
local HumanoidRootPart = {}

---@class Tool
local Tool = {}

---@class NumberValue
local NumberValue = {}

---@class IntValue
local IntValue = {}

---@class StringValue
local StringValue = {}

---@class BoolValue
local BoolValue = {}

---@class ObjectValue
local ObjectValue = {}

---@class Ray
---@function new
---@param origin Vector3
---@param direction Vector3
---@return Ray
Ray = {}

---@class RaycastResult
local RaycastResult = {}

---@class RaycastParams
local RaycastParams = {}

---@class Region3
---@function new
---@param min Vector3
---@param max Vector3
---@return Region3
Region3 = {}

---@class Region3int16
local Region3int16 = {}

---@class Faces
local Faces = {}

---@class Axes
local Axes = {}

---@class NumberSequence
---@function new
---@param keypoints NumberSequenceKeypoint[]
---@return NumberSequence
NumberSequence = {}

---@class NumberSequenceKeypoint
---@function new
---@param time number
---@param value number
---@param envelope number?
---@return NumberSequenceKeypoint
NumberSequenceKeypoint = {}

---@class ColorSequence
---@function new
---@param keypoints ColorSequenceKeypoint[]
---@return ColorSequence
ColorSequence = {}

---@class ColorSequenceKeypoint
---@function new
---@param time number
---@param color Color3
---@return ColorSequenceKeypoint
ColorSequenceKeypoint = {}

---@class TweenService
---@function Create
---@param instance Instance
---@param tweenInfo TweenInfo
---@param properties table
---@return Tween
TweenService = {}

---@class DataStoreService
---@function GetDataStore
---@param name string
---@param scope string?
---@return DataStore
DataStoreService = {}

---@class TeleportService
---@function TeleportAsync
---@param placeId number
---@param players Player[]
---@param teleportOptions TeleportOptions?
---@return boolean, string?
TeleportService = {}

---@class Players
---@field LocalPlayer Player?
---@function GetPlayers
---@return Player[]
---@field PlayerAdded RBXScriptSignal
---@field PlayerRemoving RBXScriptSignal
Players = {}


---@class Workspace
---@function Raycast
---@param origin Vector3
---@param direction Vector3
---@param raycastParams RaycastParams?
---@return RaycastResult?
Workspace = {}

---@class PathfindingService
---@function CreatePath
---@return Path
PathfindingService = {}

---@class ProximityPromptService
---@field PromptTriggered RBXScriptSignal
ProximityPromptService = {}

---@class RunService
---@field Heartbeat RBXScriptSignal
---@field RenderStepped RBXScriptSignal
---@field Stepped RBXScriptSignal
RunService = {}

---@class HttpService
---@function GenerateGUID
---@param wrapInCurlyBraces boolean?
---@return string
HttpService = {}

---@class Lighting
---@field ClockTime number
---@field TimeOfDay string
Lighting = {}

---@class game
---@function GetService
---@param serviceName string
---@return Instance
game = {}

--- Standard Lua functions
---@param ... any
---@return any
function print(...) end

---@param ... any
function warn(...) end

---@param ... any
function error(...) end

---@param seconds number?
---@return number
function wait(seconds) end

---@param seconds number
---@param callback function
function delay(seconds, callback) end

---@param callback function
function spawn(callback) end

---@return number
function tick() end

---@return number
function time() end

---@param value any
---@return string
function type(value) end

---@param value any
---@return string
function typeof(value) end

---@class task
task = {}

---@param callback function
---@param ... any
---@return thread
function task.spawn(callback, ...) end

---@param seconds number
function task.wait(seconds) end

---@param seconds number
function task.delay(seconds, callback) end

--- Standard library
---@class table
table = {}

---@class string
string = {}

---@class math
math = {}

---@class os
os = {}
